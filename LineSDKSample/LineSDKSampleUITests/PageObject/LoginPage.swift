//
//  LoginPage.swift
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

class LoginPage: Page {
    
    var okButton: XCUIElement { app.buttons["OK"] }
    var lineLoginButton: XCUIElement { app.buttons["login.button"] }
    var lineLogoutButton: XCUIElement { app.navigationBars.buttons["Logout"] }
    var errorAlert: XCUIElement { app.alerts["Error"] }

    @discardableResult
    func tapLoginButton() -> Self {
        tap(element: lineLoginButton)
        return self
    }
    
    func tapLogoutButton() {
        tap(element: lineLogoutButton)
    }
    
    @discardableResult
    func isLineLoginButtonExists() -> Bool {
        return lineLoginButton.exists
    }
    
    @discardableResult
    func isLineLogoutButtonExists() -> Bool{
        return lineLogoutButton.exists
    }

    func dismissSuccessAlert() {
        expect(element: okButton, status: .exist)
        tap(element: okButton)
    }

    func dismissErrorAlert() {
        expect(element: errorAlert, status: .exist)
        tap(element: errorAlert.buttons["OK"])
    }

    func checkLineLoginButtonExists() {
        expect(element: lineLoginButton, status: .exist)
    }
    
    func checkLineLogoutButtonExists() {
        expect(element: lineLogoutButton, status: .exist)
    }
        
    func logout() {
        tapLogoutButton()
        tap(element: app.alerts.buttons["Logout"])
        tap(element: app.alerts.buttons["OK"])
    }
    
    func login() {
        tapLoginButton()
        // Open LINE
        let line = XCUIApplication(bundleIdentifier: "jp.naver.line")
        tap(element: line.buttons["許可する"])
        tap(element: line.staticTexts["確認"])
        tap(element: line.buttons["開く"])
        
        // click ok button in App
        tap(element: okButton)
    }
}
