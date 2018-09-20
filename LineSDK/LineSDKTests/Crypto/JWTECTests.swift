//
//  JWTECTests.swift
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

// Private Key for test cases in this file:
/*
 
 -----BEGIN PRIVATE KEY-----
 MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
 OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
 1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
 -----END PRIVATE KEY-----
 
 */

private let pubKey = """
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEVs/o5+uQbTjL3chynL4wXgUg2R9
q9UU8I5mEovUf86QZ7kOBIjJwqnzD1omageEHWwHdBO6B+dFabmdT9POxg==
-----END PUBLIC KEY-----
"""

/*
 {
 "alg": "RS256",
 "typ": "JWT"
 }.
 {
 "sub": "1234567890",
 "name": "John Doe",
 "admin": true,
 "iat": 1516239022
 }
 */

private let sample = "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.0w6hDu9x9xd-FJqrJRboTslqAStdldw4jySapjF0tzxwhodlUS3zu81Z0bb1SoZckuprac2vxiuOH2I5i2uFUg"

private let LINEIDToken =  "eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEyMzQ1In0.eyJpc3MiOiJodHRwczovL2FjY2Vzcy5saW5lLm1lIiwic3ViIjoiVTEyMzQ1Njc4OTBhYmNkZWYxMjM0NTY3ODkwYWJjZGVmIiwiYXVkIjoiMTIzNDUiLCJleHAiOjE1MzU5NTk4NzAsImlhdCI6MTUzNTk1OTc3MCwibm9uY2UiOiJBQkNBQkMiLCJuYW1lIjoib25ldmNhdCIsInBpY3R1cmUiOiJodHRwczovL29icy1iZXRhLmxpbmUtYXBwcy5jb20veHh4eCIsImVtYWlsIjoiYWJjQGRlZi5jb20ifQ.Chf78LoctctsENqBB5MecAYKlo--ITHL-C2Ah0zYqQM4C9i9yvwOMH7hYInIsVVVmleHxtOT7yPWuiMUbvpDMA"

class JWTECTests: XCTestCase {

    func testJWTSignatureVerify() {
        let data = Data(sample.utf8)
        let token = try! JWT(data: data)
        
        let key = try! Crypto.ECDSAPublicKey(pem: pubKey)
        let result = try! token.verify(with: key)
        XCTAssertTrue(result)
    }
}
