//
//  JWK.swift
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

// A partitial implementation for JSON Web Key (JWK)
// Only RSA is required for LineSDK, ref: https://tools.ietf.org/html/rfc7517

import Foundation

struct JWA {
    enum Algorithm: String, Decodable {
        case RS256
        case RS384
        case RS512
    }
}

struct JWK: Decodable {
    
    enum KeyType: String, Decodable {
        case rsa = "RSA"
    }
    
    enum PublicKeyUse: String, Decodable {
        case signature = "sig"
        case encryption = "enc"
    }
    
    enum CodingKeys: String, CodingKey {
        case keyType = "kty"
        case keyUse = "use"
        case keyID = "kid"
        case algorithm = "alg"
    }

    let keyType: KeyType
    let keyUse: PublicKeyUse?
    let keyID: String?
    let algorithm: JWA.Algorithm?
    
    let parameters: KeyParameters
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keyTypeString = try container.decode(String.self, forKey: .keyType)
        guard let keyType = KeyType(rawValue: keyTypeString) else {
            throw CryptoError.JWKFailed(reason: .unsupportedKeyType(keyTypeString))
        }
        
        self.keyType = keyType
        keyUse = try container.decodeIfPresent(PublicKeyUse.self, forKey: .keyUse)
        keyID = try container.decodeIfPresent(String.self, forKey: .keyID)
        algorithm = try container.decodeIfPresent(JWA.Algorithm.self, forKey: .algorithm)
        
        let singleContainer = try decoder.singleValueContainer()
        parameters = try singleContainer.decode(KeyParameters.self)
    }
    
}

extension JWK {
    struct RSAParameters: Decodable {
        let modulus: String
        let exponent: String
        
        enum CodingKeys: String, CodingKey {
            case modulus = "n"
            case exponent = "e"
        }
    }

}

extension JWK {
    enum KeyParameters: Decodable {
        
        enum CodingKeys: String, CodingKey {
            case keyType = "kty"
        }
        
        case rsa(RSAParameters)
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let keyType = try container.decode(KeyType.self, forKey: .keyType)
            switch keyType {
            case .rsa:
                self = .rsa(try RSAParameters(from: decoder))
            }
        }
        
        var asRSA: RSAParameters? {
            if case .rsa(let parameters) = self { return parameters }
            return nil
        }
    }
}
