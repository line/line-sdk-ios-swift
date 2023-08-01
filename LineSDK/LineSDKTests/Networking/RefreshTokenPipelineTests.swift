//
//  RefreshTokenPipelineTests.swift
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


class RefreshTokenPipelineTests: XCTestCase {
    
    var pipeline: RefreshTokenRedirector!
    
    override func setUp() {
        super.setUp()
        LoginManager.shared.setup(channelID: "123", universalLinkURL: nil)
        pipeline = RefreshTokenRedirector()
    }
    
    override func tearDown() {
        LoginManager.shared.reset()
        super.tearDown()
    }
    
    func testRefreshTokenPipelineSuccess() {
        
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let delegate = SessionDelegateStub(stub: .init(string: PostRefreshTokenRequest.success, responseCode: 200) )
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: delegate)
        
        XCTAssertNil(AccessTokenStore.shared.current)
        setupTestToken()
        
        let request = StubRequestSimple()
        let response = HTTPURLResponse.responseFromCode(403)
        
        try! pipeline.redirect(request: request, data: Data(), response: response) {
            action in
            switch action {
            case .restartWithout(let p):
                XCTAssertNotNil(AccessTokenStore.shared.current)
                XCTAssertEqual(p, .redirector(self.pipeline))
                XCTAssertTrue(delegate.stubItems.isEmpty)
            default:
                XCTFail("Refresh token pipeline should success.")
            }
            try! AccessTokenStore.shared.removeCurrentAccessToken()
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testRefreshTokenPipelineFailed() {
        
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let either = SessionDelegateStub.Either(string: "error message", responseCode: 123)
        let delegate = SessionDelegateStub(stub: either)
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: delegate)
        
        setupTestToken()
        
        let request = StubRequestSimple()
        let response = HTTPURLResponse.responseFromCode(401)
        try! pipeline.redirect(request: request, data: Data(), response: response) {
            action in
            switch action {
            case .stop(let error):
                guard case .responseFailed(
                    reason: .invalidHTTPStatusAPIError(
                        let detail)) = error as! LineSDKError else
                {
                    XCTFail("Error type is not correct.")
                    return
                }
                XCTAssertNil(detail.error)
                XCTAssertEqual(detail.code, 123)
                XCTAssertEqual(detail.rawString, "error message")
                
                if case .response(_, let res) = either {
                    XCTAssertEqual(detail.raw, res)
                } else {
                    XCTFail("Either should contain the refresh token response")
                }
            default:
                XCTFail("Refresh token pipeline should success.")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testRefreshTokenPipelineFailedForLackOfToken() {
        
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let delegate = SessionDelegateStub(stub: .init(string: "error message", responseCode: 123))
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: delegate)
        
        let request = StubRequestSimple()
        let response = HTTPURLResponse.responseFromCode(401)
        try! pipeline.redirect(request: request, data: Data(), response: response) {
            action in
            switch action {
            case .stop(let error):
                guard case .requestFailed(
                    reason: .lackOfAccessToken) = error as! LineSDKError else
                {
                    XCTFail("Error type is not correct.")
                    return
                }
            default:
                XCTFail("Refresh token pipeline should success.")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    
}
