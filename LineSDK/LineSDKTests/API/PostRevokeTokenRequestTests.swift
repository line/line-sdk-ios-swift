//
//  PostRevokeTokenRequestTests.swift
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

extension PostRevokeTokenRequest: ResponseDataStub {
    static let success = ""
}

class PostRevokeTokenRequestTests: APITests {
    func testSuccess() {
        let request = PostRevokeTokenRequest(channelID: "123", accessToken: "123")
        runTestSuccess(for: request) { _ in }
    }
    
    func testRequestFailWith400Response() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let request = PostRevokeTokenRequest(channelID: "123", accessToken: "123")
        
        let stub = SessionDelegateStub(stub: .init(string: "{\"error\": \"invalid_request\"}", responseCode: 400))
        let session = Session(configuration: config, delegate: stub)
        session.send(request) { result in
            XCTAssertNotNil(result.error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAPISuccessWith400Response() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let stub = SessionDelegateStub(stub: .init(string: "{\"error\": \"invalid_request\"}", responseCode: 400))
        Session._shared = Session(configuration: config, delegate: stub)
        setupTestToken()
        
        API.Auth.revokeAccessToken {result in
            XCTAssertNotNil(result.value)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
