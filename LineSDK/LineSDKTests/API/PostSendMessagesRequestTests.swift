//
//  PostSendMessagesRequestTests.swift
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

extension PostSendMessagesRequest: ResponseDataStub {
    static var success = ""
}

class PostSendMessagesRequestTests: LineSDKAPITests {
    
    let message = TextMessage(text: "hello")
    
    func testSuccessOK() {
        PostSendMessagesRequest.success =
        """
        {
          "status": "ok"
        }
        """
        
        let r = PostSendMessagesRequest(chatID: "123", messages: [message])
        runTestSuccess(for: r) { status in
            switch status.status {
            case .ok: break
            default: XCTFail("The result status should be ok")
            }
        }
    }
    
    func testSuccessDiscarded() {
        PostSendMessagesRequest.success =
        """
        {
          "status": "discarded"
        }
        """
        
        let r = PostSendMessagesRequest(chatID: "123", messages: [message])
        runTestSuccess(for: r) { status in
            switch status.status {
            case .discarded: break
            default: XCTFail("The result status should be discarded")
            }
        }
    }
    
    func testUnknownStatus() {
        PostSendMessagesRequest.success =
        """
        {
          "status": "newStatus"
        }
        """
        
        let r = PostSendMessagesRequest(chatID: "123", messages: [message])
        runTestSuccess(for: r) { status in
            switch status.status {
            case .unknown(let raw):
                XCTAssertEqual(raw, "newStatus")
            default: XCTFail("The result status should be unknown")
            }
        }
    }
}
