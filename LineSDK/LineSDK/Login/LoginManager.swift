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

import UIKit

/// Represents a login manager. You can set up the LINE SDK configuration, log in and log out the user with the
/// LINE authorization flow, and check the authorization status.
public class LoginManager {

    let lock = NSLock()

    /// The shared instance of the login manager. Always use this instance to interact with the login process of
    /// the LINE SDK.
    public static let shared = LoginManager()

    /// The current login process. A non-`nil` value indicates that there is an ongoing process and the LINE SDK
    /// is waiting for the login result; `nil` otherwise.
    public private(set) var currentProcess: LoginProcess?

    /// Checks and returns whether the current `LoginManager` instance is ready to use. Call the `setup`
    /// method to set up the LINE SDK with basic information before you call any other methods or properties
    /// in the LINE SDK.
    public var isSetupFinished: Bool {
        lock.lock()
        defer { lock.unlock() }
        return setup
    }

    /// Checks and returns whether the user was authorized and an access token exists locally. This method
    /// does not check whether the access token has been expired. To verify an access token, use the
    /// `API.Auth.verifyAccessToken` method.
    public var isAuthorized: Bool {
        return AccessTokenStore.shared.current != nil
    }

    /// Checks and returns whether the authorizing process is currently ongoing.
    public var isAuthorizing: Bool {
        return currentProcess != nil
    }
    
    /// A flag to prevent setup multiple times
    var setup = false

    private init() { }

    /// Sets up the current `LoginManager` instance.
    ///
    /// - Parameters:
    ///   - channelID: The channel ID for your app.
    ///   - universalLinkURL: The universal link used to navigate back to your app from LINE.
    /// - Note:
    ///   Call this method before you access any other methods or properties in the LINE SDK. Call this method
    ///   only once because the login manager cannot be set up multiple times.
    ///
    ///   We strongly suggest that you specify a valid universal link URL. Set up your own universal link
    ///   callback for your channel by following the guide on the LINE Developers site. When the callback is set
    ///   properly, LINE will try to bring up your app with the universal link first, which improves the
    ///   security of the authorization flow and protects your data. If the `universalLinkURL` parameter is
    ///   `nil`, only a custom URL scheme will be used to open your app after the authorization in LINE
    ///   is complete.
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
    
    /// Logs in to the LINE Platform.
    ///
    /// - Parameters:
    ///   - permissions: The set of permissions requested by your app. The default value is
    ///                  `[.profile]`.
    ///   - viewController: The the view controller that presents the login view controller. If `nil`, the topmost
    ///                     view controller in the current view controller hierarchy will be used.
    ///   - parameters: The parameters used during the login process. For more information,
    ///                 see `LoginManager.Parameters`.
    ///   - completion: The completion closure to be invoked when the login action is finished.
    /// - Returns: The `LoginProcess` object which indicates that this method has started the login process.
    ///
    /// - Note:
    ///   Only one process can be started at a time. Do not call this method again to start a new login process
    ///   before `completion` is invoked.
    ///
    ///   If the value of `permissions` contains `.profile`, the user profile will be retrieved during the login
    ///   process and contained in the `userProfile` property of the `LoginResult` object in `completion`.
    ///   Otherwise, the `userProfile` property will be `nil`. Use this profile to identify your user. For
    ///   more information, see `UserProfile`.
    ///
    ///   An access token will be issued if the user authorizes your app. This token and a refresh token
    ///   will be automatically stored in the keychain of your app for later use. You do not need to
    ///   refresh the access token manually because any API call will attempt to refresh the access token if
    ///   necessary. However, if you need to refresh the access token manually, use the
    ///   `API.Auth.refreshAccessToken(with:)` method.
    ///
    @discardableResult
    public func login(
        permissions: Set<LoginPermission> = [.profile],
        in viewController: UIViewController? = nil,
        parameters: LoginManager.Parameters = .init(),
        completionHandler completion: @escaping (Result<LoginResult, LineSDKError>) -> Void
    ) -> LoginProcess?
    {
        lock.lock()
        defer { lock.unlock() }

        if !parameters.allowRecreatingLoginProcess && isAuthorizing {
            Log.print("Trying to start another login process while previous process is still valid. " +
            "New login process is ignored. Set `allowRecreatingLoginProcess` in login parameter" +
            "if you want to allow this action.")
            return nil
        }
        
        if parameters.allowRecreatingLoginProcess && isAuthorizing {
            if let process = currentProcess {
                self.currentProcess?.onFail.call(
                    LineSDKError.generalError(reason: .processDiscarded(process))
                )
            } else {
                Log.assertionFailure("Current process couldn't be asserted. This shouldn't happen." +
                    "Please report an issue here: https://github.com/line/line-sdk-ios-swift/issues")
            }
        }

        let process = LoginProcess(
            configuration: LoginConfiguration.shared,
            scopes: permissions,
            parameters: parameters,
            viewController: viewController)
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
            completion(.failure(error.sdkError))
        }

        process.start()
        
        self.currentProcess = process
        return currentProcess
    }

    /// Actions after auth process finishes. We do something like storing token, getting user profile and ID
    /// token verification before we can inform framework users every thing is done.
    ///
    /// - Parameters:
    ///   - token: The access token retrieved from auth server.
    ///   - response: The URL response object created when a login callback URL opened by SDK.
    ///   - process: The related login process initialized by `login` method.
    ///   - completion: The completion closure to be invoked when the whole login process finishes.
    func postLogin(
        token: AccessToken,
        response: LoginProcessURLResponse,
        process: LoginProcess,
        completionHandler completion: @escaping (Result<LoginResult, LineSDKError>) -> Void) {
        
        let group = DispatchGroup()
        
        var profile: UserProfile?

        var providerMetadata: DiscoveryDocument.ResolvedProviderMetadata?

        // Any possible errors will be held here.
        var errors: [Error] = []

        if token.permissions.contains(.profile) {
            // We need to pass token since it is not stored in keychain yet.
            getUserProfile(with: token, in: group) { result in
                do { profile = try result.get() }
                catch { errors.append(error) }
            }
        }

        if token.permissions.contains(.openID) {
            getProviderMetadata(for: token, in: group) { result in
                do { providerMetadata = try result.get() }
                catch { errors.append(error) }
            }
        }

        group.notify(queue: .main) {
            guard errors.isEmpty else {
                let error = errors[0]
                completion(.failure(error.sdkError))
                return
            }
            
            if let providerMetadata = providerMetadata {
                do {
                    try self.verifyIDToken(
                        token.IDToken!,
                        providerMetadata: providerMetadata,
                        process: process,
                        userID: profile?.userID
                    )
                } catch {
                    if let cryptoError = error as? CryptoError {
                        completion(.failure(.authorizeFailed(reason: .cryptoError(error: cryptoError))))
                    } else {
                        completion(.failure(error.sdkError))
                    }
                    return
                }
            }

            // Everything goes fine now. Store token.
            let result = Result {
                try AccessTokenStore.shared.setCurrentToken(token)
            }.map {
                LoginResult.init(
                    accessToken: token,
                    permissions: Set(token.permissions),
                    userProfile: profile,
                    friendshipStatusChanged: response.friendshipStatusChanged,
                    IDTokenNonce: process.IDTokenNonce)
            }
            completion(result)
        }
    }
    
    /// Logs out the current user by revoking the refresh token and all its corresponding access tokens.
    ///
    /// - Parameter completion: The completion closure to be invoked when the logout action is finished.
    public func logout(completionHandler completion: @escaping (Result<(), LineSDKError>) -> Void) {
        API.Auth.revokeRefreshToken(completionHandler: completion)
    }

    /// Asks this `LoginManager` object to handle a URL callback from either LINE or the web login flow.
    ///
    /// - Parameters:
    ///   - app: The singleton app object.
    ///   - url: The URL resource to open. This resource should be the one passed from the iOS system through the
    ///          related method of the `UIApplicationDelegate` protocol.
    ///   - options: A dictionary of the URL handling options passed from the related method of the
    ///              `UIApplicationDelegate` protocol.
    /// - Returns: `true` if `url` has been successfully handled; `false` otherwise.
    /// - Note: This method has the same method signature as in the methods of the `UIApplicationDelegate`
    ///         protocol. Pass all arguments to this method without any modification.
    public func application(
        _ app: UIApplication,
        open url: URL?,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        guard let url = url else { return false }
        guard let currentProcess = currentProcess else { return false }

        return currentProcess.resumeOpenURL(url: url)
    }
    
    // MARK: - Deprecated
    
    /// Sets the preferred language used when logging in with the web authorization flow.
    ///
    /// If not set, the web authentication flow shows the login page in the user's device language, or falls
    /// back to English. Once set, the web page will be displayed in the preferred language.
    ///
    /// - Note:
    ///   This property does not affect the preferred language when LINE is used for authorization.
    ///   LINE and the login screen are always displayed in the user's device language.
    @available(
    *, deprecated,
    message: """
    Set the preferred language in a `LoginManager.Parameters` value and use
    `login(permissions:in:parameters:completionHandler:)` instead.")
    """)
    public var preferredWebPageLanguage: WebPageLanguage? = nil
    
    /// Logs in to the LINE Platform.
    ///
    /// - Parameters:
    ///   - permissions: The set of permissions requested by your app. The default value is
    ///                  `[.profile]`.
    ///   - viewController: The the view controller that presents the login view controller. If `nil`, the topmost
    ///                     view controller in the current view controller hierarchy will be used.
    ///   - options: The options used during the login process. For more information, see `LoginManagerOptions`.
    ///   - completion: The completion closure to be invoked when the login action is finished.
    /// - Returns: The `LoginProcess` object which indicates that this method has started the login process.
    ///
    /// - Note:
    ///   Only one process can be started at a time. Do not call this method again to start a new login process
    ///   before `completion` is invoked.
    ///
    ///   If the value of `permissions` is `.profile`, the user profile will be retrieved during the login
    ///   process and contained in the `userProfile` property of the `LoginResult` object in `completion`.
    ///   Otherwise, the `userProfile` property will be `nil`. Use this profile to identify your user. For
    ///   more information, see `UserProfile`.
    ///
    ///   An access token will be issued if the user authorizes your app. This token and a refresh token
    ///   will be automatically stored in the keychain of your app for later use. You do not need to
    ///   refresh the access token manually because any API call will attempt to refresh the access token if
    ///   necessary. However, if you need to refresh the access token manually, use the
    ///   `API.Auth.refreshAccessToken(with:)` method.
    ///
    @available(
    *, deprecated,
    message: """
    Convert the `options` to a `LoginManager.Parameters` value and
    use `login(permissions:in:parameters:completionHandler:)` instead.")
    """)
    @discardableResult
    public func login(
        permissions: Set<LoginPermission> = [.profile],
        in viewController: UIViewController? = nil,
        options: LoginManagerOptions,
        completionHandler completion: @escaping (Result<LoginResult, LineSDKError>) -> Void) -> LoginProcess?
    {
        let parameters = Parameters(options: options, language: preferredWebPageLanguage)
        return login(
            permissions: permissions,
            in: viewController,
            parameters: parameters,
            completionHandler: completion
        )
    }
}

extension LoginManager {
    func getUserProfile(
        with token: AccessToken,
        in group: DispatchGroup,
        handler: @escaping (Result<UserProfile, LineSDKError>) -> Void)
    {
        group.enter()

        Session.shared.send(GetUserProfileRequestInjectedToken(token: token.value)) { profileResult in
            handler(profileResult)
            group.leave()
        }
    }
    
    func getProviderMetadata(
        for token: AccessToken,
        in group: DispatchGroup,
        handler: @escaping (Result<DiscoveryDocument.ResolvedProviderMetadata, LineSDKError>) -> Void)
    {
        group.enter()
        // We need a valid ID Token existing to continue.
        guard let IDToken = token.IDToken else {
            handler(.failure(LineSDKError.authorizeFailed(reason: .lackOfIDToken(raw: token.IDTokenRaw))))
            group.leave()
            return
        }
        // We need a supported verify algorithm to continue
        let algorithm = IDToken.header.algorithm
        guard let _ = JWA.Algorithm(rawValue: algorithm) else {
            let unsupportedError = CryptoError.JWTFailed(reason: .unsupportedHeaderAlgorithm(name: algorithm))
            handler(.failure(LineSDKError.authorizeFailed(reason: .cryptoError(error: unsupportedError))))
            group.leave()
            return
        }

        // Use Discovery Document to find JWKs URI. How about introducing some promise mechanism
        Session.shared.send(GetDiscoveryDocumentRequest()) { documentResult in
            switch documentResult {
            case .success(let document):
                let jwkSetURL = document.jwksURI
                Session.shared.send(GetJWKSetRequest(url: jwkSetURL)) { jwkSetResult in
                    switch jwkSetResult {
                    case .success(let jwkSet):
                        guard let keyID = IDToken.header.keyID, let key = jwkSet.getKeyByID(keyID) else {
                            handler(.failure(LineSDKError.authorizeFailed(
                                reason: .JWTPublicKeyNotFound(keyID: IDToken.header.keyID))))
                            group.leave()
                            return
                        }
                        handler(
                            .success(DiscoveryDocument.ResolvedProviderMetadata(issuer: document.issuer, jwk: key))
                        )
                        group.leave()
                    case .failure(let err):
                        handler(.failure(err))
                        group.leave()
                    }
                }
            case .failure(let err):
                handler(.failure(err))
                group.leave()
            }
        }
    }

    func verifyIDToken(
        _ token: JWT,
        providerMetadata: DiscoveryDocument.ResolvedProviderMetadata,
        process: LoginProcess, userID: String?) throws
    {

        try token.verify(with: providerMetadata.jwk)
        
        let payload = token.payload
        try payload.verify(keyPath: \.issuer, expected: providerMetadata.issuer)
        
        if let userID = userID {
            try payload.verify(keyPath: \.subject, expected: userID)
        }
        try payload.verify(keyPath: \.audience, expected: process.configuration.channelID)

        let now = Date()
        let allowedClockSkew: TimeInterval = 5 * 60
        try payload.verify(keyPath: \.expiration, laterThan: now.addingTimeInterval(-allowedClockSkew))
        try payload.verify(keyPath: \.issueAt, earlierThan: now.addingTimeInterval(allowedClockSkew))
        try payload.verify(keyPath: \.nonce, expected: process.IDTokenNonce!)
    }
}
