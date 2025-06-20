//
//  LoginManagerTests.swift
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

let sampleFlowParameters = LoginProcess.FlowParameters(
        channelID: "",
        universalLinkURL: nil,
        scopes: [],
        pkce: .init(),
        processID: "",
        nonce: nil,
        loginParameter: .init()
)

@MainActor
class LoginManagerTests: XCTestCase, ViewControllerCompatibleTest {
    
    var window: UIWindow!
    
    override func setUp() {
        let url = URL(string: "https://example.com/auth")
        LoginManager.shared.setup(channelID: "123", universalLinkURL: url)
    }
    
    override func tearDown() async throws {
        LoginManager.shared.reset()
        resetViewController()
    }
    
    func testSetupLoginManager() {
        XCTAssertNotNil(Session.shared)
        XCTAssertNotNil(AccessTokenStore.shared)
        XCTAssertNotNil(LoginConfiguration.shared)
        
        XCTAssertTrue(LoginManager.shared.isSetupFinished)
    }
    
    func testLoginAction() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        XCTAssertFalse(LoginManager.shared.isAuthorized)
        XCTAssertFalse(LoginManager.shared.isAuthorizing)
        
        let delegateStub = SessionDelegateStub(stubs: [
            .init(data: PostExchangeTokenRequest.successData, responseCode: 200),
            .init(data: GetUserProfileRequest.successData, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )

        var process: LoginProcess!
        process = LoginManager.shared.login(permissions: [.profile], in: setupViewController()) {
            loginResult in
            XCTAssertNotNil(loginResult.value)
            
            let result = loginResult.value!
            XCTAssertEqual(result.accessToken.value, PostExchangeTokenRequest.successToken)
            XCTAssertEqual(AccessTokenStore.shared.current, result.accessToken)
            
            XCTAssertTrue(LoginManager.shared.isAuthorized)
            XCTAssertFalse(LoginManager.shared.isAuthorizing)

            // IDTokenNonce should be `nil` when `.openID` not required.
            XCTAssertNil(result.IDTokenNonce)

            XCTAssertEqual(process.loginRoute, .appUniversalLink)

            try! AccessTokenStore.shared.removeCurrentAccessToken()
            expect.fulfill()
        }!

        // Set a sample value for checking `loginRoute` in the result.
        process.appUniversalLinkFlow = AppUniversalLinkFlow(parameter: sampleFlowParameters)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            XCTAssertFalse(LoginManager.shared.isAuthorized)
            XCTAssertTrue(LoginManager.shared.isAuthorizing)

            // Simulate auth result
            let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=\(process.processID)"
            let handled = process.resumeOpenURL(url: URL(string: urlString)!)
            XCTAssertTrue(handled)
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testLoginActionWithOpenID() {
        let expect = expectation(description: "\(#file)_\(#line)")

        XCTAssertFalse(LoginManager.shared.isAuthorized)
        XCTAssertFalse(LoginManager.shared.isAuthorizing)

        let delegateStub = SessionDelegateStub(stubs: [
            .init(data: PostExchangeTokenRequest.successData, responseCode: 200),
            .init(data: GetUserProfileRequest.successData, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )

        var process: LoginProcess!
        process = LoginManager.shared.login(permissions: [.profile, .openID], in: setupViewController()) {
            loginResult in
            XCTAssertNotNil(loginResult.value)

            let result = loginResult.value!

            // IDTokenNonce should be `nil` when `.openID` not required.
            XCTAssertNotNil(result.IDTokenNonce)
            XCTAssertEqual(result.IDTokenNonce, process!.IDTokenNonce)

            try! AccessTokenStore.shared.removeCurrentAccessToken()
            expect.fulfill()
        }!

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

            XCTAssertFalse(LoginManager.shared.isAuthorized)
            XCTAssertTrue(LoginManager.shared.isAuthorizing)

            let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=\(process.processID)"
            let handled = process.resumeOpenURL(url: URL(string: urlString)!)
            XCTAssertTrue(handled)
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testLogout() {
        let expect = expectation(description: "\(#file)_\(#line)")

        setupTestToken()
        XCTAssertTrue(LoginManager.shared.isAuthorized)
        
        Session._shared = Session.stub(configuration: LoginConfiguration.shared, string: "")
        LoginManager.shared.logout { result in
            XCTAssertFalse(LoginManager.shared.isAuthorized)
            XCTAssertNotNil(result.value)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRefreshNotOverwriteStoredIDToken() {

        let expect = expectation(description: "\(#file)_\(#line)")

        setupTestToken()
        XCTAssertTrue(LoginManager.shared.isAuthorized)
        XCTAssertNotNil(AccessTokenStore.shared.current?.IDToken)

        let delegateStub = SessionDelegateStub(
            stubs: [.init(data: PostRefreshTokenRequest.successData, responseCode: 200)])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )

        API.Auth.refreshAccessToken { result in
            XCTAssertNotNil(AccessTokenStore.shared.current?.IDToken)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testLoginProcessRouteSetting() {
        XCTContext.runActivity(named: "app universal link") { _ in
            let process = LoginProcess(
                configuration: .shared, scopes: [], parameters: .init(), viewController: setupViewController()
            )
            XCTAssertNil(process.loginRoute)
            process.appUniversalLinkFlow = AppUniversalLinkFlow(parameter: sampleFlowParameters)
            XCTAssertEqual(process.loginRoute, .appUniversalLink)
        }

        XCTContext.runActivity(named: "app auth") { _ in
            let process = LoginProcess(
                configuration: .shared, scopes: [], parameters: .init(), viewController: setupViewController()
            )
            XCTAssertNil(process.loginRoute)
            process.appAuthSchemeFlow = AppAuthSchemeFlow(parameter: sampleFlowParameters)
            XCTAssertEqual(process.loginRoute, .appAuthScheme)
        }

        XCTContext.runActivity(named: "web login") { _ in
            let process = LoginProcess(
                configuration: .shared, scopes: [], parameters: .init(), viewController: setupViewController()
            )
            XCTAssertNil(process.loginRoute)
            process.webLoginFlow = WebLoginFlow(parameter: sampleFlowParameters)
            XCTAssertEqual(process.loginRoute, .webLogin)
        }
    }

}

