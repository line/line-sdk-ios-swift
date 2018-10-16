//
//  CryptoData.swift
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

/// Defines a data type under crypto domain. All data types just behave as a container for raw data, but with
/// different operation.
protocol CryptoData: Equatable {
    var raw: Data { get }
    init(raw: Data)
    func digest(using algorithm: CryptoAlgorithm) throws -> Data
}

extension CryptoData {
    
    /// Creates a data object in crypto domian for operation from a base64 string.
    ///
    /// - Parameter string: The raw data in base64 encoding.
    /// - Throws: A `CryptoError` if something wrong happens.
    init(base64Encoded string: String) throws {
        guard let data = Data(base64Encoded: string) else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: string))
        }
        self.init(raw: data)
    }
    
    /// Calculates the digest for current data under a given algorithm.
    ///
    /// - Parameter algorithm: The crypto algorithm used to calculate the data digest.
    /// - Returns: The `Data` represents the digest of `self`.
    func digest(using algorithm: CryptoAlgorithm) -> Data {
        return raw.digest(using: algorithm)
    }
}

struct Crypto {}
/// Data Types of Crypto related domain.
extension Crypto {
    /// Represents unencrypted data. The plain data could be encrypted or signed.
    struct PlainData: CryptoData {
        let raw: Data
        
        init(raw: Data) { self.raw = raw }
        
        init(string: String, encoding: String.Encoding = .utf8) throws {
            guard let data = string.data(using: encoding) else {
                throw CryptoError.generalError(reason: .stringConversionFailed(string: string, encoding: encoding))
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
        func encrypted(with key: CryptoPublicKey, using algorithm: CryptoAlgorithm) throws -> EncryptedData {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCreateEncryptedData(
                key.key, algorithm.encryptionAlgorithm, raw as CFData, &error) else
            {
                throw CryptoError.algorithmsFailed(reason: .encryptingError(error?.takeRetainedValue()))
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
        func signed(with key: CryptoPrivateKey, algorithm: CryptoAlgorithm) throws -> SignedData {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCreateSignature(
                key.key, algorithm.signatureAlgorithm, raw as CFData, &error) else
            {
                throw CryptoError.algorithmsFailed(reason: .signingError(error?.takeRetainedValue()))
            }
            
            return SignedData(raw: data as Data)
        }
        
        /// Verifies the current plain data with an RSA public key and related signature, using a given algorithm.
        ///
        /// - Parameters:
        ///   - key: The public key used to encrypt data.
        ///   - signature: The signed data created when signing the plain data with paired private key.
        ///   - algorithm: The digest algorithm used to verify data with `key`.
        /// - Returns: The digest algorithm used to verify data with `key`.
        /// - Throws: A `CryptoError` if something wrong happens.
        func verify(with key: CryptoPublicKey, signature: SignedData, algorithm: CryptoAlgorithm) throws -> Bool {
            
            // EC algorithm does not work when using iOS 10 SecKeyVerifySignature and related SecKeyAlgorithm.
            // Maybe it is due to https://forums.developer.apple.com/thread/83136 (ECDSA signature generated by OpenSSL)
            // or https://forums.developer.apple.com/thread/89619
            //
            // .ecdsaSignatureMessageX962SHA256 requires DER x96.2 encoded signature.
            // However, following RFC 5480 (https://www.ietf.org/rfc/rfc5480.txt) to encode {r, s} as:
            //
            // ECDSA-Sig-Value ::= SEQUENCE {
            //   r  INTEGER,
            //   s  INTEGER
            // }
            //
            // causes verifying error when using `SecKeyVerifySignature` sometimes (even with or without prefixing 0x00
            // to the first byte if it is above 0x70). It might be an implemetation issue, so we decide to use
            // `SecKeyRawVerify` now, which accepts raw {r, s} signature.
            //
            // Check this later if we have time to make all algorithms doing a `SecKeyVerifySignature` instead.
            // See http://www.secg.org/sec1-v2.pdf
            //     https://crypto.stackexchange.com/questions/57731/ecdsa-signature-rs-to-asn1-der-encoding-question
            //     https://opensource.apple.com/source/Security/Security-57740.51.3/keychain/SecKey.h
            //
            if let rsaAlgorithm = algorithm as? RSA.Algorithm {
                var error: Unmanaged<CFError>?
                let result = SecKeyVerifySignature(
                    key.key, rsaAlgorithm.signatureAlgorithm, raw as CFData, signature.raw as CFData, &error)
                
                guard error == nil else {
                    let err = error?.takeRetainedValue()
                    throw CryptoError.algorithmsFailed(
                        reason: .verifyingError(err, statusCode: (err as? CustomNSError)?.errorCode))
                }
                
                return result
            } else if let ecAlgorithm = algorithm as? ECDSA.Algorithm {
                let digestData = raw.digest(using: ecAlgorithm)
                let digest = [UInt8](digestData)
                let signatureBytes: [UInt8] = Array(signature.raw)
                let status = SecKeyRawVerify(
                    key.key, .sigRaw, digest, digest.count, signatureBytes, ecAlgorithm.curve.signatureOctetLength)
                if status != 0 {
                    let statusCode = Int(status)
                    let error = NSError(domain: CryptoError.errorDomain, code: statusCode, userInfo: nil)
                    throw CryptoError.algorithmsFailed(reason: .verifyingError(error, statusCode: statusCode))
                }
                return true
            } else {
                Log.fatalError("Unsupported algorithm: \(algorithm)")
            }
        }
    }
    
    /// Represents encrypted data. The encrypted data could be decrypted.
    struct EncryptedData: CryptoData {
        let raw: Data
        
        /// Decrypts the current encrypted data with an RSA private key, using a given algorithm.
        ///
        /// - Parameters:
        ///   - key: The private key used to decrypt data.
        ///   - algorithm: The digest algorithm used to decrypt data with `key`.
        /// - Returns: The plain data representation.
        /// - Throws: A `CryptoError` if something wrong happens.
        func decrypted(with key: CryptoPrivateKey, using algorithm: CryptoAlgorithm) throws -> PlainData {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCreateDecryptedData(
                key.key, algorithm.encryptionAlgorithm, raw as CFData, &error) else
            {
                throw CryptoError.algorithmsFailed(reason: .decryptingError(error?.takeRetainedValue()))
            }
            
            return PlainData(raw: data as Data)
        }
    }
    
    struct SignedData: CryptoData {
        let raw: Data
    }
}
