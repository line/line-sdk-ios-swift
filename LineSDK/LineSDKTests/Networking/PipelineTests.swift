//
//  PipelineTests.swift
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

class PipelineTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPipelineEquality() {
        
        let token1 = RefreshTokenRedirector()
        let token2 = RefreshTokenRedirector()
        
        XCTAssertTrue(ResponsePipeline.redirector(token1) == ResponsePipeline.redirector(token1))
        XCTAssertFalse(ResponsePipeline.redirector(token1) == ResponsePipeline.redirector(token2))
        
        let parser1 = ParsePipeline(JSONDecoder())
        let parser2 = ParsePipeline(JSONDecoder())
        
        XCTAssertTrue(ResponsePipeline.terminator(parser1) == ResponsePipeline.terminator(parser1))
        XCTAssertFalse(ResponsePipeline.terminator(parser1) == ResponsePipeline.terminator(parser2))
        
        XCTAssertFalse(ResponsePipeline.redirector(token1) == ResponsePipeline.terminator(parser1))
    }
    
    func testParsePipeline() {
        let pipeline = ParsePipeline(JSONDecoder())
        let result = try! pipeline.parse(request: StubRequestSimple(), data: StubRequestSimple.successData)
        XCTAssertEqual(result.foo, "bar")
    }
    
    func testRefreshTokenPipeline() {
        // TODO: RefreshTokenRedirector is not implemented yet.
    }
    
    func testBadHTTPStatusPipelineValidCode() {
        let pipeline = BadHTTPStatusRedirector(valid: 200..<300)
        
        let request = StubRequestSimple()
        let response = HTTPURLResponse.responseFromCode(200)
        let shouldApply = pipeline.shouldApply(request: request, data: Data(), response: response)
        XCTAssertFalse(shouldApply)
    }
    
    func testBadHTTPStatusPipelineApplyAuthError() {
        let pipeline = BadHTTPStatusRedirector(valid: 200..<300)
        
        let request = StubRequestSimple()
        let response = HTTPURLResponse.responseFromCode(404)
        
        let authError = ["error": "123", "error_description": "sample"]
        let data = try! JSONSerialization.data(withJSONObject: authError, options: [])
        try! pipeline.redirect(request: request, data: data, response: response) { action in
            switch action {
            case .stop(let error):
                if let sdkError = error as? LineSDKError,
                   case .responseFailed(reason:
                    .invalidHTTPStatusAuth(code: let code, error: let authErr, raw: let raw)) = sdkError
                {
                    XCTAssertEqual(code, 404)
                    XCTAssertEqual(authErr.error, "123")
                    XCTAssertEqual(authErr.errorDescription, "sample")
                    assertJSONText(raw, equalsTo: authError)
                } else {
                    XCTFail("A responseFailed with AuthError should be thrown out.")
                }
            default:
                XCTFail("A back HTTP status pipeline should result in .stop action.")
            }
        }
    }
    
    func testBadHTTPStatusPipelineApplyAPIError() {
        let pipeline = BadHTTPStatusRedirector(valid: 200..<300)
        
        let request = StubRequestSimple()
        let response = HTTPURLResponse.responseFromCode(404)
        
        let apiError = ["message": "hello"]
        let data = try! JSONSerialization.data(withJSONObject: apiError, options: [])
        try! pipeline.redirect(request: request, data: data, response: response) { action in
            switch action {
            case .stop(let error):
                if let sdkError = error as? LineSDKError,
                    case .responseFailed(reason:
                        .invalidHTTPStatusAPI(code: let code, error: let apiErr, raw: let raw)) = sdkError
                {
                    XCTAssertEqual(code, 404)
                    XCTAssertEqual(apiErr.message, "hello")
                    assertJSONText(raw, equalsTo: apiError)
                } else {
                    XCTFail("A responseFailed with AuthError should be thrown out.")
                }
            default:
                XCTFail("A back HTTP status pipeline should result in .stop action.")
            }
        }
    }
    
    func testBadHTTPStatusPipelineApplyUnknownError() {
        let pipeline = BadHTTPStatusRedirector(valid: 200..<300)
        
        let request = StubRequestSimple()
        let response = HTTPURLResponse.responseFromCode(404)
        
        let error = ["error_domain": "error_detail"]
        let data = try! JSONSerialization.data(withJSONObject: error, options: [])
        try! pipeline.redirect(request: request, data: data, response: response) { action in
            switch action {
            case .stop(let err):
                if let sdkError = err as? LineSDKError,
                    case .responseFailed(reason:
                        .invalidHTTPStatus(code: let code, raw: let raw)) = sdkError
                {
                    XCTAssertEqual(code, 404)
                    assertJSONText(raw, equalsTo: error)
                } else {
                    XCTFail("A responseFailed with AuthError should be thrown out.")
                }
            default:
                XCTFail("A back HTTP status pipeline should result in .stop action.")
            }
        }
    }
    
    private func assertJSONText(_ text: String!, equalsTo obj: [String: String]) {
        let rawData = text!.data(using: .utf8)!
        let payload = try! JSONSerialization.jsonObject(with: rawData, options: []) as! [String: String]
        XCTAssertEqual(obj, payload)
    }
}

