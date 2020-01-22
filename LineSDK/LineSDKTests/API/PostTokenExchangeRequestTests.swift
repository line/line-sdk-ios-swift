//
//  PostExchangeTokenRequestTests.swift
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

/*
 {
 "alg": "RS256",
 "typ": "JWT",
 "kid": "12345"
 }.
 {
 "iss": "https://access.line.me",
 "sub": "U1234567890abcdef1234567890abcdef",
 "aud": "12345",
 "exp": 1535959870,
 "iat": 1535959770,
 "nonce": "ABCABC",
 "name": "onevcat",
 "picture": "https://obs.line-apps.com/xxxx",
 "email": "abc@def.com"
 }
 */
private let LINEIDToken = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEyMzQ1In0.eyJpc3MiOiJodHRwczovL2FjY2Vzcy5saW5lLm1lIiwic3ViIjoiVTEyMzQ1Njc4OTBhYmNkZWYxMjM0NTY3ODkwYWJjZGVmIiwiYXVkIjoiMTIzNDUiLCJleHAiOjE1MzU5NTk4NzAsImlhdCI6MTUzNTk1OTc3MCwibm9uY2UiOiJBQkNBQkMiLCJuYW1lIjoib25ldmNhdCIsInBpY3R1cmUiOiJodHRwczovL29icy1iZXRhLmxpbmUtYXBwcy5jb20veHh4eCIsImVtYWlsIjoiYWJjQGRlZi5jb20ifQ.F_Y8w5rqQEdzrjxhps4EJYUf0choZ9Mu7Uq-WMQ2sGIJDpWOIxu4DjGN-jYOeW_1ndJ9tFwUwXA26Gobawjirf4Y9WvGQiC7mevpkilAB8kL7sBILJ2pjmryJPagaFto0yAv0e2_UQjGSgZnElU2k2UbViAdfzIEC0XKy_PApFM"

extension PostExchangeTokenRequest: ResponseDataStub {
    
    static let successToken = "123"
    
    static let success: String =
    """
    {
        "access_token":"\(successToken)",
        "refresh_token":"abc",
        "token_type":"Bearer",
        "scope":"profile abcd",
        "id_token": "\(LINEIDToken)",
        "expires_in":2592000
    }
    """
}

class PostExchangeTokenRequestTests: APITests {

    func testSuccess() {
        let request = PostExchangeTokenRequest(
            channelID: config.channelID,
            code: "abcabc",
            codeVerifier: PKCE().codeVerifier,
            redirectURI: "urlurl",
            optionalRedirectURI: "universal")
        runTestSuccess(for: request) { token in
            XCTAssertEqual(token.value, "123")
            XCTAssertEqual(token._refreshToken, "abc")
            XCTAssertEqual(token.tokenType, "Bearer")
            XCTAssertEqual(token.permissions, [LoginPermission.profile, LoginPermission(rawValue: "abcd")])
            XCTAssertEqual(token.expiresAt, token.createdAt.addingTimeInterval(token.expiresIn))
            XCTAssertEqual(token.IDToken?.payload.issuer, "https://access.line.me")
        }
    }
}
