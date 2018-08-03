//
//  LoginConfiguration.swift
//
//  Copyright (c) 2016-present, LINE Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LINE Corporation.
//
//  As with any software that integrates with the LINE Corporation platform, your use of this software
//  is subject to the LINE Developers Agreement [http://terms2.line.me/LINE_Developers_Agreement].
//  This copyright notice shall be included in all copies or substantial portions of the software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation

public class LoginManager {
    
    let lock = NSLock()
    
    public static let shared = LoginManager()
    public private(set) var currentProcess: LoginProcess?
    var setup = false
    public var isSetupFinished: Bool {
        lock.lock()
        defer { lock.unlock() }
        return setup
    }
    
    public var isAuthorized: Bool {
        return AccessTokenStore.shared.current != nil
    }
    
    public var isAuthorizing: Bool {
        return currentProcess != nil
    }
    
    private init() { }
    
    public func setup(channelID: String, universalLinkURL: URL?) {
        
        lock.lock()
        defer { lock.unlock() }
        
        guard !setup else {
            Log.assertionFailure("Trying to set configuration multiplet times is not permitted.")
            return
        }
        defer { setup = true }
        
        let config = LoginConfiguration(channelID: channelID, universalLinkURL: universalLinkURL)
        LoginConfiguration.shared = config
        AccessTokenStore.shared = AccessTokenStore(configuration: config)
        Session.shared = Session(configuration: config)
    }
    
    @discardableResult
    public func login(
        permissions: Set<LoginPermission> = [],
        in viewController: UIViewController? = nil,
        completionHandler completion: @escaping (Result<LoginResult>) -> Void) -> LoginProcess? {
        
        lock.lock()
        defer { lock.unlock() }
        
        guard currentProcess == nil else {
            Log.assertionFailure("Trying to start another login process " +
                "while the previous one still valid is not permitted.")
            return nil
        }
        
        let process = LoginProcess(
            configuration: LoginConfiguration.shared,
            scopes: permissions,
            viewController: viewController)
        process.start()
        process.onSucceed.delegate(on: self) { [unowned process] (self, token) in
            self.currentProcess = nil
            do {
                try self.postLogin(token, process: process, completionHandler: completion)
            } catch {
                completion(.failure(error))
            }
        }
        process.onFail.delegate(on: self) { (self, error) in
            self.currentProcess = nil
            completion(.failure(error))
        }
        
        self.currentProcess = process
        return currentProcess
    }
    
    func postLogin(
        _ token: AccessToken,
        process: LoginProcess,
        completionHandler completion: @escaping (Result<LoginResult>) -> Void) throws {
        // Store token
        try AccessTokenStore.shared.setCurrentToken(token)
        if token.permissions.contains(.profile) {
            Session.shared.send(GetUserProfileRequest()) { profileResult in
                let result = LoginResult.init(
                    accessToken: token,
                    permissions: Set(token.permissions),
                    userProfile: profileResult.value)
                completion(.success(result))
            }
        } else {
            let result = LoginResult.init(
                accessToken: token,
                permissions: Set(token.permissions),
                userProfile: nil)
            completion(.success(result))
        }
    }
    
    public func logout(completionHandler completion: @escaping (Result<()>) -> Void) {
        LineSDKAPI.revokeAccessToken(completionHandler: completion)
    }
    
    @available(iOS 9.0, *)
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[.sourceApplication] as? String
        let annotation = options[.annotation] as Any
        return application(app, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // Not in login process. Ignore.
        guard let currentProcess = currentProcess else { return false }
        
        return currentProcess.resumeOpenURL(url: url, sourceApplication: sourceApplication)
    }

}
