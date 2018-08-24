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
    
    func testInitFromClientResponse() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?resultCode=SUCCESS&resultMessage=abc&requestToken=123"
        let response = try! LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "state")
        XCTAssertEqual(response.requestToken, "123")
    }
    
    func testInitFromClientResponseWithoutToken() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?resultCode=SUCCESS&resultMessage=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .malformedRedirectURL(let url, let message)) = e else {
                XCTFail("Should be .malformedRedirectURL error")
                return
            }
            XCTAssertEqual(url, URL(string: urlString)!)
            XCTAssertEqual(message, "abc")
        }
    }
    
    func testInitFromClientUserCancel() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?resultCode=CANCELLED&resultMessage=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .userCancelled) = e else {
                XCTFail("Should be .userCancelled error")
                return
            }
        }
    }
    
    func testInitFromClientUserDisallow() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?resultCode=DISALLOWED&resultMessage=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .userCancelled) = e else {
                XCTFail("Should be .userCancelled error")
                return
            }
        }
    }
    
    func testInitFromClientOtherErrorCode() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?resultCode=INVALIDPARAM&resultMessage=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .lineClientError(let code, let message)) = e else {
                XCTFail("Should be .lineClientError error")
                return
            }
            XCTAssertEqual(code, "INVALIDPARAM")
            XCTAssertEqual(message, "abc")
        }
    }
    
    func testInitFromClientUnknownCode() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?resultCode=UNKNOWN&resultMessage=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .invalidLineURLResultCode(let code)) = e else {
                XCTFail("Should be .invalidLineURLResultCode error")
                return
            }
            XCTAssertEqual(code, "UNKNOWN")
        }
    }
    
    func testInitFromWebResponse() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=abc"
        let response = try! LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
        XCTAssertEqual(response.requestToken, "123")
    }
    
    func testInitFromWebResponseWithoutToken() {
        let urlString = "\(Constant.thirdPartyAppReturnURL)?state=abc"
        do {
            _ = try LoginProcessURLResponse(from: URL(string: urlString)!, validatingWith: "abc")
            XCTFail("Should not init response")
        } catch {
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .malformedRedirectURL(let url, let message)) = e else {
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
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .responseStateValueNotMatching(let expected, let got)) = e else {
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
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .userCancelled) = e else {
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
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .webLoginError(let error, let errorDescription)) = e else {
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
            let e = error as! SDKError
            guard case SDKError.authorizeFailed(reason: .webLoginError(let error, let errorDescription)) = e else {
                XCTFail("Should be .webLoginError error")
                return
            }
            XCTAssertEqual(error, "some_error")
            XCTAssertEqual(errorDescription, "123")
        }
    }
}
