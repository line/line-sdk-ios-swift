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
    
    func getKeyData() throws -> Data {
        switch parameters {
        case .rsa(let rsaParams):
            return try rsaParams.getKeyData()
        }
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
        
        // Get public key DER data from modulus and exponent
        func getKeyData() throws -> Data {
            guard let decodedModulusData = modulus.base64URLDecoded else {
                throw CryptoError.generalError(reason: .base64ConversionFailed(string: modulus))
            }
            guard let decodedExponentData = exponent.base64URLDecoded else {
                throw CryptoError.generalError(reason: .base64ConversionFailed(string: exponent))
            }
            
            var modulusBytes = [UInt8](decodedModulusData)
            // Make sure the modulusBytes starts with 0x00
            if let firstByte = modulusBytes.first, firstByte != 0x00 {
                modulusBytes.insert(0x00, at: 0)
            }
            
            let modulusEncoded = modulusBytes.encode(as: .integer)
            
            let exponentBytes = [UInt8](decodedExponentData)
            let exponentEncoded = exponentBytes.encode(as: .integer)
            
            let sequenceEncoded = (modulusEncoded + exponentEncoded).encode(as: .sequence)
            return Data(bytes: sequenceEncoded)
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

// MARK: Array Extension for Encoding
// Inspired by: https://github.com/henrinormak/Heimdall/blob/master/Heimdall/Heimdall.swift
extension Array where Element == UInt8 {
    
    func encode(as type: ASN1Type) -> [UInt8] {
        var tlvTriplet: [UInt8] = []
        tlvTriplet.append(type.byte)
        tlvTriplet.append(contentsOf: lengthField(of: self))
        tlvTriplet.append(contentsOf: self)
        
        return tlvTriplet
    }
    
}

// MARK: Freestanding Helper Function
private func lengthField(of valueField: [UInt8]) -> [UInt8] {
    var count = valueField.count
    
    if count < 128 {
        return [ UInt8(count) ]
    }
    
    // The number of bytes needed to encode count.
    let lengthBytesCount = Int((log2(Double(count)) / 8) + 1)
    
    // The first byte in the length field encoding the number of remaining bytes.
    let firstLengthFieldByte = UInt8(128 + lengthBytesCount)
    
    var lengthField: [UInt8] = []
    for _ in 0..<lengthBytesCount {
        // Take the last 8 bits of count.
        let lengthByte = UInt8(count & 0xff)
        // Add them to the length field.
        lengthField.insert(lengthByte, at: 0)
        // Delete the last 8 bits of count.
        count = count >> 8
    }
    
    // Include the first byte.
    lengthField.insert(firstLengthFieldByte, at: 0)
    
    return lengthField
}
