//
//  RSAKey.swift
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
import CommonCrypto

protocol RSAKey {
    var key: SecKey { get }
    init(key: SecKey)
    init(der data: Data) throws
}

extension RSAKey {
    /// Creates a public key with a base64-encoded string representing DER data.
    ///
    /// - Parameter base64Encoded: Base64-encoded DER data.
    /// - Throws: Any possible error while creating the key.
    init(base64Encoded string: String) throws {
        guard let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters) else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: string))
        }
        try self.init(der: data)
    }
    
    /// Creates a public key with a given PEM encoded string.
    ///
    /// - Parameter string: The PEM encoded string.
    /// - Throws: Any possible error while creating the key.
    init(pem string: String) throws {
        let base64String = try string.markerStrippedBase64()
        try self.init(base64Encoded: base64String)
    }
}

extension RSA {
    
    struct PublicKey: RSAKey {
        let key: SecKey
        init(key: SecKey) { self.key = key }
        
        /// Creates a public key with DER data.
        ///
        /// - Parameter data: The DER data from which to create the public key.
        /// - Throws: Any possible error while creating the key.
        init(der data: Data) throws {
            let keyData = try data.x509HeaserStripped()
            self.key = try SecKey.createKey(derData: keyData, keyClass: .publicKey)
        }
        
        /// Creates a public key from a certificate data.
        ///
        /// - Parameter data: `Data` represents the certificate.
        /// - Throws: Any possible error while creating the key.
        init(certificate data: Data) throws {
            guard let string = String(data: data, encoding: .utf8) else {
                throw CryptoError.generalError(reason: .dataConversionFailed(data: data, encoding: .utf8))
            }
            
            let certString = try string.markerStrippedBase64()
            let base64Data = Data(base64Encoded: certString)!
            self.key = try SecKey.createPublicKey(certificateData: base64Data)
        }
    }
    
    struct PrivateKey: RSAKey {
        let key: SecKey
        init(key: SecKey) { self.key = key }
        
        /// Creates a private key with DER data.
        ///
        /// - Parameter data: The DER data from which to create the private key.
        /// - Throws: Any possible error while creating the key.
        init(der data: Data) throws {
            let keyData = try data.x509HeaserStripped()
            self.key = try SecKey.createKey(derData: keyData, keyClass: .privateKey)
        }
    }
}

extension RSA.PublicKey {
    init(_ key: JWK) throws {
        let data = try key.getKeyData()
        try self.init(der: data)
    }
}

// This should be in the same file with JWTSignKey protocol definition.
// See https://bugs.swift.org/browse/SR-631 & https://github.com/apple/swift/pull/18168
extension RSA.PublicKey: JWTSignKey {
    var RSAKey: RSA.PublicKey? {
        return self
    }
}
