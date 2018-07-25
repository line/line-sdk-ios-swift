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

public protocol LoginManagerDelegate: class {
    func loginManager(_ manager: LoginManager, didSucceed loginProcess: LoginProcess, withResult: LoginResult)
    func loginManager(_ manager: LoginManager, didFail loginProcess: LoginProcess, withError: Error)
}

extension LoginManagerDelegate {
    
}

public class LoginManager {
    
    public static let shared = LoginManager()
    
    public private(set) var currentProcess: LoginProcess?
    public weak var delegate: LoginManagerDelegate?
    
    var configuration: LoginConfiguration?
    
    private init() { }
    
    public func setup(channelID: String) {
        guard configuration == nil else {
            Log.assertionFailure("Trying to set configuration multiplet times is not permitted.")
            return
        }
        
        let config = LoginConfiguration(channelID: channelID)
        self.configuration = config
        Session.shared = Session(configuration: config)
    }
    
    @discardableResult
    public func login(permissions: Set<LoginPermission> = [], in viewController: UIViewController? = nil) -> LoginProcess? {
        guard currentProcess == nil else {
            Log.assertionFailure("Trying to start another login process while the previous one still valid is not permitted.")
            return nil
        }
        let process = LoginProcess(configuration: configuration!, scopes: permissions, viewController: viewController)
        process.start()
        
        process.onSucceed.delegate(on: self) { (self, result) in
            self.delegate?.loginManager(self, didSucceed: process, withResult: result)
        }
        process.onFail.delegate(on: self) { (self, error) in
            self.delegate?.loginManager(self, didFail: process, withError: error)
        }
        
        self.currentProcess = process
        return currentProcess
    }
    
    @available(iOS 9.0, *)
    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
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
