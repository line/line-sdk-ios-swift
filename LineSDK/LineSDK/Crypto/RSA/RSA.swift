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

struct RSA {}

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
    
    init(string: String, encoding: String.Encoding = .utf8) throws {
        guard let data = string.data(using: encoding) else {
            throw CryptoError.generalError(reason: .stringConversionFailed(String: string, encoding: encoding))
        }
        self.init(raw: data)
    }

    func digest(using algorithm: RSA.Algorithm) throws -> Data {
        return try raw.digest(using: algorithm)
    }
}

/// Data Types of RSA related domain.
extension RSA {
    struct PlainData: RSAData {
        let raw: Data
        
        func encrypted(with key: PublicKey, using algorithm: RSA.Algorithm) throws -> EncryptedData {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCreateEncryptedData(
                key.key, algorithm.encryptionAlgorithm, raw as CFData, &error) else
            {
                throw CryptoError.rsaFailed(reason: .encryptingError(reason: "\(String(describing: error))"))
            }
            
            return EncryptedData(raw: data as Data)
        }
        
        func signed(with key: PrivateKey, algorithm: RSA.Algorithm) throws -> SignedData {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCreateSignature(
                key.key, algorithm.signatureAlgorithm, raw as CFData, &error) else
            {
                throw CryptoError.rsaFailed(reason: .signingError(reason: "\(String(describing: error))"))
            }
            
            return SignedData(raw: data as Data)
        }
        
        func verify(with key: PublicKey, signature: SignedData, algorithm: RSA.Algorithm) throws -> Bool {
            var error: Unmanaged<CFError>?
            let result = SecKeyVerifySignature(
                key.key, algorithm.signatureAlgorithm, raw as CFData, signature.raw as CFData, &error)
            
            guard error == nil else {
                throw CryptoError.rsaFailed(reason: .verifyingError(reason: "\(String(describing: error))"))
            }
            
            return result
        }
    }
    
    struct EncryptedData: RSAData {
        let raw: Data
        func decrypted(with key: PrivateKey, using algorithm: RSA.Algorithm) throws -> PlainData {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCreateDecryptedData(
                key.key, algorithm.encryptionAlgorithm, raw as CFData, &error) else
            {
                throw CryptoError.rsaFailed(reason: .decryptingError(reason: "\(String(describing: error))"))
            }
            
            return PlainData(raw: data as Data)
        }
    }
    
    struct SignedData: RSAData {
        let raw: Data
    }
}
