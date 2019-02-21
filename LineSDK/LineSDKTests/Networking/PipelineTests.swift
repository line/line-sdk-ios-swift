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

    func testPipelineEquality() {
        
        let token1 = RefreshTokenRedirector()
        let token2 = RefreshTokenRedirector()
        
        XCTAssertTrue(ResponsePipeline.redirector(token1) == ResponsePipeline.redirector(token1))
        XCTAssertFalse(ResponsePipeline.redirector(token1) == ResponsePipeline.redirector(token2))
        
        let parser1 = JSONParsePipeline(JSONDecoder())
        let parser2 = JSONParsePipeline(JSONDecoder())
        
        XCTAssertTrue(ResponsePipeline.terminator(parser1) == ResponsePipeline.terminator(parser1))
        XCTAssertFalse(ResponsePipeline.terminator(parser1) == ResponsePipeline.terminator(parser2))
        
        XCTAssertFalse(ResponsePipeline.redirector(token1) == ResponsePipeline.terminator(parser1))
    }
    
    func testJSONParsePipeline() {
        let pipeline = JSONParsePipeline(JSONDecoder())
        let result = try! pipeline.parse(request: StubRequestSimple(), data: StubRequestSimple.successData)
        XCTAssertEqual(result.foo, "bar")
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
                    .invalidHTTPStatusAPIError(let detail)) = sdkError
                {
                    XCTAssertEqual(detail.code, 404)
                    XCTAssertEqual(detail.error!.error, "123")
                    XCTAssertEqual(detail.error!.detail, "sample")
                    self.assertJSONText(detail.rawString, equalsTo: authError)
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
                        .invalidHTTPStatusAPIError(let detail)) = sdkError
                {
                    XCTAssertEqual(detail.code, 404)
                    XCTAssertEqual(detail.error!.error, "hello")
                    self.assertJSONText(detail.rawString, equalsTo: apiError)
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
                        .invalidHTTPStatusAPIError(let detail)) = sdkError
                {
                    XCTAssertEqual(detail.code, 404)
                    XCTAssertNil(detail.error)
                    self.assertJSONText(detail.rawString, equalsTo: error)
                } else {
                    XCTFail("A responseFailed with AuthError should be thrown out.")
                }
            default:
                XCTFail("A back HTTP status pipeline should result in .stop action.")
            }
        }
    }
    
    func testDataTransformPipeline() {
        let pipeline = DataTransformRedirector(condition: { $0.isEmpty }) {
            data in
            return "123".data(using: .utf8)!
        }
        
        let request = StubRequestSimple()
        let response = HTTPURLResponse.responseFromCode(200)
        
        let result1 = pipeline.shouldApply(request: request, data: Data(), response: response)
        XCTAssertTrue(result1)

        #if swift(>=5.0)
        let data = Data([1,2,3])
        #else
        let data = Data(bytes: [1,2,3])
        #endif

        let result2 = pipeline.shouldApply(request: request, data: data, response: response)
        XCTAssertFalse(result2)
        
        try! pipeline.redirect(request: request, data: Data(), response: response) { action in
            switch action {
            case .continueWith(let data, let res):
                XCTAssertEqual(String(data: data, encoding: .utf8), "123")
                XCTAssertEqual(res, response)
            default:
                XCTFail("Pipeline should continue with data and response.")
            }
        }
    }
    
    private func assertJSONText(_ text: String!, equalsTo obj: [String: String]) {
        let rawData = text!.data(using: .utf8)!
        let payload = try! JSONSerialization.jsonObject(with: rawData, options: []) as! [String: String]
        XCTAssertEqual(obj, payload)
    }
}

