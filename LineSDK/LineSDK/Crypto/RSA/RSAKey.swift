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
}

extension RSA {
    struct PublicKey: RSAKey {
        let key: SecKey
        init(key: SecKey) { self.key = key }
        
        // Creates a public key with DER data.
        init(der data: Data) throws {
            let keyData = try data.x509HeaserStripped()
            self.key = try SecKey.createKey(derData: keyData, keyClass: .publicKey)
        }
        
        init(certificate data: Data) throws {
            guard let string = String(data: data, encoding: .utf8) else {
                throw CryptoError.generalError(reason: .stringConversionFailed(data: data, encoding: .utf8))
            }
            
            let PEMString = try string.markerStrippedPEMBase64()
            let base64Data = Data(base64Encoded: PEMString)!
            self.key = try SecKey.createPublicKey(certificateData: base64Data)
        }
        
    }
    
    struct PrivateKey: RSAKey {
        let key: SecKey
        init(key: SecKey) { self.key = key }
        
        
        init(der data: Data) throws {
            let keyData = try data.x509HeaserStripped()
            self.key = try SecKey.createKey(derData: keyData, keyClass: .privateKey)
        }
    }
}

