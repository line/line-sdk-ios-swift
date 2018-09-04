//
//  RSA.swift
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

/// Namespace for RSA related things.
struct RSA {}

/// Define a data type under RSA domain. All RSA data types just behave as a container for raw data, but with
/// different operation.
protocol RSAData: Equatable {
    var raw: Data { get }
    init(raw: Data)
    func digest(using algorithm: RSA.Algorithm) throws -> Data
}


// Some convenience methods.
extension RSAData {
    init(base64Encoded string: String) throws {
        guard let data = Data(base64Encoded: string) else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: string))
        }
        self.init(raw: data)
    }

    func digest(using algorithm: RSA.Algorithm) throws -> Data {
        return try raw.digest(using: algorithm)
    }
}

/// Data Types of RSA related domain.
extension RSA {
    /// Represents unencrypted data. The plain data could be encrypted or signed.
    struct PlainData: RSAData {
        let raw: Data
        
        init(raw: Data) { self.raw = raw }
        
        init(string: String, encoding: String.Encoding = .utf8) throws {
            guard let data = string.data(using: encoding) else {
                throw CryptoError.generalError(reason: .stringConversionFailed(String: string, encoding: encoding))
            }
            self.init(raw: data)
        }
        
        /// Encrypts the current plain data with an RSA public key, using a given algorithm.
        ///
        /// - Parameters:
        ///   - key: The public key used to encrypt data.
        ///   - algorithm: The digest algorithm used to encrypt data with `key`.
        /// - Returns: The encrypted data representation.
        /// - Throws: A `CryptoError` if something wrong happens.
        func encrypted(with key: PublicKey, using algorithm: RSA.Algorithm) throws -> EncryptedData {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCreateEncryptedData(
                key.key, algorithm.encryptionAlgorithm, raw as CFData, &error) else
            {
                throw CryptoError.RSAFailed(reason: .encryptingError(reason: "\(String(describing: error))"))
            }
            
            return EncryptedData(raw: data as Data)
        }
        
        /// Signs the current plain data with an RSA private key, using a given algorithm.
        ///
        /// - Parameters:
        ///   - key: The private key used to sign data.
        ///   - algorithm: The digest algorithm used to sign data with `key`.
        /// - Returns: The signed data representation.
        /// - Throws: A `CryptoError` if something wrong happens.
        func signed(with key: PrivateKey, algorithm: RSA.Algorithm) throws -> SignedData {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCreateSignature(
                key.key, algorithm.signatureAlgorithm, raw as CFData, &error) else
            {
                throw CryptoError.RSAFailed(reason: .signingError(reason: "\(String(describing: error))"))
            }
            
            return SignedData(raw: data as Data)
        }
        
        /// Verifies the current plain data with an RSA public key and related signature, using a given algorithm.
        ///
        /// - Parameters:
        ///   - key: The public key used to encrypt data.
        ///   - signature: The signed data created when signing the plain data with paired private key.
        ///   - algorithm:
        /// - Returns: The digest algorithm used to verify data with `key`.
        /// - Throws: A `CryptoError` if something wrong happens.
        func verify(with key: PublicKey, signature: SignedData, algorithm: RSA.Algorithm) throws -> Bool {
            var error: Unmanaged<CFError>?
            let result = SecKeyVerifySignature(
                key.key, algorithm.signatureAlgorithm, raw as CFData, signature.raw as CFData, &error)
            
            guard error == nil else {
                throw CryptoError.RSAFailed(reason: .verifyingError(reason: "\(String(describing: error))"))
            }
            
            return result
        }
    }
    
    /// Represents encrypted data. The encrypted data could be decrypted.
    struct EncryptedData: RSAData {
        let raw: Data
        
        /// Decrypts the current encrypted data with an RSA private key, using a given algorithm.
        ///
        /// - Parameters:
        ///   - key: The private key used to decrypt data.
        ///   - algorithm: The digest algorithm used to decrypt data with `key`.
        /// - Returns: The plain data representation.
        /// - Throws: A `CryptoError` if something wrong happens.
        func decrypted(with key: PrivateKey, using algorithm: RSA.Algorithm) throws -> PlainData {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCreateDecryptedData(
                key.key, algorithm.encryptionAlgorithm, raw as CFData, &error) else
            {
                throw CryptoError.RSAFailed(reason: .decryptingError(reason: "\(String(describing: error))"))
            }
            
            return PlainData(raw: data as Data)
        }
    }
    
    struct SignedData: RSAData {
        let raw: Data
    }
}
