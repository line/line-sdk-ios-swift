//
//  LoginProcessURLResponseTests.swift
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

class LoginProcessURLResponseTests: XCTestCase {
        
    func testInitFromWebResponse() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=abc&friendship_status_changed=true"
        let response = try! LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
        XCTAssertEqual(response.requestToken, "123")
        XCTAssertEqual(response.friendshipStatusChanged, true)
    }
    
    func testInitFromWebResponseWithoutFriendShipStatusChanged() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=abc"
        let response = try! LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
        XCTAssertEqual(response.requestToken, "123")
        XCTAssertNil(response.friendshipStatusChanged)
    }
    
    func testInitFromWebResponseWithInvalidFriendShipStatusChanged() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=abc&friendship_status_changed=hello"
        let response = try! LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
        XCTAssertEqual(response.requestToken, "123")
        XCTAssertNil(response.friendshipStatusChanged)
    }
    
    func testInitFromWebResponseWithoutToken() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?state=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! LineSDKError
            guard case LineSDKError.authorizeFailed(reason: .malformedRedirectURL(let url, let message)) = e else {
                XCTFail("Should be .malformedRedirectURL error")
                return
            }
            XCTAssertEqual(url, URL(string: urlString)!)
            XCTAssertNil(message)
        }
    }
    
    func testInitFromWebStateNotMatch() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "hello")
            XCTFail("Should not init response")
        } catch {
            let e = error as! LineSDKError
            guard case LineSDKError.authorizeFailed(reason: .responseStateValueNotMatching(let expected, let got)) = e else {
                XCTFail("Should be .responseStateValueNotMatching error")
                return
            }
            XCTAssertEqual(expected, "hello")
            XCTAssertEqual(got, "abc")
        }
    }
    
    func testInitFromWebUserCancel() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?error=access_denied&error_description=123&state=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! LineSDKError
            guard case LineSDKError.authorizeFailed(reason: .userCancelled) = e else {
                XCTFail("Should be .userCancelled error")
                return
            }
        }
    }
    
    func testInitFromWebServerError() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?error=server_error&error_description=123&state=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! LineSDKError
            guard case LineSDKError.authorizeFailed(reason: .webLoginError(let error, let errorDescription)) = e else {
                XCTFail("Should be .webLoginError error")
                return
            }
            XCTAssertEqual(error, "server_error")
            XCTAssertEqual(errorDescription, "123")
        }
    }
    
    func testInitFromWebUnknownError() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?error=some_error&error_description=123&state=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! LineSDKError
            guard case LineSDKError.authorizeFailed(reason: .webLoginError(let error, let errorDescription)) = e else {
                XCTFail("Should be .webLoginError error")
                return
            }
            XCTAssertEqual(error, "some_error")
            XCTAssertEqual(errorDescription, "123")
        }
    }
}
