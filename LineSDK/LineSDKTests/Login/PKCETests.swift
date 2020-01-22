//
//  PKCETests.swift
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

class PKCETests: XCTestCase {

    /// code_verifier
    /// high-entropy cryptographic random STRING
    /// with a minimum length of 43 characters and a maximum length of 128 characters
    ///
    /// Ref: https://tools.ietf.org/html/rfc7636#section-4.1
    ///
    func testCodeVerifierLength() {
        for _ in 0...1000 {
            autoreleasepool {
                let codeVerifier = PKCE().codeVerifier
                XCTAssertTrue(43...128 ~= codeVerifier.count)
            }
        }
    }

    func testCodeChallenge() {
        let codeVerifier = "ksl2M8Qvw6Ith2hYslVx7XUmtDjt2RvVUzMk8UUgQHc"
        let codeChallenge = PKCE.generateCodeChallenge(codeVerifier: codeVerifier)
        XCTAssertEqual(codeChallenge, "x0ecinHXuDev1f89OvD8rzH4FzKNiv2I07qIdZSuStA")
    }
}
