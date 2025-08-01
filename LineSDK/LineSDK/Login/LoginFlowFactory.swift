//
//  LoginFlowFactory.swift
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

import UIKit
import Foundation

// MARK: - Application Opener Protocol

/// Protocol to abstract UIApplication.open behavior for testing
@MainActor protocol ApplicationOpener {
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey : Any],
        completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?
    )
}

extension UIApplication: ApplicationOpener { }

// MARK: - Flow Protocols

/// Protocol for AppUniversalLinkFlow behavior
@MainActor
protocol AppUniversalLinkFlowType: AnyObject {
    var onNext: Delegate<Bool, Void> { get }
    func start()
}

/// Protocol for AppAuthSchemeFlow behavior  
@MainActor
protocol AppAuthSchemeFlowType: AnyObject {
    var onNext: Delegate<Bool, Void> { get }
    func start()
}

/// Protocol for WebLoginFlow behavior
@MainActor
protocol WebLoginFlowType: AnyObject {
    var onNext: Delegate<WebLoginFlow.Next, Void> { get }
    var onCancel: Delegate<(), Void> { get }
    func start(in viewController: UIViewController?)
    func dismiss()
}

// MARK: - LINE Availability Checker Protocol

/// Protocol to check if LINE app is available
protocol LINEAvailabilityChecker: Sendable {
    @MainActor var isLINEInstalled: Bool { get }
}

/// Default implementation using Constant.isLINEInstalled
struct DefaultLINEAvailabilityChecker: LINEAvailabilityChecker {
    @MainActor var isLINEInstalled: Bool {
        return Constant.isLINEInstalled
    }
}

// MARK: - Flow Factory Protocol

/// Factory protocol for creating login flows (allows dependency injection)
@MainActor
protocol LoginFlowFactory: Sendable {
    func createAppUniversalLinkFlow(parameter: LoginProcess.FlowParameters) -> AppUniversalLinkFlowType
    func createAppAuthSchemeFlow(parameter: LoginProcess.FlowParameters) -> AppAuthSchemeFlowType  
    func createWebLoginFlow(parameter: LoginProcess.FlowParameters) -> WebLoginFlowType
}

// MARK: - Default Implementation

/// Default factory implementation using real flows
@MainActor
class DefaultLoginFlowFactory: LoginFlowFactory {
    private let applicationOpener: ApplicationOpener
    
    init(applicationOpener: ApplicationOpener = UIApplication.shared) {
        self.applicationOpener = applicationOpener
    }
    
    func createAppUniversalLinkFlow(parameter: LoginProcess.FlowParameters) -> AppUniversalLinkFlowType {
        return AppUniversalLinkFlow(parameter: parameter, applicationOpener: applicationOpener)
    }
    
    func createAppAuthSchemeFlow(parameter: LoginProcess.FlowParameters) -> AppAuthSchemeFlowType {
        return AppAuthSchemeFlow(parameter: parameter, applicationOpener: applicationOpener)
    }
    
    func createWebLoginFlow(parameter: LoginProcess.FlowParameters) -> WebLoginFlowType {
        return WebLoginFlow(parameter: parameter)
    }
}
