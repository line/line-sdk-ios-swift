//
//  WebLoginPage.swift
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

class WebLoginPage: Page {
    
    // MARK: - Element Identifiers
    
    // Sample app elements
    lazy var webLoginButton = app.buttons["Web Login"]
    lazy var cancelButtonJP = app.buttons["キャンセル"]
    lazy var cancelButtonCN = app.buttons["取消"]
    lazy var cancelButtonEN = app.buttons["Cancel"]

    // Safari View Controller elements
    lazy var safariView = app.otherElements["TopBrowserBar"]
    
    // LINE login web form elements
    lazy var emailField = app.webViews.textFields["メールアドレス"]
    lazy var focusedTextField = app.webViews.textFields.element(
        matching: NSPredicate(format: "hasKeyboardFocus == true")
    )

    lazy var passwordField = app.webViews.secureTextFields["パスワード"]
    lazy var focusedSecureTextFields = app.webViews.secureTextFields.element(
        matching: NSPredicate(format: "hasKeyboardFocus == true")
    )

    lazy var loginSubmitButton = app.webViews.buttons["ログイン"]
    lazy var webAllowButton = app.webViews.buttons["許可する"]
    lazy var webCancelButton = app.webViews.buttons["キャンセル"]
    lazy var confirmButton = app.webViews.staticTexts["確認"]
    
    // QR Code login elements
    lazy var qrCodeButton = app.webViews.staticTexts["QRコードログイン"]
    lazy var emailLoginButton = app.webViews.staticTexts["メールアドレスでログイン"]
    lazy var qrCodeImage = app.webViews.images.firstMatch

    // MARK: - Navigation Actions
    
    @discardableResult
    func tapWebLoginButton() -> Self {
        tap(element: webLoginButton)
        return self
    }
    
    @discardableResult
    func waitForSafariViewController(timeout: TimeInterval = 30) -> Self {
        sleep(2) // Allow time for the Safari View Controller to appear
        expect(element: safariView, status: .exist, withIn: timeout)
        return self
    }
    
    @discardableResult
    func dismissSafariViewController() -> Self {
        for cancelButton in [cancelButtonJP, cancelButtonCN, cancelButtonEN] {
            if cancelButton.exists {
                tap(element: cancelButton)
                break
            }
        }
        return self
    }
    
    // MARK: - Login Form Interactions
    
    @discardableResult
    func enterCredentials(email: String, password: String) -> Self {
        // Wait for the web form to load
        expect(element: emailField, status: .exist, withIn: 20)

        // Clear and enter email
        emailField.tap()
        focusedTextField.typeText(email)

        // Clear and enter password
        passwordField.tap()
        focusedSecureTextFields.typeText(password)
        
        return self
    }
    
    @discardableResult
    func submitLogin() -> Self {
        tap(element: loginSubmitButton)
        return self
    }
    
    @discardableResult
    func allowPermissions() -> Self {
        // Wait for permission screen to appear
        expect(element: webAllowButton, status: .exist, withIn: 20)
        tap(element: webAllowButton)
        return self
    }

    @discardableResult
    func rejectPermissions() -> Self {
        // Wait for permission screen to appear
        expect(element: webCancelButton, status: .exist, withIn: 20)
        tap(element: webCancelButton)
        return self
    }

    @discardableResult
    func tapNotSavePasswordIfNeeded() -> Self {
        let notSavePasswordButton = app.alerts.buttons.element(boundBy: 1)
        if notSavePasswordButton.waitForExistence(timeout: 3) {
            tap(element: notSavePasswordButton)
        }
        return self
    }

    @discardableResult
    func confirmLogin() -> Self {
        // Wait for permission screen to appear
        expect(element: confirmButton, status: .exist, withIn: 20)
        tap(element: confirmButton)
        return self
    }
    
    // MARK: - QR Code Login
    
    @discardableResult
    func switchToQRCodeLogin() -> Self {
        tap(element: qrCodeButton)
        expect(element: qrCodeImage, status: .exist, withIn: 20)
        return self
    }
    
    @discardableResult
    func switchToEmailLogin() -> Self {
        tap(element: emailLoginButton)
        expect(element: emailField, status: .exist, withIn: 20)
        return self
    }
    
    // MARK: - Validation Methods
    
    func checkWebLoginButtonExists() {
        expect(element: webLoginButton, status: .exist)
    }
    
    func checkSafariViewControllerPresented() {
        expect(element: safariView, status: .exist)
    }
    
    func checkLoginFormLoaded() {
        expect(element: emailField, status: .exist, withIn: 20)
        expect(element: passwordField, status: .exist)
        expect(element: loginSubmitButton, status: .exist)
    }
    
    func checkPermissionScreenDisplayed() {
        expect(element: webAllowButton, status: .exist, withIn: 20)
    }

    func checkQRCodeDisplayed() {
        expect(element: qrCodeImage, status: .exist)
    }
    
    // MARK: - Complete Login Flow
    
    func performWebLogin(email: String, password: String, allow: Bool) {
        tapWebLoginButton()
        waitForSafariViewController()
        enterCredentials(email: email, password: password)
        submitLogin()

        tapNotSavePasswordIfNeeded()

        // Return to app should happen automatically
        if allow {
            allowPermissions()
        } else {
            rejectPermissions()
        }
        confirmLogin()
    }
    
    func performWebLoginWithWebViewCancel() {
        tapWebLoginButton()
        waitForSafariViewController()
        dismissSafariViewController()
    }
}
