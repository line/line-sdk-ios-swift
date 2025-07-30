//
//  LoginProcessFlowTests.swift
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
class LoginProcessFlowTests: XCTestCase, ViewControllerCompatibleTest {

    var window: UIWindow!
    let mockFlowFactory = MockLoginFlowFactory()

    // MARK: - Helper Methods

    private func createLoginProcess(
        lineInstalled: Bool = true,
        onlyWebLogin: Bool = false
    ) -> LoginProcess {
        let mockLineChecker = MockLINEAvailabilityChecker(isLINEInstalled: lineInstalled)

        var parameters = LoginManager.Parameters()
        parameters.onlyWebLogin = onlyWebLogin

        return LoginProcess(
            configuration: LoginConfiguration(channelID: "test_channel", universalLinkURL: nil),
            scopes: [.profile],
            parameters: parameters,
            viewController: setupViewController(),
            flowFactory: mockFlowFactory,
            lineAvailabilityChecker: mockLineChecker
        )
    }

    // MARK: - Universal Link Flow Tests

    func testUniversalLinkFlowSuccess() {
        let expect = expectation(description: "universal link success")

        let process = createLoginProcess()
        mockFlowFactory.configureAllFlowsToSucceed()

        // We cannot directly test setupAppSwitchingObserver since it's private,
        // but we can verify the observer property is set

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Verify Universal Link flow was created and started
            XCTAssertNotNil(self.mockFlowFactory.mockUniversalLinkFlow)
            XCTAssertEqual(self.mockFlowFactory.mockUniversalLinkFlow?.startCallCount, 1)

            // Verify that flow is set and app switching observer should be called
            XCTAssertNotNil(process.appUniversalLinkFlow)
            XCTAssertEqual(process.loginRoute, .appUniversalLink)

            // Auth scheme and web login should not be started
            XCTAssertNil(self.mockFlowFactory.mockAuthSchemeFlow)
            XCTAssertNil(self.mockFlowFactory.mockWebLoginFlow)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testUniversalLinkFlowFailureFallbackToAuth() {
        let expect = expectation(description: "universal link failure fallback to auth")

        let process = createLoginProcess()
        mockFlowFactory.configureUniversalLinkFailAuthSchemeSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Verify Universal Link flow was started and failed
            XCTAssertNotNil(self.mockFlowFactory.mockUniversalLinkFlow)
            XCTAssertEqual(self.mockFlowFactory.mockUniversalLinkFlow?.startCallCount, 1)

            // Verify Auth Scheme flow was started as fallback
            XCTAssertNotNil(self.mockFlowFactory.mockAuthSchemeFlow)
            XCTAssertEqual(self.mockFlowFactory.mockAuthSchemeFlow?.startCallCount, 1)
            XCTAssertNotNil(process.appAuthSchemeFlow)
            XCTAssertEqual(process.loginRoute, .appAuthScheme)

            // Web login should not be started
            XCTAssertNil(self.mockFlowFactory.mockWebLoginFlow)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testUniversalLinkFlowFailureFallbackToWeb() {
        let expect = expectation(description: "universal link failure fallback to web")

        mockFlowFactory.configureUniversalLinkFailAuthSchemeSucceed()
        let process = createLoginProcess(lineInstalled: false) // LINE not installed

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Verify Universal Link flow was started and failed
            XCTAssertNotNil(self.mockFlowFactory.mockUniversalLinkFlow)
            XCTAssertEqual(self.mockFlowFactory.mockUniversalLinkFlow?.startCallCount, 1)

            // Auth Scheme should be skipped since LINE is not installed
            XCTAssertNil(self.mockFlowFactory.mockAuthSchemeFlow)

            // Verify Web Login flow was started as fallback
            XCTAssertNotNil(self.mockFlowFactory.mockWebLoginFlow)
            XCTAssertEqual(self.mockFlowFactory.mockWebLoginFlow?.startCallCount, 1)
            XCTAssertNotNil(process.webLoginFlow)
            XCTAssertEqual(process.loginRoute, .webLogin)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Auth Scheme Flow Tests

    func testAuthSchemeFlowSuccess() {
        let expect = expectation(description: "auth scheme success")

        mockFlowFactory.universalLinkShouldSucceed = false
        mockFlowFactory.authSchemeShouldSucceed = true
        let process = createLoginProcess(lineInstalled: true)

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Verify Auth Scheme flow was started and succeeded
            XCTAssertNotNil(self.mockFlowFactory.mockAuthSchemeFlow)
            XCTAssertEqual(self.mockFlowFactory.mockAuthSchemeFlow?.startCallCount, 1)
            XCTAssertNotNil(process.appAuthSchemeFlow)
            XCTAssertEqual(process.loginRoute, .appAuthScheme)

            // Web login should not be started
            XCTAssertNil(self.mockFlowFactory.mockWebLoginFlow)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testAuthSchemeFlowFailureFallbackToWeb() {
        let expect = expectation(description: "auth scheme failure fallback to web")

        let process = createLoginProcess()
        mockFlowFactory.configureAllAppFlowsFailWebSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Both Universal Link and Auth Scheme should have been tried
            XCTAssertNotNil(self.mockFlowFactory.mockUniversalLinkFlow)
            XCTAssertNotNil(self.mockFlowFactory.mockAuthSchemeFlow)

            // Web Login should be started as final fallback
            XCTAssertNotNil(self.mockFlowFactory.mockWebLoginFlow)
            XCTAssertEqual(self.mockFlowFactory.mockWebLoginFlow?.startCallCount, 1)
            XCTAssertNotNil(process.webLoginFlow)
            XCTAssertEqual(process.loginRoute, .webLogin)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - Web Login Flow Tests

    func testWebLoginFlowSuccess() {
        let expect = expectation(description: "web login success")

        let process = createLoginProcess()
        mockFlowFactory.configureAllAppFlowsFailWebSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Verify Web Login flow was started and succeeded
            XCTAssertNotNil(self.mockFlowFactory.mockWebLoginFlow)
            XCTAssertEqual(self.mockFlowFactory.mockWebLoginFlow?.startCallCount, 1)
            XCTAssertNotNil(process.webLoginFlow)
            XCTAssertEqual(process.loginRoute, .webLogin)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testWebLoginFlowError() {
        let expect = expectation(description: "web login error")

        let process = createLoginProcess()
        mockFlowFactory.configureAllFlowsToFail()

        var receivedError: Error?
        process.onFail.delegate(on: self) { (self, error) in
            receivedError = error
            expect.fulfill()
        }

        process.start()

        waitForExpectations(timeout: 1.0)

        XCTAssertNotNil(receivedError)
        XCTAssertTrue(receivedError is LineSDKError)
    }

    // MARK: - Complete Flow Chain Tests

    func testCompleteFlowChain() {
        let expect = expectation(description: "complete flow chain")

        // Configure all flows to fail except web login
        let process = createLoginProcess()
        mockFlowFactory.configureAllAppFlowsFailWebSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Verify all flows were attempted in order
            XCTAssertNotNil(self.mockFlowFactory.mockUniversalLinkFlow)
            XCTAssertEqual(self.mockFlowFactory.mockUniversalLinkFlow?.startCallCount, 1)

            XCTAssertNotNil(self.mockFlowFactory.mockAuthSchemeFlow)
            XCTAssertEqual(self.mockFlowFactory.mockAuthSchemeFlow?.startCallCount, 1)

            XCTAssertNotNil(self.mockFlowFactory.mockWebLoginFlow)
            XCTAssertEqual(self.mockFlowFactory.mockWebLoginFlow?.startCallCount, 1)

            // Final state should be web login
            XCTAssertEqual(process.loginRoute, .webLogin)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testOnlyWebLoginParameter() {
        let expect = expectation(description: "only web login parameter")

        let process = createLoginProcess(onlyWebLogin: true)
        mockFlowFactory.configureAllFlowsToSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Only Web Login should be started, no app links
            XCTAssertNil(self.mockFlowFactory.mockUniversalLinkFlow)
            XCTAssertNil(self.mockFlowFactory.mockAuthSchemeFlow)

            XCTAssertNotNil(self.mockFlowFactory.mockWebLoginFlow)
            XCTAssertEqual(self.mockFlowFactory.mockWebLoginFlow?.startCallCount, 1)
            XCTAssertEqual(process.loginRoute, .webLogin)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - App Switching Observer Tests

    func testAppSwitchingObserverSetupOnUniversalLinkSuccess() {
        let expect = expectation(description: "app switching observer setup on universal link success")

        let process = createLoginProcess()
        mockFlowFactory.configureAllFlowsToSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // When Universal Link succeeds, app switching observer should be set up
            XCTAssertNotNil(process.appSwitchingObserver)
            XCTAssertEqual(process.loginRoute, .appUniversalLink)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testAppSwitchingObserverSetupOnAuthSchemeSuccess() {
        let expect = expectation(description: "app switching observer setup on auth scheme success")

        let process = createLoginProcess()
        mockFlowFactory.configureUniversalLinkFailAuthSchemeSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // When Auth Scheme succeeds, app switching observer should be set up
            XCTAssertNotNil(process.appSwitchingObserver)
            XCTAssertEqual(process.loginRoute, .appAuthScheme)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testAppSwitchingObserverNotSetupOnWebLogin() {
        let expect = expectation(description: "app switching observer not setup on web login")

        let process = createLoginProcess()
        mockFlowFactory.configureAllAppFlowsFailWebSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // When only Web Login is used, no app switching observer should be set up
            // because we don't leave the app
            XCTAssertNil(process.appSwitchingObserver)
            XCTAssertEqual(process.loginRoute, .webLogin)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - MacCatalyst Behavior Test

    #if targetEnvironment(macCatalyst)
    func testMacCatalystBehavior() {
        let expect = expectation(description: "macCatalyst behavior")

        let process = createLoginProcess()
        mockFlowFactory.configureAllFlowsToSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // On macCatalyst, should skip to Web Login directly
            XCTAssertNil(self.mockFlowFactory.mockUniversalLinkFlow)
            XCTAssertNil(self.mockFlowFactory.mockAuthSchemeFlow)

            XCTAssertNotNil(self.mockFlowFactory.mockWebLoginFlow)
            XCTAssertEqual(process.loginRoute, .webLogin)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
    #endif

    // MARK: - Edge Cases Tests

    func testProcessStop() {
        let expect = expectation(description: "process stop")

        let process = createLoginProcess()

        var receivedError: Error?
        process.onFail.delegate(on: self) { (self, error) in
            receivedError = error
            expect.fulfill()
        }

        process.stop()

        waitForExpectations(timeout: 1.0)

        XCTAssertNotNil(receivedError)
        if let lineError = receivedError as? LineSDKError,
           case .authorizeFailed(reason: .forceStopped) = lineError {
            // Expected error type
        } else {
            XCTFail("Expected forceStopped error")
        }
    }

    func testFlowReset() {
        let expect = expectation(description: "flow reset")

        let process = createLoginProcess()
        mockFlowFactory.configureAllFlowsToSucceed()

        process.start()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Verify flow is set
            XCTAssertNotNil(process.appUniversalLinkFlow)

            // Stop process (which should reset flows)
            process.stop()

            // Verify flows are reset
            XCTAssertNil(process.appUniversalLinkFlow)
            XCTAssertNil(process.appAuthSchemeFlow)
            XCTAssertNil(process.webLoginFlow)
            XCTAssertNil(process.loginRoute)
            XCTAssertNil(process.appSwitchingObserver)

            expect.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
}
