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
            },
            {
              "displayName": "Original Name",
              "displayNameOverridden": "New Name",
              "userId": "cccc"
            },
          ]
        }
        """
        runTestSuccess(for: r) { response in
            XCTAssertEqual(response.friends.count, 3)
            
            let friend0 = response.friends[0]
            XCTAssertEqual(friend0.userID, "aaaa")
            XCTAssertEqual(friend0.displayName, "Brown")
            XCTAssertEqual(friend0.displayNameOriginal, "Brown")
            XCTAssertEqual(friend0.displayNameOverridden, nil)
            
            let friend1 = response.friends[1]
            XCTAssertEqual(friend1.displayName, "Sally")
            XCTAssertEqual(friend1.displayName, "Sally")
            XCTAssertEqual(friend1.displayNameOriginal, "Sally")
            XCTAssertEqual(friend1.displayNameOverridden, nil)
            
            let friend2 = response.friends[2]
            XCTAssertEqual(friend2.displayName, "New Name")
            XCTAssertEqual(friend2.displayNameOriginal, "Original Name")
            XCTAssertEqual(friend2.displayNameOverridden, "New Name")
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
