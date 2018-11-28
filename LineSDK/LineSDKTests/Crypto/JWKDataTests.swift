//
//  JWKDataTests.swift
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

let keys = """
{
  "keys": [
  {
    "alg": "RS256",
    "n": "8h6tCwOYDPtzyFivNaIguQVc_yBO5eOA2kUu_MAN8s4VWn8tIfCbVvcAz3yNwQuGpkdNg8gTk9QmReXl4SE8m7aCa0iRcBBWLyPUt6TM1RkYE51rOGYhjWxo9V8ogMXSBclE6x0t8qFY00l5O34gjYzXtyvyBX7Sw5mGuNLVAzq2nsCTnIsHrIaBy70IKU3FLsJ_PRYyViXP1nfo9872q3mtn7bJ7_hqss0vDgUiNAqPztVIsrZinFbaTgXjLhBlUjFWgJx_g4p76CJkjQ3-puZRU5A0D04KvqQ_0AWcN1Q8pvwQ9V4uGHm6Bop9nUhIcZJYjjlTM9Pkx_JnVOfekw",
    "use": "sig",
    "kid": "b863b534069bfc0207197bcf831320d1cdc2cee2",
    "e": "AQAB",
    "kty": "RSA"
  },
  {
    "alg": "RS256",
    "n": "xul55cFjIY7QFMhl79y_3MWK4rHDRqTu-C2VxaPqxbLUSW-LJp8hotDeIOdMEawi2WFNUUCrOpSl33CtX3oFeq7ytLS6y5aosoQMLlguGHnU7FBNvw9kNtR41ykvLphU5YGJVr_JVFAqJPcpB9cEo6f6Mo9i8_gfsXMhkyrm5eqXDFlgDfgfJ_oaMyfkBmhLO2sjgdLguy_x6jg1Ys3WK2DfsI0q7X_esbEStEiV9M9lHOYsmdikKO-CPK6_c5zzJgiIjoND47WEtWuuOp_izV6BeojK9JFPHxcOnX71__sTWYl2iv7cZUNQQeH3Kub6gfpfVjCExy_5qKvtdMnzrw",
    "use": "sig",
    "kid": "55b854edf35f093b4708f72dec4f15149836e8ac",
    "e": "AQAB",
    "kty": "RSA"
  },
  {
    "kty":"EC",
    "alg":"ES256",
    "use":"sig",
    "kid":"038513fc01804702e2670334007c8c8cbe744d4a8691b3f5bfe0f251dd2ca475",
    "crv":"P-256",
    "x":"GGERLwduXJpu_-Yizvypq5TlJS8VCOxoreD9J6DsZZs",
    "y":"RLKGzm2JCHmixjsrKysjNKPym8-odN_HSY2rx72qZFM"
  },
  {
    "kty":"EC",
    "alg":"ES256",
    "use":"sig",
    "kid":"3829b108279b26bcfcc8971e348d116727d20773f06a41c5e4e9706f7a0dc966",
    "crv":"P-256",
    "x":"AP-wDPkDt5uw9sBJIIpZxEgEm-Cioa9GksSGCFy9kFfv",
    "y":"PU-LJ7KeXHf8-Hc2ckXz11wvuoBsVKCgwFgH4bU25oo"
  },
  {
    "kty":"EC",
    "alg":"ES256",
    "use":"sig",
    "kid":"16e04d4e56783a792dcb4684d86d179dc7abc0bb909d96ee12ef07097cddff0c",
    "crv":"P-256",
    "x":"M5ucqcVZ7YVZcZ8QNXfLQkcpMssToe2o7IogW2yrhZQ",
    "y":"AJVj5j7yN_wz-Zc0a9n-7bk-U9BxhNOF0taXzFrwdxcy"
  }
  ]
}
"""

class JWKDataTests: XCTestCase {
    func testKeysData() {
        let decoder = JSONDecoder()
        let keySet = try! decoder.decode(JWKSet.self, from: Data(keys.utf8))
        
        let key1 = keySet.getKeyByID("b863b534069bfc0207197bcf831320d1cdc2cee2")
        XCTAssertNotNil(key1)
        let data1 = try! key1!.getKeyData()
        _ = try! Crypto.RSAPublicKey(der: data1)
        
        let key2 = keySet.getKeyByID("55b854edf35f093b4708f72dec4f15149836e8ac")
        XCTAssertNotNil(key1)
        let data2 = try! key2!.getKeyData()
        _ = try! Crypto.RSAPublicKey(der: data2)
        
        let key3 = keySet.getKeyByID("038513fc01804702e2670334007c8c8cbe744d4a8691b3f5bfe0f251dd2ca475")
        XCTAssertNotNil(key3)
        let data3 = try! key3!.getKeyData()
        _ = try! Crypto.ECDSAPublicKey(der: data3)
        
        let key4 = keySet.getKeyByID("3829b108279b26bcfcc8971e348d116727d20773f06a41c5e4e9706f7a0dc966")
        XCTAssertNotNil(key4)
        let data4 = try! key4!.getKeyData()
        _ = try! Crypto.ECDSAPublicKey(der: data4)
        
        let key6 = keySet.getKeyByID("16e04d4e56783a792dcb4684d86d179dc7abc0bb909d96ee12ef07097cddff0c")
        XCTAssertNotNil(key6)
        let data6 = try! key6!.getKeyData()
        _ = try! Crypto.ECDSAPublicKey(der: data6)
    }
}
