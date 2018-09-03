//
//  KeychainStore.swift
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

private let kMatchLimit = String(kSecMatchLimit)
private let kReturnData = String(kSecReturnData)
private let kAttributeAccount = String(kSecAttrAccount)
private let kClass = String(kSecClass)
private let kValueData = String(kSecValueData)
private let kAttributeAccessible = String(kSecAttrAccessible)
private let kAttributeService = String(kSecAttrService)
private let kAttributeSynchronizable = String(kSecAttrSynchronizable)

/// KeychainStore is a simple wrapper of Keychain with type safe behavior.
/// It does not provide full set of functionality of keychain access now.
/// Only features used in LINE SDK are added.
struct KeychainStore {
    struct Options {
        enum ItemClass {
            case genericPassword
            
            var value: String {
                switch self {
                case .genericPassword:
                    return String(kSecClassGenericPassword)
                }
            }
        }
        
        enum Accessibility {
            case afterFirstUnlockThisDeviceOnly
            var value: String {
                switch self {
                case .afterFirstUnlockThisDeviceOnly:
                    return String(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
                }
            }
        }
        
        var query: [String: Any] {
            var result = [String: Any]()
            result[kClass] = itemClass.value
            result[kAttributeSynchronizable] = kSecAttrSynchronizableAny
            result[kAttributeService] = service
            return result
        }
        
        func attributes(for key: String?, value: Data) -> [String: Any] {
            var result: [String: Any]
            if let key = key {
                result = query
                result[kAttributeAccount] = key
            } else {
                result = [:]
            }
            
            result[kValueData] = value
            result[kAttributeAccessible] = accessibility.value
            result[kAttributeSynchronizable] = kCFBooleanFalse
            return result
        }
        
        let itemClass: ItemClass = .genericPassword
        let accessibility: Accessibility = .afterFirstUnlockThisDeviceOnly
        let service: String
    }
    
    let options: Options
    init(service: String) {
        options = Options(service: service)
    }
}

extension KeychainStore {
    func contains(_ key: String) throws -> Bool {
        var query = options.query
        query[kAttributeAccount] = key
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw keychainError(status)
        }
    }
}

/// Keychain Setter
extension KeychainStore {
    func set<T: Encodable>(_ value: T, for key: String, using encoder: JSONEncoder) throws {
        let data = try encoder.encode(value)
        try set(data, for: key)
    }
    
    func set(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else {
            throw LineSDKError.generalError(reason: .conversionError(string: string, encoding: .utf8))
        }
        try set(data, for: key)
    }
    
    func set(_ data: Data, for key: String) throws {
        var query = options.query
        query[kAttributeAccount] = key

        let attributes = options.attributes(for: nil, value: data)
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        switch status {
        case errSecSuccess:
            break
        case errSecItemNotFound:
            let a = options.attributes(for: key, value: data)
            let status = SecItemAdd(a as CFDictionary, nil)
            if status != errSecSuccess {
                throw keychainError(status)
            }
        default: throw keychainError(status)
        }
    }
    
    func remove(_ key: String) throws {
        let query = options.query
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw keychainError(status)
        }
    }
    
    func removeAll() throws {
        let query = options.query
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw keychainError(status)
        }
    }
    
    func keychainError(_ status: OSStatus) -> LineSDKError {
        return .authorizeFailed(reason: .keychainOperation(status: status))
    }
}

/// Keychain Getter
extension KeychainStore {
    func value<T: Decodable>(for key: String, using decoder: JSONDecoder) throws -> T? {
        guard let value = try data(for: key) else {
            return nil
        }
        return try decoder.decode(T.self, from: value)
    }
    
    func data(for key: String) throws -> Data? {
        var query = options.query
        query[kAttributeAccount] = key
        query[kMatchLimit] = kSecMatchLimitOne
        query[kReturnData] = kCFBooleanTrue
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        switch status {
        case errSecSuccess:
            guard let data = result as? Data else {
                throw LineSDKError.authorizeFailed(reason: .invalidDataInKeychain)
            }
            return data
        case errSecItemNotFound: return nil
        default: throw keychainError(status)
        }
    }
    
    func string(for key: String) throws -> String? {
        guard let data = try data(for: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
