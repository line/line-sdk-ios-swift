//
//  PostRefreshTokenRequestTests.swift
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

extension PostRefreshTokenRequest: ResponseDataStub {
    static let successToken = "123"
    
    static let success = PostRefreshTokenRequest.successToken(with: successToken)
    
    static func successToken(with token: String) -> String {
        return """
        {
        "scope":"profile openid",
        "access_token":"\(token)",
        "token_type":"Bearer",
        "refresh_token":"abc",
        "expires_in":259200
        }
        """
    }
}

class PostRefreshTokenRequestTests: APITests {
    
    func testSuccess() {
        let request = PostRefreshTokenRequest(channelID: "abc", refreshToken: "123123")
        runTestSuccess(for: request) { token in
            XCTAssertEqual(token.value, "123")
            XCTAssertEqual(token._refreshToken, "abc")
            XCTAssertEqual(token.tokenType, "Bearer")
            XCTAssertEqual(token.permissions, [LoginPermission.profile, LoginPermission.openID])
            XCTAssertEqual(token.expiresAt, token.createdAt.addingTimeInterval(token.expiresIn))
            XCTAssertNil(token.IDToken)
        }
    }
}
