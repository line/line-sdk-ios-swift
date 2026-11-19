//
//  AccessTokenStore.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

extension Notification.Name {
    /// Sent when the LINE SDK detects that the current token has been updated. This means that the user has
    /// authorized your app and your app has obtained an access token. Normally, the new token is also stored
    /// in the keychain. If the keychain is temporarily unavailable, the token is kept in memory and the SDK
    /// stores it to the keychain later when the app becomes active or protected data becomes available. The
    /// `object` property of the posted `Notification` object contains the new access token. The `userInfo`
    /// dictionary of the posted `Notification` object contains the new access token under the
    /// `LineSDKNotificationKey.newAccessToken` key. If an access token has previously existed, it will be under
    /// the `LineSDKNotificationKey.oldAccessToken` key.
    public static let LineSDKAccessTokenDidUpdate = Notification.Name("com.linecorp.linesdk.AccessTokenDidUpdate")
    
    /// Sent when the LINE SDK removes the current access token from the keychain. This normally happens
    /// when you log out the user or call the `revokeToken` method. An expired access token is not
    /// automatically removed since the access token is refreshed when it is used to make an API call.
    /// The `object` property of the posted `Notification` object contains the removed access token.
    public static let LineSDKAccessTokenDidRemove = Notification.Name("com.linecorp.linesdk.AccessTokenDidRemove")

    /// Sent when the LINE SDK fails to store the current access token to the keychain. This can happen when
    /// the keychain is temporarily unavailable (for example, `errSecNotAvailable`). The token is kept in
    /// memory and keeps working for the current session, and the SDK retries the storing when the app
    /// becomes active or protected data becomes available; this notification is sent again if a retry fails.
    /// The `object` property of the posted `Notification` object contains the access token which failed to
    /// be stored. The `userInfo` dictionary contains the underlying error under the
    /// `LineSDKNotificationKey.persistingError` key. Observe this notification if you want to log or report
    /// such failures.
    public static let LineSDKAccessTokenDidFailToPersist =
        Notification.Name("com.linecorp.linesdk.AccessTokenDidFailToPersist")
}

extension LineSDKNotificationKey {
    
    /// A user information key for an old access token value.
    public static let oldAccessToken = "oldAccessToken"

    /// A user information key for a new access token value.
    public static let newAccessToken = "newAccessToken"

    /// A user information key for the error which caused an access token persisting failure.
    public static let persistingError = "persistingError"
}

/// Represents the storage of an `AccessToken` object.
final public class AccessTokenStore: @unchecked Sendable {

    // In case we might do migration later on the token,
    // we need a way to identifier the token store version.
    
    /// All possible versions of current store. This could be used to make old token migration process smoother
    /// when major breaking release happens.
    enum Version {
        case auth2_1(JSONEncoder, JSONDecoder)
        
        /// A string representation of version.
        var value: String {
            switch self {
            case .auth2_1: return "auth2.1"
            }
        }
        
        /// Encoder used to encode token to data, which will be store in keychain.
        var encoder: JSONEncoder {
            switch self {
            case .auth2_1(let encoder, _): return encoder
            }
        }
        
        /// Decoder to decode keychain data to token.
        var decoder: JSONDecoder {
            switch self {
            case .auth2_1(_, let decoder): return decoder
            }
        }
        
        /// The type of corresponding `AccessToken`. It might vary with access token version bumping up.
        var tokenType: AccessTokenType.Type {
            switch self {
            case .auth2_1: return AccessToken.self
            }
        }
        
        /// Keychain service name of the token version.
        var keychainService: String {
            switch self {
            case .auth2_1:
                return "com.linecorp.linesdk.tokenstore.\(Bundle.main.bundleIdentifier ?? "")"
            }
        }
        
        /// Key for storing the token.
        func tokenKey(for configuration: LoginConfiguration) -> String {
            switch self {
            case .auth2_1:
                return "\(configuration.channelID)@\(value)"
            }
        }
    }
    
    enum Coder {
        static let encoderAuth2_1 = JSONEncoder()
        static let decoderAuth2_1 = JSONDecoder()
    }

    // This internal state is ensured safe by the lock in login manager.
    nonisolated(unsafe) static var _shared: AccessTokenStore?
    
    /// The shared instance of `AccessTokenStore`. Use this instance to access values in the token store of LINE SDK.
    /// Access this value after you setup the LINE SDK. Otherwise, your app will be trapped.
    public static var shared: AccessTokenStore {
        return guardSharedProperty(_shared)
    }
    
    let configuration: LoginConfiguration
    let keychainStore: KeychainStore
    
    let storeVersion: Version = .auth2_1(Coder.encoderAuth2_1, Coder.decoderAuth2_1)
    
    init(configuration: LoginConfiguration) {
        self.configuration = configuration

        let keychainStore = KeychainStore(service: storeVersion.keychainService)
        self.keychainStore = keychainStore
        do {
            current = try keychainStore.token(for: configuration, version: storeVersion)
        } catch {
            Log.print("Error happened during loading token from token store: \(error)")
            Log.print("LineSDK recovered from it but your user might need another authorization to Line SDK.")
        }
        setupTokenPersistenceRetryObservers()
    }

    deinit {
        lifecycleObservers.forEach(NotificationCenter.default.removeObserver)
    }

    private let lock = NSLock()

    /// The `AccessToken` object currently in use.
    private(set) var _current: AccessToken?
    public var current: AccessToken? {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _current
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _current = newValue
        }
    }

    // Whether the `current` token failed to be stored to the keychain and is waiting for another
    // persistence attempt. Guarded by `lock`.
    private var _tokenPersistencePending = false
    var isTokenPersistencePending: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _tokenPersistencePending
    }

    private var lifecycleObservers: [NSObjectProtocol] = []

    // Executes a pending-persistence retry, off the main thread by default since keychain calls can
    // block when securityd is unresponsive. Tests replace this to run retries synchronously.
    var persistenceRetryExecutor: (@escaping @Sendable () -> Void) -> Void = { work in
        DispatchQueue.global(qos: .utility).async(execute: work)
    }

    func setCurrentToken(_ token: AccessToken) {
        guard current != token else { return }

        lock.lock()
        var persistenceError: Error?
        do {
            try keychainStore.set(token, configuration: configuration, version: storeVersion)
            _tokenPersistencePending = false
        } catch {
            // The keychain can be temporarily unavailable (typically `errSecNotAvailable` when securityd is
            // unreachable). Keep the token in memory so the current session continues with the new token and
            // the consumed refresh token is not sent again. The keychain writing will be retried later.
            _tokenPersistencePending = true
            persistenceError = error
        }

        var userInfo = [LineSDKNotificationKey.newAccessToken: token]
        if let old = _current {
            userInfo[LineSDKNotificationKey.oldAccessToken] = old
        }
        _current = token
        lock.unlock()

        NotificationCenter.default.post(name: .LineSDKAccessTokenDidUpdate, object: token, userInfo: userInfo)
        if let error = persistenceError {
            logTokenPersistenceFailure(error)
            NotificationCenter.default.post(
                name: .LineSDKAccessTokenDidFailToPersist,
                object: token,
                userInfo: [LineSDKNotificationKey.persistingError: error]
            )
        }
    }

    // Retries to store the in-memory token when a previous keychain writing failed.
    func retryPendingTokenPersistence() {
        lock.lock()
        guard _tokenPersistencePending, let token = _current else {
            lock.unlock()
            return
        }
        var persistenceError: Error?
        do {
            try keychainStore.set(token, configuration: configuration, version: storeVersion)
            _tokenPersistencePending = false
        } catch {
            // Keychain is still unavailable. Keep the pending state and wait for the next chance.
            persistenceError = error
        }
        lock.unlock()

        if let error = persistenceError {
            Log.print("Retrying token persistence failed again: \(error)")
            NotificationCenter.default.post(
                name: .LineSDKAccessTokenDidFailToPersist,
                object: token,
                userInfo: [LineSDKNotificationKey.persistingError: error]
            )
        } else {
            Log.print("The pending access token is now stored to keychain successfully.")
        }
    }

    private func setupTokenPersistenceRetryObservers() {
        let names: [Notification.Name] = [
            UIApplication.didBecomeActiveNotification,
            UIApplication.protectedDataDidBecomeAvailableNotification
        ]
        lifecycleObservers = names.map { name in
            NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { [weak self] _ in
                guard let self = self, self.isTokenPersistencePending else { return }
                self.persistenceRetryExecutor {
                    self.retryPendingTokenPersistence()
                }
            }
        }
    }

    private func logTokenPersistenceFailure(_ error: Error) {
        Task { @MainActor in
            let application = UIApplication.shared
            let state: String
            switch application.applicationState {
            case .active: state = "active"
            case .inactive: state = "inactive"
            case .background: state = "background"
            @unknown default: state = "unknown"
            }
            Log.print(
                "Writing token to keychain failed: \(error). The token is kept in memory and LineSDK will " +
                "retry the writing when the app becomes active or protected data becomes available. " +
                "(applicationState: \(state), " +
                "isProtectedDataAvailable: \(application.isProtectedDataAvailable))"
            )
        }
    }

    func removeCurrentAccessToken() throws {
        lock.lock()
        _tokenPersistencePending = false
        lock.unlock()

        let key = storeVersion.tokenKey(for: configuration)
        if try keychainStore.contains(key) {
            try keychainStore.remove(key)
        }

        // TODO: We need to consider the location of setting `nil` carefully.
        // In normal case if keychainStore works well, everything should be fine.
        // But what will happen if revoke request succeeded, then keychain operation fails?
        // Now `current` is kept in that case since the throws above skip the code below.
        //
        // The in-memory token needs to be cleared even when the keychain does not contain
        // the key. A pending token which failed to be stored only exists in memory.
        if let token = current {
            current = nil
            NotificationCenter.default.post(name: .LineSDKAccessTokenDidRemove, object: token, userInfo: nil)
        }
    }
}

extension KeychainStore {
    func set(_ token: AccessToken, configuration: LoginConfiguration, version: AccessTokenStore.Version) throws {
        let key = version.tokenKey(for: configuration)
        try set(token, for: key, using: version.encoder)
    }
    
    func token(for configuration: LoginConfiguration, version: AccessTokenStore.Version) throws -> AccessToken? {
        let key = version.tokenKey(for: configuration)
        return try value(for: key, using: version.decoder)
    }
}
