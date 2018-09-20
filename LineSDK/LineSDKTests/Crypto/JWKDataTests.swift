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
        
    }
}
