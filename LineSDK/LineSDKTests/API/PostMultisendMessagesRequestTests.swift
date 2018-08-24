//
//  PostMultisendMessagesRequestTests.swift
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

extension PostMultisendMessagesRequest: ResponseDataStub {
    static var success = ""
}

class PostMultisendMessagesRequestTests: APITests {
    
    let message = TextMessage(text: "hello")
    
    func testAllSuccess() {
        PostMultisendMessagesRequest.success =
        """
        {
          "results": [
            {
              "to": "123",
              "status": "ok"
            },
            {
              "to": "abc",
              "status": "ok"
            }
          ]
        }
        """
        let r = PostMultisendMessagesRequest(userIDs: ["123", "456"], messages: [message])
        
        runTestSuccess(for: r) { result in
            XCTAssertEqual(result.results.count, 2)
            
            XCTAssertEqual(result.results[0].to, "123")
            XCTAssertTrue(result.results[0].status.isOK)
            
            XCTAssertEqual(result.results[1].to, "abc")
            XCTAssertTrue(result.results[1].status.isOK)
        }
    }
    
    func testAllDiscarded() {
        PostMultisendMessagesRequest.success =
        """
        {
          "results": [
            {
              "to": "123",
              "status": "discarded"
            },
            {
              "to": "abc",
              "status": "discarded"
            }
          ]
        }
        """
        let r = PostMultisendMessagesRequest(userIDs: ["123", "456"], messages: [message])
        
        runTestSuccess(for: r) { result in
            XCTAssertEqual(result.results.count, 2)
            
            XCTAssertEqual(result.results[0].to, "123")
            XCTAssertFalse(result.results[0].status.isOK)
            
            XCTAssertEqual(result.results[1].to, "abc")
            XCTAssertFalse(result.results[1].status.isOK)
        }
    }
    
    func testPartitialSuccess() {
        PostMultisendMessagesRequest.success =
        """
        {
          "results": [
            {
              "to": "123",
              "status": "ok"
            },
            {
              "to": "abc",
              "status": "discarded"
            }
          ]
        }
        """
        let r = PostMultisendMessagesRequest(userIDs: ["123", "456"], messages: [message])
        
        runTestSuccess(for: r) { result in
            XCTAssertEqual(result.results.count, 2)
            
            XCTAssertEqual(result.results[0].to, "123")
            XCTAssertTrue(result.results[0].status.isOK)
            
            XCTAssertEqual(result.results[1].to, "abc")
            XCTAssertFalse(result.results[1].status.isOK)
        }
    }
    
}
