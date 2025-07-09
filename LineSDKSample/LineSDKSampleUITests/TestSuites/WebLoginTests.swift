//
//  WebLoginTests.swift
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

class WebLoginTests: XCTestCase {

    let app = XCUIApplication()

    // Test credentials - loaded from environment variables for security
    struct TestCredentials {
        static let validEmail: String = {
            guard let email = ProcessInfo.processInfo.environment["LINE_SDK_TEST_EMAIL"] else {
                fatalError("""
                Missing test credentials. Please set the following environment variables:
                - LINE_SDK_TEST_EMAIL: Test email for web login
                - LINE_SDK_TEST_PASSWORD: Test password for web login
                
                For local Xcode testing, you can set these in the config file:
                1. Open LineSDKSample/LineSDKSampleUITests/env.xcconfig
                2. Set correct LINE_SDK_TEST_EMAIL and LINE_SDK_TEST_PASSWORD values
                
                For CI/CD, configure these as secure environment variables.
                """)
            }
            return email
        }()
        
        static let validPassword: String = {
            guard let password = ProcessInfo.processInfo.environment["LINE_SDK_TEST_PASSWORD"] else {
                fatalError("""
                Missing test credentials. Please set the following environment variables:
                - LINE_SDK_TEST_EMAIL: Test email for web login
                - LINE_SDK_TEST_PASSWORD: Test password for web login
                
                For local Xcode testing, you can set these in the config file:
                1. Open LineSDKSample/LineSDKSampleUITests/env.xcconfig
                2. Set correct LINE_SDK_TEST_EMAIL and LINE_SDK_TEST_PASSWORD values
                
                For CI/CD, configure these as secure environment variables.
                """)
            }
            return password
        }()
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false

        app.launch()

        // Ensure we start with a clean state
        let loginPage = LoginPage(app)
        if loginPage.isLineLogoutButtonExists() {
            loginPage.logout()
        }
    }
    
    override func tearDownWithError() throws {
        // Capture screenshot on test failure
        if let failureCount = testRun?.failureCount, failureCount > 0 {
            let screenshot = XCUIScreen.main.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "TestFailure_\(self.name)_\(Date().timeIntervalSince1970)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        
        try super.tearDownWithError()
    }

    override func tearDown() {
        super.tearDown()

        // Clean up after each test
        let loginPage = LoginPage(app)
        if loginPage.isLineLogoutButtonExists() {
            loginPage.logout()
        }
    }

    // MARK: - Basic Web Login Tests

    func testWebLoginButtonExists() {
        let webLoginPage = WebLoginPage(app)
        webLoginPage.checkWebLoginButtonExists()
    }

    func testWebLoginOpenSafariViewController() {
        let webLoginPage = WebLoginPage(app)
        webLoginPage.tapWebLoginButton()
        webLoginPage.checkSafariViewControllerPresented()
    }

    func testWebLoginFormLoads() {
        let webLoginPage = WebLoginPage(app)
        webLoginPage.tapWebLoginButton()
        webLoginPage.waitForSafariViewController()
        webLoginPage.checkLoginFormLoaded()
    }

    // MARK: - Successful Login Tests

    func testWebLogin() {
        // Web login will start to require Captcha verification when failure. So we need to ensure that
        // the good path is tested first.
        webLoginSuccessful()
        let loginPage = LoginPage(app)
        if loginPage.isLineLogoutButtonExists() {
            loginPage.logout()
        }
        webLoginCancelFromWebView()
    }

    func webLoginSuccessful() {
        let webLoginPage = WebLoginPage(app)

        webLoginPage.performWebLogin(
            email: TestCredentials.validEmail,
            password: TestCredentials.validPassword,
            allow: true
        )

        // Verify login success in the main app
        let loginPage = LoginPage(app)
        loginPage.dismissSuccessAlert()
        loginPage.checkLineLogoutButtonExists()
    }

    func webLoginCancelFromWebView() {
        let webLoginPage = WebLoginPage(app)

        webLoginPage.performWebLoginWithWebViewCancel()

        // Should return to main app without login
        let loginPage = LoginPage(app)
        loginPage.dismissErrorAlert()
        loginPage.checkLineLoginButtonExists()
    }

    func testWebLoginCancelFromAuthPage() {
        let webLoginPage = WebLoginPage(app)

        webLoginPage.performWebLogin(
            email: TestCredentials.validEmail,
            password: TestCredentials.validPassword,
            allow: false
        )

        // Should return to main app without login
        let loginPage = LoginPage(app)
        loginPage.dismissErrorAlert()
        loginPage.checkLineLoginButtonExists()
    }

    // MARK: - QR Code Login Tests

    func testQRCodeLoginInterface() {
        let webLoginPage = WebLoginPage(app)

        webLoginPage.tapWebLoginButton()
        webLoginPage.waitForSafariViewController()
        webLoginPage.switchToQRCodeLogin()
        webLoginPage.checkQRCodeDisplayed()
    }

    func testSwitchBetweenEmailAndQRCode() {
        let webLoginPage = WebLoginPage(app)

        webLoginPage.tapWebLoginButton()
        webLoginPage.waitForSafariViewController()

        // Start with email login
        webLoginPage.checkLoginFormLoaded()

        // Switch to QR code
        webLoginPage.switchToQRCodeLogin()
        webLoginPage.checkQRCodeDisplayed()

        // Switch back to email
        webLoginPage.switchToEmailLogin()
        webLoginPage.checkLoginFormLoaded()
    }
}
