//
//  LoginConfigurationTests.swift
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

class LoginConfigurationTests: XCTestCase {

    func testValidCustomizeURL() {
        let config = LoginConfiguration(channelID: "123", universalLinkURL: nil)
        
        let results = [
            "/somePath/",
            "https://example.com",
            "randomUrl://authorize",
            "\(Constant.thirdPartyAppReturnScheme)://somePath/",
            
            "\(Constant.thirdPartyAppReturnScheme)://authorize?hello=world",
            "\(Constant.thirdPartyAppReturnScheme)://authorize",
            "\(Constant.thirdPartyAppReturnScheme.uppercased())://Authorize"
        ].map { config.isValidCustomizeURL(url: URL(string: $0)!) }

        XCTAssertEqual(results, [
            false, false, false, false,
            true,  true,  true
        ])
    }
    
    func testValidUniversalLinkURL() {
        let url = URL(string: "https://example.com/auth/")
        let config = LoginConfiguration(channelID: "123", universalLinkURL: url)
        
        let results = [
            "https://example.com",
            "https://example.com/auth/other",
            "https://domain.com/auth",
            "randomUrl://auth",
            "http://example.com/auth",
            
            "https://example.com/auth",
            "https://example.com/auth?code=123",
            "https://example.com/Auth/?code=123",
            "HTTPS://example.com/auth",
        ].map { config.isValidUniversalLinkURL(url: URL(string: $0)!) }
        XCTAssertEqual(results, [
            false, false, false, false, false,
            true,  true,  true,  true
        ])
    }
    
    func testInvalidUniversalLinkURLIfNotSet() {
        let config = LoginConfiguration(channelID: "123", universalLinkURL: nil)
        let result = config.isValidUniversalLinkURL(url: URL(string: "https://example.com")!)
        XCTAssertEqual(result, false)
    }
}
