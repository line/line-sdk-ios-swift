//
//  CryptoKey.swift
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

/// Represents a general key in crypto domain.
/// Basically it is a wrapper of a native `SecKey`. All keys should be created by some DER raw data, but they could
/// have its own clustered implementation.
protocol CryptoKey {
    var key: SecKey { get }
    init(key: SecKey)
    init(der data: Data) throws
}

protocol CryptoPublicKey: CryptoKey {}

protocol CryptoPrivateKey: CryptoKey {}

extension CryptoKey {
    /// Creates a key with a base64-encoded string representing DER data.
    ///
    /// - Parameter base64Encoded: Base64-encoded DER data.
    /// - Throws: Any possible error while creating the key.
    init(base64Encoded string: String) throws {
        guard let data = Data(base64Encoded: string, options: .ignoreUnknownCharacters) else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: string))
        }
        try self.init(der: data)
    }
    
    /// Creates a key with a given PEM encoded string.
    ///
    /// - Parameter string: The PEM encoded string.
    /// - Throws: Any possible error while creating the key.
    init(pem string: String) throws {
        let base64String = try string.markerStrippedBase64()
        try self.init(base64Encoded: base64String)
    }
}

// MARK: - RSA Keys
extension Crypto {
    
    /// Represents an RSA public key. This key should follow PKCS #1 specifications and with ASN.1 encoded.
    // RFC8017 & RFC3447
    struct RSAPublicKey: CryptoPublicKey {
        let key: SecKey
        init(key: SecKey) { self.key = key }
        
        /// Creates a public key with DER data.
        ///
        /// - Parameter data: The DER data from which to create the public key.
        /// - Throws: Any possible error while creating the key.
        init(der data: Data) throws {
            let keyData = try data.x509HeaderStrippedForRSA()
            self.key = try SecKey.createKey(derData: keyData, keyClass: .publicKey, keyType: .rsa)
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
    
    /// Represents an RSA private key.
    struct RSAPrivateKey: CryptoPrivateKey {
        let key: SecKey
        init(key: SecKey) { self.key = key }
        
        /// Creates a private key with DER data.
        ///
        /// - Parameter data: The DER data from which to create the private key.
        /// - Throws: Any possible error while creating the key.
        init(der data: Data) throws {
            let keyData = try data.x509HeaderStrippedForRSA()
            self.key = try SecKey.createKey(derData: keyData, keyClass: .privateKey, keyType: .rsa)
        }
    }
}

// MARK: - ECDSA Keys
// Now only public key support is provided (since we only use public keys to verify a signature).
extension Crypto {
    
    /// Represents an ECDSA public key. The raw data of this key should follow X9.62 for EC parameters encoding or
    /// it should be just a plain key with uncompressed indication. Compressed EC key is not supported yet.
    // RFC5480 https://tools.ietf.org/html/rfc5480
    struct ECDSAPublicKey: CryptoPublicKey {
        let key: SecKey
        init(key: SecKey) { self.key = key }
        
        init(der data: Data) throws {
            let keyData = try data.x509HeaderStrippedForEC()
            self.key = try SecKey.createKey(derData: keyData, keyClass: .publicKey, keyType: .ec)
        }
    }
}

// MARK: - JWK Related Methods
extension JWK {
    
    /// Helps for converting this `JWK` to a `CryptoPublicKey`.
    ///
    /// - Returns: The converted crypto public key, if succeeded.
    /// - Throws: Any possible error while converting the key.
    func getPublicKey() throws -> CryptoPublicKey {
        let data = try getKeyData()
        switch keyType {
        case .rsa: return try Crypto.RSAPublicKey(der: data)
        case .ec: return try Crypto.ECDSAPublicKey(der: data)
        }
    }
}
