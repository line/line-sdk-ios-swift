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

/// `LoginManager` takes responsibility of login process management. You could setup the LineSDK configuration,
/// let your users login or logout with LINE authorization flows and check the authorizing state.
public class LoginManager {
    
    let lock = NSLock()
    
    /// Shared instance of manager. You should always use this instance to interact with LineSDK login process.
    public static let shared = LoginManager()
    
    /// Current login process. A non-`nil` value means there is an on-going process and LineSDK is waiting for the
    /// login result. Otherwise, `nil`.
    public private(set) var currentProcess: LoginProcess?
    
    /// Returns whether current `LoginManager` instance is setup and ready to use. You should call `setup` method
    /// to setup the SDK with its basic information before you call any other methods or properties in LineSDK.
    public var isSetupFinished: Bool {
        lock.lock()
        defer { lock.unlock() }
        return setup
    }
    
    /// Returns whether a user was authorized and a token is existing locally.
    /// This does not check whether a token is expired or not.
    /// To verify a token, use `API.verifyAccessToken` instead.
    public var isAuthorized: Bool {
        return AccessTokenStore.shared.current != nil
    }
    
    /// Returns whether the authorizing process is currently on-going.
    public var isAuthorizing: Bool {
        return currentProcess != nil
    }
    
    /// A flag to prevent setup multiple times
    var setup = false
    
    private init() { }
    
    /// Setups current `LoginManager` instance.
    ///
    /// - Parameters:
    ///   - channelID: The channel ID your app is registering.
    ///   - universalLinkURL: A universal link used to navigate back to your app from LINE client app.
    /// - Note:
    ///   This should be the first method you call before you access any other methods or properties in LineSDK.
    ///   A login manager cannot be setup for multiple times, so do not call it more than once.
    ///
    ///   Providing a valid `universalLinkURL` is strongly suggested. You need to setup your own universal link callback
    ///   in your channel setting by following guide on LINE developer dev center page. When set properly, LINE client
    ///   will try to bring up your app by universal link first, which dramatically improves the security of
    ///   authorization flow and protects your data. If `universalLinkURL` is `nil`, only custom URL scheme will be
    ///   used to open your app after authorization in LINE client.
    ///
    public func setup(channelID: String, universalLinkURL: URL?) {
        
        lock.lock()
        defer { lock.unlock() }
        
        guard !setup else {
            Log.assertionFailure("Trying to set configuration multiple times is not permitted.")
            return
        }
        defer { setup = true }
        
        let config = LoginConfiguration(channelID: channelID, universalLinkURL: universalLinkURL)
        LoginConfiguration._shared = config
        AccessTokenStore._shared = AccessTokenStore(configuration: config)
        Session._shared = Session(configuration: config)
    }
    
    /// Login to LINE service.
    ///
    /// - Parameters:
    ///   - permissions: The set of permissions which are required by client app. Default is `[.profile]`.
    ///   - viewController: The view controller from which LineSDK should present its login view controller.
    ///                     If `nil`, the most top view controller in current view controller hierarchy will be used.
    ///   - options: The options used during login process. See `LoginManagerOptions` for more.
    ///   - completion: The completion closure to be executed when login action finishes.
    /// - Returns: A `LoginProcess` object which indicates this started login process.
    ///
    /// - Note:
    ///   Only one process could be started at a time. You should not call this method again to start a new login
    ///         process before `completion` being invoked.
    ///
    ///   If `.profile` is contained in `permissions`, the user profile will be retrieved during the login process
    ///   and contained in the `userProfile` property of `LoginResult` in `completionHandler`. Otherwise, `userProfile`
    ///   will be `nil`. You could use this profile to identify your user. See `UserProfile` for more.
    ///
    ///   The access token will be issued if user authorized your app. This token will be stored to keychain of your
    ///   app automatically for later use. A refresh token will be stored as well, and all API invocation will try to
    ///   refresh the access token if necessary, so basically you do not need to worry about it. However, if you would
    ///   like to refresh the access token manually, use `API.refreshAccessToken(with:)`.
    ///
    @discardableResult
    public func login(
        permissions: Set<LoginPermission> = [.profile],
        in viewController: UIViewController? = nil,
        options: LoginManagerOptions = [],
        completionHandler completion: @escaping (Result<LoginResult>) -> Void) -> LoginProcess?
    {
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
            options: options,
            viewController: viewController)
        process.start()
        process.onSucceed.delegate(on: self) { [unowned process] (self, result) in
            self.currentProcess = nil
            self.postLogin(
                token: result.token,
                response: result.response,
                process: process,
                completionHandler: completion)
        }
        process.onFail.delegate(on: self) { (self, error) in
            self.currentProcess = nil
            completion(.failure(error))
        }
        
        self.currentProcess = process
        return currentProcess
    }
    
    /// Actions after auth process finishes. We do something like storing token and getting user profile before we
    /// inform framework users every thing is done.
    ///
    /// - Parameters:
    ///   - token: The access token retrieved from auth server.
    ///   - response: The URL response object created when a login callback URL opened by SDK.
    ///   - process: The related login process initialized by `login` method.
    ///   - completion: The completion closure to be executed when the whole login process finishes.
    func postLogin(
        token: AccessToken,
        response: LoginProcessURLResponse,
        process: LoginProcess,
        completionHandler completion: @escaping (Result<LoginResult>) -> Void) {
        // Store token
        do {
            try AccessTokenStore.shared.setCurrentToken(token)
        } catch {
            completion(.failure(error))
            return
        }
        
        if token.permissions.contains(.profile) {
            Session.shared.send(GetUserProfileRequest()) { profileResult in
                let result = LoginResult.init(
                    accessToken: token,
                    permissions: Set(token.permissions),
                    userProfile: profileResult.value,
                    friendshipStatusChanged: response.friendshipStatusChanged)
                completion(.success(result))
            }
        } else {
            let result = LoginResult.init(
                accessToken: token,
                permissions: Set(token.permissions),
                userProfile: nil,
                friendshipStatusChanged: response.friendshipStatusChanged)
            completion(.success(result))
        }
    }
    
    /// Logout current user by revoking the access token.
    ///
    /// - Parameter completion: The completion closure to be executed when logout action finishes.
    public func logout(completionHandler completion: @escaping (Result<()>) -> Void) {
        API.revokeAccessToken(completionHandler: completion)
    }
    
    /// Asks this `LoginManager` to handle a url callback from either LINE client app or web login flow.
    ///
    /// - Parameters:
    ///   - app: The singleton app object.
    ///   - url: The URL resource to open. This resource should be the URL iOS system pass to you in
    ///          related `UIApplicationDelegate` methods.
    ///   - options: A dictionary of URL handling options which passed to you in related
    ///              `UIApplicationDelegate` methods.
    /// - Returns: Whether the `url` is successfully handled or not. If the input `url` is a valid login callback url,
    ///            it will be handled and `true` is returned.
    /// - Note: This method has the same method signature as in `UIApplicationDelegate`. You can just pass in all
    ///         arguments without modifying anything.
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        guard let currentProcess = currentProcess else { return false }
        let sourceApplication = options[.sourceApplication] as? String
        return currentProcess.resumeOpenURL(url: url, sourceApplication: sourceApplication)
    }
}
