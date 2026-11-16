//
//  LoginFlowTests.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

class LoginFlowTests: XCTestCase, ViewControllerCompatibleTest {
    
    var window: UIWindow!

    let parameter = LoginProcess.FlowParameters(
        channelID: "123",
        universalLinkURL: nil,
        scopes: [.profile, .openID],
        pkce: PKCE(),
        processID: "abc",
        nonce: "kkk",
        loginParameter: {
            var p = LoginManager.Parameters()
            p.botPromptStyle = .normal
            return p
        }()
    )

    let parameterWithLanguage = LoginProcess.FlowParameters(
        channelID: "123",
        universalLinkURL: nil,
        scopes: [.profile, .openID],
        pkce: PKCE(),
        processID: "abc",
        nonce: "kkk",
        loginParameter: {
            var p = LoginManager.Parameters()
            p.botPromptStyle = .normal
            p.preferredWebPageLanguage = .chineseSimplified
            return p
        }()
    )

    let parameterWithOnlyWebLogin = LoginProcess.FlowParameters(
        channelID: "123",
        universalLinkURL: nil,
        scopes: [.profile, .openID],
        pkce: PKCE(),
        processID: "abc",
        nonce: "kkk",
        loginParameter: {
            var p = LoginManager.Parameters()
            p.botPromptStyle = .normal
            p.onlyWebLogin = true
            return p
        }()
    )

    let parameterWithPromptBotID = LoginProcess.FlowParameters(
        channelID: "123",
        universalLinkURL: nil,
        scopes: [.profile, .openID],
        pkce: PKCE(),
        processID: "abc",
        nonce: "kkk",
        loginParameter: {
            var p = LoginManager.Parameters()
            p.botPromptStyle = .normal
            p.promptBotID = "@abc123"
            return p
        }()
    )

    let parameterWithInitialQRMethod = LoginProcess.FlowParameters(
        channelID: "123",
        universalLinkURL: nil,
        scopes: [.profile, .openID],
        pkce: PKCE(),
        processID: "abc",
        nonce: "kkk",
        loginParameter: {
            var p = LoginManager.Parameters()
            p.botPromptStyle = .normal
            p.initialWebAuthenticationMethod = .qrCode
            return p
        }()
    )

    // Login URL has a double escaped query.
    func testLoginQueryURLEncode() {
        
        let baseURL = URL(string: Constant.lineWebAuthUniversalURL)!
        let result = baseURL.appendedLoginQuery(parameter)
        
        let urlString = result.absoluteString.removingPercentEncoding
        XCTAssertNotNil(urlString)
        
        let components = URLComponents(url: result, resolvingAgainstBaseURL: false)
        let items = components!.queryItems!
        XCTAssertEqual(items.count, ["loginChannelId", "returnUri"].count)
        
        var item: URLQueryItem

        item = items.first { $0.name == "loginChannelId" }!
        XCTAssertEqual(item.value, "123")

        item = items.first { $0.name == "returnUri" }!
        XCTAssertNotEqual(item.value, item.value?.removingPercentEncoding)

        // Should be already fully decoded (no double encoding in the url)
        XCTAssertEqual(item.value?.removingPercentEncoding,
                       item.value?.removingPercentEncoding?.removingPercentEncoding)
    }

    func testLoginQueryWithLangURLEncode() {

        let baseURL = URL(string: Constant.lineWebAuthUniversalURL)!
        let result = baseURL.appendedLoginQuery(parameterWithLanguage)

        let urlString = result.absoluteString.removingPercentEncoding
        XCTAssertNotNil(urlString)

        let components = URLComponents(url: result, resolvingAgainstBaseURL: false)
        let items = components!.queryItems!
        XCTAssertEqual(items.count, ["loginChannelId", "returnUri", "ui_locales"].count)

        var item: URLQueryItem

        item = items.first { $0.name == "loginChannelId" }!
        XCTAssertEqual(item.value, "123")

        item = items.first { $0.name == "returnUri" }!
        XCTAssertNotEqual(item.value, item.value?.removingPercentEncoding)

        // Should be already fully decoded (no double encoding in the url)
        XCTAssertEqual(item.value?.removingPercentEncoding,
                       item.value?.removingPercentEncoding?.removingPercentEncoding)

        item = items.first { $0.name == "ui_locales" }!
        XCTAssertEqual(item.value, "zh-Hans")
    }

    func testLoginQueryWithOnlyWebLoginURLEncode() {

        let baseURL = URL(string: Constant.lineWebAuthUniversalURL)!
        let result = baseURL.appendedLoginQuery(parameterWithOnlyWebLogin)

        let urlString = result.absoluteString.removingPercentEncoding
        XCTAssertNotNil(urlString)

        let components = URLComponents(url: result, resolvingAgainstBaseURL: false)
        let items = components!.queryItems!
        XCTAssertEqual(items.count, ["loginChannelId", "returnUri", "disable_ios_auto_login"].count)

        var item: URLQueryItem

        item = items.first { $0.name == "loginChannelId" }!
        XCTAssertEqual(item.value, "123")

        item = items.first { $0.name == "returnUri" }!
        XCTAssertNotEqual(item.value, item.value?.removingPercentEncoding)

        item = items.first { $0.name == "disable_ios_auto_login" }!
        XCTAssertEqual(item.value, "true")
    }

    func testLoginQueryWithPromptBotID() {
        let baseURL = URL(string: Constant.lineWebAuthUniversalURL)!
        let result = baseURL.appendedLoginQuery(parameterWithPromptBotID)

        let urlString = result.absoluteString.removingPercentEncoding
        XCTAssertNotNil(urlString)

        let components = URLComponents(url: result, resolvingAgainstBaseURL: false)
        let items = components!.queryItems!
        XCTAssertEqual(items.count, ["loginChannelId", "returnUri"].count)

        let item = items.first { $0.name == "returnUri" }!
        XCTAssertNotEqual(item.value, item.value?.removingPercentEncoding)
        XCTAssertTrue(item.value!.removingPercentEncoding!.contains("prompt_bot_id=@abc123"))
    }

    func testAppUniversalLinkFlow() {
        let expect = expectation(description: "\(#file)_\(#line)")

        let opener = MockApplicationOpener()
        let flow = AppUniversalLinkFlow(parameter: parameter, applicationOpener: opener)
        let universal = URL(string: Constant.lineWebAuthUniversalURL)!
        let components = URLComponents(url: flow.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.host, universal.host)
        XCTAssertEqual(components?.path, universal.path)
        
        flow.onNext.delegate(on: self) { (self, started) in
            expect.fulfill()
        }
        flow.start()
        
        waitForExpectations(timeout: 3.0, handler: nil)
        XCTAssertEqual(opener.openCallCount, 1)
        XCTAssertEqual(opener.lastOpenedURL, flow.url)
        XCTAssertEqual(opener.lastOptions?[.universalLinksOnly] as? Bool, true)
        XCTAssertNil(components?.queryItems?.first { $0.name == "disable_ios_auto_login" })
    }
    
    func testWebLoginFlowDisablesAppAutoLogin() {
        for parameters in [parameter, parameterWithOnlyWebLogin] {
            let flow = WebLoginFlow(parameter: parameters)
            let components = URLComponents(url: flow.url, resolvingAgainstBaseURL: false)
            let items = components?.queryItems?.filter { $0.name == "disable_ios_auto_login" }

            XCTAssertEqual(items?.count, 1)
            XCTAssertEqual(items?.first?.value, "true")
        }
    }

    func testWebLoginFlowPreservesAuthorizationParameters() throws {
        let flow = WebLoginFlow(parameter: parameter)
        let components = URLComponents(url: flow.url, resolvingAgainstBaseURL: false)
        let returnURI = try XCTUnwrap(components?.queryItems?.first { $0.name == "returnUri" }?.value)
        let items = try XCTUnwrap(URLComponents(string: returnURI)?.queryItems)
        let values = Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value) })

        XCTAssertEqual(values["client_id"], parameter.channelID)
        XCTAssertEqual(values["state"], parameter.processID)
        XCTAssertEqual(values["code_challenge"], parameter.pkce.codeChallenge)
        XCTAssertEqual(values["code_challenge_method"], parameter.pkce.codeChallengeMethod)
        XCTAssertEqual(values["nonce"], parameter.nonce)
        XCTAssertEqual(values["redirect_uri"], Constant.thirdPartyAppReturnURL)
    }

    func testWebLoginFlow() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let flow = WebLoginFlow(parameter: parameter)
        let webURL = URL(string: Constant.lineWebAuthURL)!
        let components = URLComponents(url: flow.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.host, webURL.host)
        XCTAssertEqual(components?.path, webURL.path)
        
        let rootViewController = setupViewController()

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
        
        flow.start(in: rootViewController)
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testWebLoginFlowWithQRCodeFirst() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let flow = WebLoginFlow(parameter: parameterWithInitialQRMethod)
        let webURL = URL(string: Constant.lineWebAuthURL)!
        let components = URLComponents(url: flow.url, resolvingAgainstBaseURL: false)
        XCTAssertEqual(components?.scheme, "https")
        XCTAssertEqual(components?.host, webURL.host)
        XCTAssertEqual(components?.path, webURL.path)

        XCTAssertEqual(components?.fragment, "/qr")
        XCTAssertTrue(flow.url.absoluteString.contains("#/qr"))

        let rootViewController = setupViewController()

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

        flow.start(in: rootViewController)
        waitForExpectations(timeout: 3.0, handler: nil)
    }

    func testAppSwitchingObserver() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let observer = LoginProcess.AppSwitchingObserver()
        observer.onTrigger.delegate(on: self) { (self, _) in
            expect.fulfill()
        }
        observer.startObserving()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    func testAppSwitchingObserverInvalid() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let observer = LoginProcess.AppSwitchingObserver()
        observer.onTrigger.delegate(on: self) { (self, _) in
            XCTFail("onTrigger should not called for an invalid observer.")
        }
        observer.startObserving()
        observer.valid = false
        DispatchQueue.main.async { NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { expect.fulfill() }
        waitForExpectations(timeout: 3.0, handler: nil)
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
            NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertNil(ref)
            expect.fulfill()
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    // MARK: - Window Management Tests
    
    func testFindKeyWindowWithCreatedWindow() {
        let testWindow = UIWindow(frame: UIScreen.main.bounds)
        testWindow.windowLevel = .normal
        testWindow.makeKeyAndVisible()
        
        let foundWindow = UIWindow.findKeyWindow()
        XCTAssertNotNil(foundWindow, "Should find the created window")
        XCTAssertEqual(foundWindow, testWindow, "Should return the test window")
        XCTAssertEqual(foundWindow?.windowLevel, .normal, "Window should be at normal level")
        XCTAssertTrue(foundWindow?.isKeyWindow == true, "Found window should be key window")
        
        testWindow.isHidden = true
    }
    
    func testTopMostViewControllerWithSetup() {
        let rootViewController = setupViewController()
        
        let topMost = UIViewController.topMost
        XCTAssertNotNil(topMost, "Should find top most view controller with setup window")
        XCTAssertEqual(topMost, rootViewController, "Top most should be the root view controller")
        
        resetViewController()
    }
    
    func testTopMostViewControllerWithPresentation() {
        let rootViewController = setupViewController()
        let presentedViewController = UIViewController()
        
        let expectPresent = expectation(description: "present")
        rootViewController.present(presentedViewController, animated: false) {
            expectPresent.fulfill()
        }
        wait(for: [expectPresent], timeout: 1.0)
        
        let topMost = UIViewController.topMost
        XCTAssertNotNil(topMost, "Should find top most view controller")
        XCTAssertEqual(topMost, presentedViewController, "Top most should be the presented view controller")
        
        let expectDismiss = expectation(description: "dismiss")
        presentedViewController.dismiss(animated: false) {
            expectDismiss.fulfill()
        }
        wait(for: [expectDismiss], timeout: 1.0)
        
        resetViewController()
    }
    
    func testTopMostViewControllerWithNestedPresentation() {
        let rootViewController = setupViewController()
        let firstPresentedViewController = UIViewController()
        let secondPresentedViewController = UIViewController()
        
        let expectFirstPresent = expectation(description: "first present")
        rootViewController.present(firstPresentedViewController, animated: false) {
            expectFirstPresent.fulfill()
        }
        wait(for: [expectFirstPresent], timeout: 1.0)
        
        let expectSecondPresent = expectation(description: "second present")
        firstPresentedViewController.present(secondPresentedViewController, animated: false) {
            expectSecondPresent.fulfill()
        }
        wait(for: [expectSecondPresent], timeout: 1.0)
        
        let topMost = UIViewController.topMost
        XCTAssertNotNil(topMost, "Should find top most view controller")
        XCTAssertEqual(topMost, secondPresentedViewController, "Top most should be the deepest presented view controller")
        
        let expectDismissSecond = expectation(description: "dismiss second")
        secondPresentedViewController.dismiss(animated: false) {
            expectDismissSecond.fulfill()
        }
        wait(for: [expectDismissSecond], timeout: 1.0)
        
        let expectDismissFirst = expectation(description: "dismiss first")
        firstPresentedViewController.dismiss(animated: false) {
            expectDismissFirst.fulfill()
        }
        wait(for: [expectDismissFirst], timeout: 1.0)
        
        resetViewController()
    }
    
    func testWindowWithoutRootViewController() {
        let testWindow = UIWindow(frame: UIScreen.main.bounds)
        testWindow.windowLevel = .normal
        testWindow.makeKeyAndVisible()
        
        let topMost = UIViewController.topMost
        XCTAssertNil(topMost, "Should return nil when window has no root view controller")
        
        testWindow.isHidden = true
    }
}




