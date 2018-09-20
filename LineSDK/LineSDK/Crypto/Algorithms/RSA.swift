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

/// RSA Digest Algorithms.
extension RSA {
    enum Algorithm: CryptoAlgorithm {
        case sha1, sha224, sha256, sha384, sha512
        
        var length: CC_LONG {
            switch self {
            case .sha1: return CC_LONG(CC_SHA1_DIGEST_LENGTH)
            case .sha224: return CC_LONG(CC_SHA224_DIGEST_LENGTH)
            case .sha256: return CC_LONG(CC_SHA256_DIGEST_LENGTH)
            case .sha384: return CC_LONG(CC_SHA384_DIGEST_LENGTH)
            case .sha512: return CC_LONG(CC_SHA512_DIGEST_LENGTH)
            }
        }
        
        var signatureAlgorithm: SecKeyAlgorithm {
            switch self {
            case .sha1:   return .rsaSignatureMessagePKCS1v15SHA1
            case .sha224: return .rsaSignatureMessagePKCS1v15SHA224
            case .sha256: return .rsaSignatureMessagePKCS1v15SHA256
            case .sha384: return .rsaSignatureMessagePKCS1v15SHA384
            case .sha512: return .rsaSignatureMessagePKCS1v15SHA512
            }
        }
        
        var encryptionAlgorithm: SecKeyAlgorithm {
            switch self {
            case .sha1:   return .rsaEncryptionOAEPSHA1AESGCM
            case .sha224: return .rsaEncryptionOAEPSHA224AESGCM
            case .sha256: return .rsaEncryptionOAEPSHA256AESGCM
            case .sha384: return .rsaEncryptionOAEPSHA384AESGCM
            case .sha512: return .rsaEncryptionOAEPSHA512AESGCM
            }
        }
        
        var digest: CryptoDigest {
            switch self {
            case .sha1:   return CC_SHA1
            case .sha224: return CC_SHA224
            case .sha256: return CC_SHA256
            case .sha384: return CC_SHA384
            case .sha512: return CC_SHA512
            }
        }
    }
}
