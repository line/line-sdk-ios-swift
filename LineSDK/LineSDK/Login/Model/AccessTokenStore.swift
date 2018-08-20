//
//  AccessTokenStore.swift
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

extension Notification.Name {
    /// Sent when LineSDK detected current token gets updated and stored to keychain. It means a user authorized
    /// your app and an access token was obtained without problem. The `object` of posted `Notification` is the
    /// new token. `userInfo` dictionary of the posted `Notification` contains the new token under
    /// `LineSDKNotificationKey.newAccessToken` key. If the old token existed, it will be under the
    /// `LineSDKNotificationKey.oldAccessToken` key.
    public static let LineSDKAccessTokenDidUpdate = Notification.Name("com.linecorp.linesdk.AccessTokenDidUpdate")
    
    /// Sent when LineSDK removed current token from keychain. This normally happens when you logout a user or invoke
    /// `revokeToken` API. Expired token will not be removed automatically since it could be refreshed when
    /// used to access an API. The `object` of the posted `Notification` is the token just removed.
    public static let LineSDKAccessTokenDidRemove = Notification.Name("com.linecorp.linesdk.AccessTokenDidRemove")
}

extension LineSDKNotificationKey {
    
    /// User info key for old access token value.
    public static let oldAccessToken = "oldAccessToken"
    
    /// User info key for new access token value.
    public static let newAccessToken = "newAccessToken"
}

/// Represents the storage of `AccessToken`.
public class AccessTokenStore {
    
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
    
    static var _shared: AccessTokenStore?
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
    }
    
    /// The `AccessToken` in use currently.
    public private(set) var current: AccessToken?
    
    func setCurrentToken(_ token: AccessToken) throws {
        guard current != token else { return }
        
        try keychainStore.set(token, configuration: configuration, version: storeVersion)
        
        var userInfo = [LineSDKNotificationKey.newAccessToken: token]
        if let old = current {
            userInfo[LineSDKNotificationKey.oldAccessToken] = old
        }
        current = token
        
        NotificationCenter.default.post(name: .LineSDKAccessTokenDidUpdate, object: token, userInfo: userInfo)
    }
    
    func removeCurrentAccessToken() throws {
        let key = storeVersion.tokenKey(for: configuration)
        if try keychainStore.contains(key) {
            try keychainStore.remove(key)
            
            // TODO: We need to consider the location of setting `nil` carefully.
            // In normal case if keychainStore works well, everything should be fine.
            // But what will happen if revoke request succeeded, then keychain operation fails?
            // Do we want to keep `current` token or should be put it outside the if statement
            // and always reset it?
            let token = current
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
