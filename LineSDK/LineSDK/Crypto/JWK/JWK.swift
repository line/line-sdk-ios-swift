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

enum JWKKeyType: String, Decodable {
    case rsa = "RSA"
}

enum JWK: Decodable {
    case rsa(RSAJSONWebKey)
    
    enum CodingKeys: String, CodingKey {
        case type = "kty"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keyType = try container.decode(String.self, forKey: .type)
        switch JWKKeyType(rawValue: keyType) {
        case .rsa?:
            let key = try RSAJSONWebKey(from: decoder)
            self = .rsa(key)
        case nil:
            throw CryptoError.jsonWebKeyFailed(reason: .unsupportedKeyType(keyType))
        }
    }
}

struct RSAJSONWebKey: Decodable {
    let keyType = JWKKeyType.rsa
    let modulus: String
    let exponent: String
}
