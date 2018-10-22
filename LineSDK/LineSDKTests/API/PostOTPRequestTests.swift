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

class PostOTPRequestTests: APITests {
        
    func testSuccess() {
        let request = PostOTPRequest(channelID: config.channelID)
        runTestSuccess(for: request) { result in
            XCTAssertEqual(result.otpId, "7IMDGquTwIkgPGM2Z0ZXIGYnhIo=")
            XCTAssertEqual(result.otp, "mggOa8NxWrrlcd0rhLTt")
        }
    }
    
    func testFail() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let session = Session.stub(configuration: config, string: PostOTPRequest.fail, statusCode: 400)
        session.send(PostOTPRequest(channelID: config.channelID)) { result in

            guard case .responseFailed(
                reason: .invalidHTTPStatusAPIError(let detail)) = result.error! else
            {
                XCTFail("Error reason should be .invalidHTTPStatusAPIError")
                return
            }
            
            XCTAssertEqual(detail.code, 400)
            XCTAssertEqual(detail.error!.error, "invalid_request")
            XCTAssertEqual(detail.error!.detail, "some error")
            
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
