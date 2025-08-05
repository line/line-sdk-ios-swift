//
//  LoginButtonTests.swift
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

@MainActor
class LoginButtonTests: XCTestCase, ViewControllerCompatibleTest {
    
    var window: UIWindow!
    var loginButton: LoginButton!
    
    override func setUp() async throws {
        let url = URL(string: "https://example.com/auth")
        LoginManager.shared.setup(channelID: "123", universalLinkURL: url)
        loginButton = LoginButton()
    }
    
    override func tearDown() async throws {
        LoginManager.shared.reset()
        resetViewController()
        loginButton = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertEqual(loginButton.permissions, [.profile])
        XCTAssertEqual(loginButton.buttonSize, .normal)
        XCTAssertEqual(loginButton.accessibilityLabel, "login.button")
        XCTAssertNotNil(loginButton.titleLabel?.font)
        XCTAssertEqual(loginButton.titleColor(for: .normal), .white)
        XCTAssertEqual(loginButton.titleLabel?.textAlignment, .center)
    }
    
    // MARK: - Button Text Tests
    
    func testButtonTextCustomization() {
        let customText = "Custom Login Text"
        loginButton.buttonText = customText
        
        XCTAssertEqual(loginButton.title(for: .normal), customText)
    }
    
    func testIntrinsicContentSize() {
        let initialSize = loginButton.intrinsicContentSize
        XCTAssertTrue(initialSize.width > 0)
        XCTAssertTrue(initialSize.height > 0)
        
        loginButton.buttonSize = .small
        let smallSize = loginButton.intrinsicContentSize
        XCTAssertTrue(smallSize.height < initialSize.height)
        
        loginButton.buttonText = "Very Long Custom Login Button Text"
        let longTextSize = loginButton.intrinsicContentSize
        XCTAssertTrue(longTextSize.width > smallSize.width)
    }
    
    // MARK: - Permission Tests
    
    func testPermissionsProperty() {
        let permissions: Set<LoginPermission> = [.profile, .openID, .email]
        loginButton.permissions = permissions
        
        XCTAssertEqual(loginButton.permissions, permissions)
    }
    
    // MARK: - Parameters Tests
    
    func testParametersProperty() {
        var parameters = LoginManager.Parameters()
        parameters.onlyWebLogin = true
        parameters.botPromptStyle = .aggressive
        
        loginButton.parameters = parameters
        
        XCTAssertEqual(loginButton.parameters.onlyWebLogin, true)
        XCTAssertEqual(loginButton.parameters.botPromptStyle, .aggressive)
    }
    
    // MARK: - Presenting View Controller Tests
    
    func testPresentingViewController() {
        let viewController = UIViewController()
        loginButton.presentingViewController = viewController
        
        XCTAssertEqual(loginButton.presentingViewController, viewController)
    }
    
    // MARK: - Delegate Tests
    
    func testDelegateAssignment() {
        let delegate = MockLoginButtonDelegate()
        loginButton.delegate = delegate
        
        XCTAssertTrue(loginButton.delegate === delegate)
    }
    
    // MARK: - Login Action Tests
    
    func testLoginAction() {
        let viewController = setupViewController()
        loginButton.presentingViewController = viewController
        loginButton.permissions = [.profile, .openID]
        
        XCTAssertFalse(LoginManager.shared.isAuthorizing)
        
        loginButton.login()
        
        XCTAssertTrue(LoginManager.shared.isAuthorizing)
        XCTAssertNotNil(LoginManager.shared.currentProcess)
    }
    
    // MARK: - Style Update Tests
    
    func testStyleUpdateOnButtonSizeChange() {
        let originalSize = loginButton.frame.size
        
        loginButton.buttonSize = .small
        loginButton.updateButtonStyle()
        
        // The frame size should be updated after style change
        let newSize = loginButton.frame.size
        XCTAssertNotEqual(originalSize, newSize)
    }
    
    func testStyleUpdateOnButtonTextChange() {
        let originalSize = loginButton.frame.size
        
        loginButton.buttonText = "Different Text"
        
        // The frame size should be updated after text change
        let newSize = loginButton.frame.size
        XCTAssertNotEqual(originalSize, newSize)
    }

    // MARK: - Accessibility Tests
    
    func testAccessibilityConfiguration() {
        XCTAssertEqual(loginButton.accessibilityLabel, "login.button")
        
        // Test custom accessibility label
        loginButton.accessibilityLabel = "Custom Login"
        XCTAssertEqual(loginButton.accessibilityLabel, "Custom Login")
    }
    
    // MARK: - UI Configuration Tests
    
    func testTitleEdgeInsets() {
        loginButton.buttonSize = .normal
        loginButton.updateButtonStyle()
        
        let insets = loginButton.titleEdgeInsets
        XCTAssertTrue(insets.left > 0)
        XCTAssertTrue(insets.right > 0)
        XCTAssertTrue(insets.top > 0)
        XCTAssertTrue(insets.bottom > 0)
    }
    
    func testBackgroundImages() {
        loginButton.buttonSize = .normal
        loginButton.updateButtonStyle()
        
        XCTAssertNotNil(loginButton.backgroundImage(for: .normal))
        XCTAssertNotNil(loginButton.backgroundImage(for: .highlighted))
        XCTAssertNotNil(loginButton.backgroundImage(for: .disabled))
    }
}

// MARK: - Mock Delegate

private class MockLoginButtonDelegate: LoginButtonDelegate {

    func loginButtonDidStartLogin(_ button: LoginButton) { }

    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) { }

    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) { }
}
