//
//  LoginFlowTests.swift
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

class LoginFlowTests: XCTestCase {

    func testLoginQueryURLEncode() {
        let baseURL = URL(string: Constant.lineWebAuthUniversalURL)!
        let result = baseURL.appendedLoginQuery(
            channelID: "123",
            universalLinkURL: nil,
            scopes: [.profile, .openID],
            otpID: "321",
            state: "abc"
        )
        let urlString = result.absoluteString.removingPercentEncoding
        XCTAssertNotNil(urlString)
        
        let components = URLComponents(url: result, resolvingAgainstBaseURL: false)
        let items = components!.queryItems!
        XCTAssertEqual(items.count, 2)
        
        var hit = 0
        for item in items {
            if item.name == "loginChannelId" {
                hit += 1
                XCTAssertEqual(item.value, "123")
            }
            if (item.name == "returnUri") {
                hit += 1
                // Should be already fully decoded (no double encoding in the url)
                XCTAssertEqual(item.value, item.value?.removingPercentEncoding)
            }
        }
    }
}
