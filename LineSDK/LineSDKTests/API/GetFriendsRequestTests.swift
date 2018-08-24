//
//  GetFriendsRequestTests.swift
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

extension GetFriendsRequest: ResponseDataStub {
    static var success = ""
}

class GetFriendsRequestTests: APITests {

    func testSuccess() {

        let r = GetFriendsRequest()
        GetFriendsRequest.success =
        """
        {
          "friends": [
            {
              "displayName": "Brown",
              "pictureUrl": "https://example.com/abc",
              "userId": "aaaa"
            },
            {
              "displayName": "Sally",
              "userId": "cccc"
            }
          ]
        }
        """
        runTestSuccess(for: r) { response in
            XCTAssertEqual(response.friends.count, 2)
            XCTAssertEqual(response.friends.first?.userID, "aaaa")
        }
    }

    func testPageTokenExistence() {
        let r = GetFriendsRequest()

        /// pageToken exists
        GetFriendsRequest.success =
        """
        {
            "friends": [
                {
                    "displayName": "Brown",
                    "pictureUrl": "https://example.com/abc",
                    "userId": "bbbb"
                }
            ],
            "pageToken": "foo"
        }
        """
        runTestSuccess(for: r) { response in
            XCTAssertEqual(response.friends.count, 1)
            XCTAssertEqual(response.friends.first?.userID, "bbbb")
            XCTAssertEqual(response.pageToken, "foo")
        }

        /// pageToken not exists
        GetFriendsRequest.success =
        """
        {
            "friends": [
                {
                "displayName": "Brown",
                "pictureUrl": "https://example.com/abc",
                "userId": "cccc"
                }
            ],
        }
        """
        runTestSuccess(for: r) { response in
            XCTAssertEqual(response.friends.count, 1)
            XCTAssertEqual(response.friends.first?.userID, "cccc")
            XCTAssertNil(response.pageToken)
        }
    }
}
