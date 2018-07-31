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
    static let LineSDKAccessTokenDidUpdate = Notification.Name("com.linecorp.linesdk.AccessTokenDidUpdate")
}

public let LineSDKOldAccessTokenUserInfoKey = "oldToken"
public let LineSDKNewAccessTokenUserInfoKey = "newToken"

class AccessTokenStore: LazySingleton {
    
    // In case we might do migration later on the token,
    // we need a way to identifier the token store version.
    enum Version {
        case auth2_1(JSONEncoder, JSONDecoder)
        
        var value: String {
            switch self {
            case .auth2_1: return "auth2.1"
            }
        }
        
        var encoder: JSONEncoder {
            switch self {
            case .auth2_1(let encoder, _): return encoder
            }
        }
        
        var decoder: JSONDecoder {
            switch self {
            case .auth2_1(_, let decoder): return decoder
            }
        }
        
        var tokenType: AccessTokenType.Type {
            switch self {
            case .auth2_1: return AccessToken.self
            }
        }
    }
    
    enum Coder {
        static let encoderAuth2_1 = JSONEncoder()
        static let decoderAuth2_1 = JSONDecoder()
    }
    
    static var _shared: AccessTokenStore?
    
    let configuration: LoginConfiguration
    let keychainStore: KeychainStore
    
    let storeVersion: Version = .auth2_1(Coder.encoderAuth2_1, Coder.decoderAuth2_1)
    
    init(configuration: LoginConfiguration) {
        self.configuration = configuration
        
        let keychainService = "com.linecorp.linesdk.tokenstore.\(Bundle.main.bundleIdentifier ?? "")"
        let keychainStore = KeychainStore(service: keychainService)
        self.keychainStore = keychainStore
        do {
            current = try keychainStore.token(for: configuration, version: storeVersion)
        } catch {
            Log.print("Error happened during loading token from token store: \(error)")
            Log.print("LineSDK recovered from it but your user might need another authorization to Line SDK.")
        }
    }
    
    private(set) var current: AccessToken?
    
    func setCurrentToken(_ token: AccessToken) throws {
        guard current != token else { return }
        
        try keychainStore.set(token, configuration: configuration, version: storeVersion)
        
        var userInfo = [LineSDKNewAccessTokenUserInfoKey: token]
        if let old = current {
            userInfo[LineSDKOldAccessTokenUserInfoKey] = old
        }
        current = token
        NotificationCenter.default.post(name: .LineSDKAccessTokenDidUpdate, object: token, userInfo: userInfo)
    }
    
    func removeCurrentAccessToken() throws {
        let key = keychainStore.tokenKey(for: configuration, version: storeVersion)
        try keychainStore.remove(key)
    }
}

extension KeychainStore {
    
    func tokenKey(for configuration: LoginConfiguration, version: AccessTokenStore.Version) -> String {
        return "\(configuration.channelID)@\(version.value)"
    }
    
    func set(_ token: AccessToken, configuration: LoginConfiguration, version: AccessTokenStore.Version) throws {
        let key = tokenKey(for: configuration, version: version)
        try set(token, for: key, using: version.encoder)
    }
    
    func token(for configuration: LoginConfiguration, version: AccessTokenStore.Version) throws -> AccessToken? {
        let key = tokenKey(for: configuration, version: version)
        return try value(for: key, using: version.decoder)
    }
}
