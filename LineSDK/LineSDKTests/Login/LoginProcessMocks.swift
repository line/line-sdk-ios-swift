//
//  LoginProcessMocks.swift
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
import UIKit
import Foundation
@testable import LineSDK

// MARK: - Mock ApplicationOpener

/// Mock ApplicationOpener for testing
@MainActor
class MockApplicationOpener: ApplicationOpener {

    var shouldSucceed: Bool = true
    var openCallCount = 0
    var lastOpenedURL: URL?
    var lastOptions: [UIApplication.OpenExternalURLOptionsKey : Any]?

    func open(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?) {
        openCallCount += 1
        lastOpenedURL = url
        lastOptions = options

        // Simulate async callback
        DispatchQueue.main.async {
            completion?(self.shouldSucceed)
        }
    }
}

// MARK: - Mock LINEAvailabilityChecker

/// Mock LINEAvailabilityChecker for testing
struct MockLINEAvailabilityChecker: LINEAvailabilityChecker {
    let isLINEInstalled: Bool

    init(isLINEInstalled: Bool = true) {
        self.isLINEInstalled = isLINEInstalled
    }
}

// MARK: - Mock Flow Implementations

/// Mock AppUniversalLinkFlow for testing
@MainActor
class MockAppUniversalLinkFlow: AppUniversalLinkFlowType {
    let onNext = Delegate<Bool, Void>()
    var shouldSucceed: Bool = true
    var startCallCount = 0

    func start() {
        startCallCount += 1
        DispatchQueue.main.async {
            self.onNext.call(self.shouldSucceed)
        }
    }
}

/// Mock AppAuthSchemeFlow for testing
@MainActor
class MockAppAuthSchemeFlow: AppAuthSchemeFlowType {
    let onNext = Delegate<Bool, Void>()
    var shouldSucceed: Bool = true
    var startCallCount = 0

    func start() {
        startCallCount += 1
        DispatchQueue.main.async {
            self.onNext.call(self.shouldSucceed)
        }
    }
}

/// Mock WebLoginFlow for testing
@MainActor
class MockWebLoginFlow: WebLoginFlowType {
    let onNext = Delegate<WebLoginFlow.Next, Void>()
    let onCancel = Delegate<(), Void>()
    var nextResult: WebLoginFlow.Next = .safariViewController
    var startCallCount = 0
    var dismissCallCount = 0

    func start(in viewController: UIViewController?) {
        startCallCount += 1
        DispatchQueue.main.async {
            self.onNext.call(self.nextResult)
        }
    }

    func dismiss() {
        dismissCallCount += 1
    }
}

// MARK: - Mock LoginFlowFactory

/// Mock LoginFlowFactory for testing
@MainActor
class MockLoginFlowFactory: LoginFlowFactory {
    var mockUniversalLinkFlow: MockAppUniversalLinkFlow?
    var mockAuthSchemeFlow: MockAppAuthSchemeFlow?
    var mockWebLoginFlow: MockWebLoginFlow?

    // Configuration for created flows
    var universalLinkShouldSucceed: Bool = true
    var authSchemeShouldSucceed: Bool = true
    var webLoginResult: WebLoginFlow.Next = .safariViewController

    func createAppUniversalLinkFlow(parameter: LoginProcess.FlowParameters) -> AppUniversalLinkFlowType {
        let flow = MockAppUniversalLinkFlow()
        flow.shouldSucceed = universalLinkShouldSucceed
        mockUniversalLinkFlow = flow
        return flow
    }

    func createAppAuthSchemeFlow(parameter: LoginProcess.FlowParameters) -> AppAuthSchemeFlowType {
        let flow = MockAppAuthSchemeFlow()
        flow.shouldSucceed = authSchemeShouldSucceed
        mockAuthSchemeFlow = flow
        return flow
    }

    func createWebLoginFlow(parameter: LoginProcess.FlowParameters) -> WebLoginFlowType {
        let flow = MockWebLoginFlow()
        flow.nextResult = webLoginResult
        mockWebLoginFlow = flow
        return flow
    }
}

// MARK: - Test Helper Extensions

extension MockLoginFlowFactory {
    /// Configure all flows to succeed
    func configureAllFlowsToSucceed() {
        universalLinkShouldSucceed = true
        authSchemeShouldSucceed = true
        webLoginResult = .safariViewController
    }

    /// Configure Universal Link to fail, Auth Scheme to succeed
    func configureUniversalLinkFailAuthSchemeSucceed() {
        universalLinkShouldSucceed = false
        authSchemeShouldSucceed = true
        webLoginResult = .safariViewController
    }

    /// Configure Universal Link and Auth Scheme to fail, Web Login to succeed
    func configureAllAppFlowsFailWebSucceed() {
        universalLinkShouldSucceed = false
        authSchemeShouldSucceed = false
        webLoginResult = .safariViewController
    }

    /// Configure Universal all flows to fail
    func configureAllFlowsToFail(with webError: Error = LineSDKError.authorizeFailed(reason: .malformedHierarchy)) {
        universalLinkShouldSucceed = false
        authSchemeShouldSucceed = false
        webLoginResult = .error(webError)
    }
}
