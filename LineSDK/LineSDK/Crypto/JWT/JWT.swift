//
//  JWT.swift
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

/// Represents a JSON Web Token Object. Use this struct to get values/verify.
public struct JWT {
    let header: Header
    public let payload: Payload
    let signature: Data
    
    let rawComponents: [String]
    
    init(text: String) throws {
        rawComponents = text.components(separatedBy: ".")
        guard rawComponents.count == 3 else {
            throw CryptoError.JWTFailed(reason: .malformedJWTFormat(string: text))
        }
        
        let decoder = Base64JSONDecoder()
        header = try decoder.decode(Header.self, from: rawComponents[0])
        
        let payloadValues = try decoder.decodeDictionary(rawComponents[1])
        payload = Payload(values: payloadValues)
        
        guard let sigData = rawComponents[2].base64URLDecoded else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: rawComponents[2]))
        }
        signature = sigData
    }
    
    init(data: Data) throws {
        guard let text = String(data: data, encoding: .utf8) else {
            throw CryptoError.generalError(reason: .dataConversionFailed(data: data, encoding: .utf8))
        }
        try self.init(text: text)
    }
    
    func verify(with key: JWTSignKey) throws -> Bool {
        guard let alg = JWA.Algorithm(rawValue: header.algorithm) else {
            throw CryptoError.JWTFailed(reason: .unsupportedHeaderAlgorithm(name: header.algorithm))
        }
        switch alg {
        case .RS256, .RS384, .RS512:
            let plainText = try RSA.PlainData(string: plainSegment)
            let signData = RSA.SignedData(raw: signature)
            guard let key = key.RSAKey else {
                return false
            }
            let result = try plainText.verify(with: key, signature: signData, algorithm: alg.rsaAlgorithm)
            return result
        }
    }
}

extension JWT {
    var plainSegment: String {
        return "\(rawComponents[0]).\(rawComponents[1])"
    }
}

extension JWT {
    struct Header: Codable {
        let algorithm: String
        let tokenType: String?
        let keyID: String?

        enum CodingKeys: String, CodingKey {
            case algorithm = "alg"
            case tokenType = "typ"
            case keyID = "kid"
        }
    }
}

extension JWT {
    public struct Payload {
        let values: [String: Any]
        
        func verify<T: Equatable>(keyPath: KeyPath<JWT.Payload, T?>, expected: T) throws {
            try verify(keyPath: keyPath, failingReason: "expected: \(expected)") { value in
                return value == expected }
        }
        
        func verify(keyPath: KeyPath<JWT.Payload, Date?>, earlierThan date: Date) throws {
            try verify(keyPath: keyPath, failingReason: "expected should earlier than \(date)") { value in
                return value <= date
            }
        }
        
        func verify(keyPath: KeyPath<JWT.Payload, Date?>, laterThan date: Date) throws {
            try verify(keyPath: keyPath, failingReason: "expected should later than \(date)") { value in
                return value >= date
            }
        }
        
        func verify<T>(
            keyPath: KeyPath<JWT.Payload, T?>,
            failingReason: @autoclosure () -> String,
            condition: (T) -> Bool) throws
        {
            guard let value = self[keyPath: keyPath] else {
                throw CryptoError.JWTFailed(
                    reason: .claimVerifyingFailed(key: "\(keyPath)", got: "nil", description: "value not exist"))
            }
            guard condition(value) else {
                throw CryptoError.JWTFailed(
                    reason: .claimVerifyingFailed(key: "\(keyPath)", got: "\(value)", description: failingReason()))
            }
        }
    }
}

// MARK: - Named getter for claims
extension JWT.Payload {
    public subscript<T>(key: String, type: T.Type) -> T? {
        return values[key] as? T
    }
    
    public var issuer: String? { return self["iss", String.self] }
    public var subject: String? { return self["sub", String.self] }
    public var audience: String? { return self["aud", String.self] }
    public var expiration: Date? {
        guard let timeInterval = self["exp", TimeInterval.self] else {
            return nil
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
    public var issueAt: Date? {
        guard let timeInterval = self["iat", TimeInterval.self] else {
            return nil
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
}

// MARK: - LINE Related claims
extension JWT.Payload {
    var nonce: String? { return self["nonce", String.self] }
    public var name: String? { return self["name", String.self] }
    public var picture: URL? {
        guard let string = self["picture", String.self] else {
            return nil
        }
        return URL(string: string)
    }
    public var email: String? { return self["email", String.self] }
    
}
