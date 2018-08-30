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

struct RSA {}

protocol RSADataType {
    var raw: Data { get }
    init(raw: Data)
}

/// Data Types of RSA related domain.
extension RSA {
    struct PlainData: RSADataType {
        let raw: Data
        func encrypted(with key: String, using algorithm: RSA.Algorithm) throws -> EncryptedData {
            throw NSError()
        }
        
        func signed(with key: String, algorithm: RSA.Algorithm) throws -> SignedData {
            throw NSError()
        }
    }
    
    struct EncryptedData: RSADataType {
        let raw: Data
        func decrypted(with key: String, using algorithm: RSA.Algorithm) throws -> PlainData {
            throw NSError()
        }
    }
    
    struct SignedData: RSADataType {
        let raw: Data
        func verify(with key: String, signature: SignedData, algorithm: RSA.Algorithm) throws -> Bool {
            throw NSError()
        }
    }
}

// Some convenience methods.
extension RSADataType {
    init(base64Encoded string: String) throws {
        guard let data = Data(base64Encoded: string) else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: string))
        }
        self.init(raw: data)
    }
}

