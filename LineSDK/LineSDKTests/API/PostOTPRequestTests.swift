//
//  PostOTPRequestTests.swift
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

extension PostOTPRequest: ResponseDataStub {
    static let success = """
    {
        "otpId": "7IMDGquTwIkgPGM2Z0ZXIGYnhIo=",
        "otp": "mggOa8NxWrrlcd0rhLTt"
    }
    """
    
    static let fail = """
    {
        "error": "invalid_request",
        "error_description": "some error"
    }
    """
}

class PostOTPRequestTests: XCTestCase {
    
    let config = LoginConfiguration(channelID: "123", universalLinkURL: nil)
    
    func testSuccess() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let session = Session.stub(configuration: config, string: PostOTPRequest.success)
        session.send(PostOTPRequest(channelID: config.channelID)) { result in
            XCTAssertEqual(result.value!.otpId, "7IMDGquTwIkgPGM2Z0ZXIGYnhIo=")
            XCTAssertEqual(result.value!.otp, "mggOa8NxWrrlcd0rhLTt")
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testFail() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let session = Session.stub(configuration: config, string: PostOTPRequest.fail, statusCode: 400)
        session.send(PostOTPRequest(channelID: config.channelID)) { result in
            
            guard let e = result.error as? LineSDKError else {
                XCTFail("Error should be a LineSDKError")
                return
            }
            
            guard case .responseFailed(
                reason: .invalidHTTPStatusAuth(
                    code: let code,
                    error: let error,
                    raw: _)) = e else
            {
                XCTFail("Error reason should be .invalidHTTPStatusAuth")
                return
            }
            
            XCTAssertEqual(code, 400)
            XCTAssertEqual(error.error, "invalid_request")
            XCTAssertEqual(error.errorDescription, "some error")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
