//
//  JWKTests.swift
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

import XCTest
@testable import LineSDK

let sampleRSAKey = """
{
  "alg": "RS256",
  "n": "abc",
  "use": "sig",
  "kid": "123",
  "e": "AQAB",
  "kty": "RSA"
}
"""

let sampleECDSAKey = """
{
  "kty": "EC",
  "use": "sig",
  "crv": "P-256",
  "kid": "123",
  "x": "JrcJv7WmUDazFvBba3WDzo2fzb_zpj8ydffUZ7h-dNQ",
  "y": "jAesyqaJz6QgLE64_XozXCQTQubDT-PtXPiV2ejriig",
  "alg": "ES256"
}
"""

// HS256 keys are not supported yet (we cannot accept a symmetric algorithm)
let unsupportedKey = """
{
  "kty": "oct",
  "use": "sig",
  "kid": "456",
  "k": "abc",
  "alg": "HS256"
}
"""

class JWKTests: XCTestCase {

    func testParseRSAKey() {
        let decoder = JSONDecoder()
        let key = try! decoder.decode(JWK.self, from: Data(sampleRSAKey.utf8))
        XCTAssertEqual(key.keyType, .rsa)
        XCTAssertEqual(key.keyUse, .signature)
        XCTAssertEqual(key.keyID, "123")
        XCTAssertEqual(key.parameters.asRSA!.exponent, "AQAB")
        XCTAssertEqual(key.parameters.asRSA!.modulus, "abc")
        XCTAssertEqual(key.parameters.asRSA!.algorithm, .RS256)
    }
    
    func testParseECDSAKey() {
        let decoder = JSONDecoder()
        let key = try! decoder.decode(JWK.self, from: Data(sampleECDSAKey.utf8))
        XCTAssertEqual(key.keyType, .ec)
        XCTAssertEqual(key.keyUse, .signature)
        XCTAssertEqual(key.keyID, "123")
        XCTAssertEqual(key.parameters.asEC!.x, "JrcJv7WmUDazFvBba3WDzo2fzb_zpj8ydffUZ7h-dNQ")
        XCTAssertEqual(key.parameters.asEC!.y, "jAesyqaJz6QgLE64_XozXCQTQubDT-PtXPiV2ejriig")
        XCTAssertEqual(key.parameters.asEC!.curve, .P256)
    }
    
    func testUnsupportedKey() {
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode(JWK.self, from: Data(unsupportedKey.utf8))
        } catch {
            guard case CryptoError.JWKFailed(reason: .unsupportedKeyType) = error else {
                XCTFail("Should be an .unsupportedKeyType error")
                return
            }
        }
    }
    
    func testJWKSetGetKey() {
        let set = "{\"keys\": [\(sampleRSAKey), \(unsupportedKey)]}"
        let decoder = JSONDecoder()
        let keySets = try! decoder.decode(JWKSet.self, from: Data(set.utf8))
        XCTAssertEqual(keySets.keys.count, 1)
        XCTAssertNotNil(keySets.getKeyByID("123"))
    }
}
