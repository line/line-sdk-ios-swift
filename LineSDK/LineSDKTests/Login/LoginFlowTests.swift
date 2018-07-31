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
    
    var window: UIWindow!

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
        XCTAssertEqual(hit, 2)
    }
    
    func testURLSchemeQueryEncode() {
        let baseURL = Constant.lineAppAuthURLv2
        let result = baseURL.appendedURLSchemeQuery(
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
        XCTAssertEqual(items.count, 1)
        
        var hit = 0
        for item in items {
            if (item.name == "loginUrl") {
                hit += 1
                // Should be already fully decoded (no double encoding in the url)
                XCTAssertEqual(item.value, item.value?.removingPercentEncoding)
            }
        }
        XCTAssertEqual(hit, 1)
    }
    
    func testAppUniversalLinkFlow() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let otp = OneTimePassword(otpId: "otpId", otp: "otp")
        let flow = AppUniversalLinkFlow(
            channelID: "123",
            universalLinkURL: URL(string: "https://sample.com/auth"),
            scopes: [.profile, .openID],
            otp: otp,
            processID: "321"
        )
        
        let universal = URL(string: Constant.lineWebAuthUniversalURL)!
        let components = URLComponents(url: flow.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.host, universal.host)
        XCTAssertEqual(components?.path, universal.path)
        
        flow.onNext.delegate(on: self) { (self, started) in
            expect.fulfill()
        }
        flow.start()
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppAuthSchemeFlow() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let otp = OneTimePassword(otpId: "otpId", otp: "otp")
        let flow = AppAuthSchemeFlow(
            channelID: "123",
            universalLinkURL: nil,
            scopes: [.profile, .openID],
            otp: otp,
            processID: "321"
        )
        
        let components = URLComponents(url: flow.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.scheme, Constant.lineAuthV2Scheme)
        XCTAssertEqual(components?.host, "authorize")
        XCTAssertEqual(components?.path, "/")

        flow.onNext.delegate(on: self) { (self, started) in
            expect.fulfill()
        }
        flow.start()
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testWebLoginFlow() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let otp = OneTimePassword(otpId: "otpId", otp: "otp")
        let flow = WebLoginFlow(
            channelID: "123",
            universalLinkURL: nil,
            scopes: [.profile, .openID],
            otp: otp,
            processID: "321"
        )
        
        let webURL = URL(string: Constant.lineWebAuthURL)!
        let components = URLComponents(url: flow.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.host, webURL.host)
        XCTAssertEqual(components?.path, webURL.path)
        
        let rootViewController = setupViewController()

        if #available(iOS 9.0, *) {
            flow.onNext.delegate(on: self) { [unowned flow] (self, next) in
                expect.fulfill()
                self.resetViewController()
                switch next {
                case .safariViewController:
                    XCTAssertEqual(rootViewController.presentedViewController, flow.safariViewController)
                default:
                    XCTFail("Should present a safari web view controller.")
                }
            }
        } else {
            flow.onNext.delegate(on: self) { (self, next) in
                expect.fulfill()
                switch next {
                case .externalSafari:
                    break
                default:
                    XCTFail("Should open in external Safari.")
                }
            }
        }
        
        flow.start(in: rootViewController)
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppSwitchingObserver() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let observer = LoginProcess.AppSwitchingObserver()
        observer.onTrigger.delegate(on: self) { (self, _) in
            expect.fulfill()
        }
        observer.startObserving()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .UIApplicationDidBecomeActive, object: nil)
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppSwitchingObserverInvalid() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let observer = LoginProcess.AppSwitchingObserver()
        observer.onTrigger.delegate(on: self) { (self, _) in
            XCTFail("onTrigger should not called for an invalid observer.")
        }
        observer.startObserving()
        observer.valid = false
        DispatchQueue.main.async { NotificationCenter.default.post(name: .UIApplicationDidBecomeActive, object: nil) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { expect.fulfill() }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func testAppSwitchingObserverRelease() {
        let expect = expectation(description: "\(#file)_\(#line)")
        var observer: LoginProcess.AppSwitchingObserver! = LoginProcess.AppSwitchingObserver()
        weak var ref = observer
        observer.onTrigger.delegate(on: self) { (self, _) in
            observer = nil
        }
        observer.startObserving()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .UIApplicationDidBecomeActive, object: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(ref)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    private func setupViewController() -> UIViewController {
        let rootViewController =  UIViewController()
        if #available(iOS 9.0, *) {
            rootViewController.loadViewIfNeeded()
        } else {
            _ = rootViewController.view
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        return rootViewController
    }
    
    private func resetViewController() {
        window = nil
    }
}




