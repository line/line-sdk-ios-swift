//
//  LoginProcess.swift
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

import Foundation
import UIKit
import SafariServices

/// Represents a login process initialized by a `LoginManager` object. Normally, a process that contains multiple
/// login flows will run serially. If a flow logs in the user successfully, subsequent flows will not be
/// executed.
@MainActor
public class LoginProcess {

    /// Represents a login route for how the auth flow is initiated.
    public enum LoginRoute: String {
        /// The auth flow starts with a LINE app universal link.
        case appUniversalLink
        /// The auth flow starts with a LINE customize URL scheme.
        case appAuthScheme
        /// The auth flow starts in a web page inside LINE SDK.
        case webLogin
    }

    struct FlowParameters: Sendable {
        let channelID: String
        let universalLinkURL: URL?
        let scopes: Set<LoginPermission>
        let pkce: PKCE
        let processID: String
        let nonce: String?

        let loginParameter: LoginManager.Parameters

        var botPrompt: LoginManager.BotPrompt? {
            loginParameter.botPromptStyle
        }
        var preferredWebPageLanguage: LoginManager.WebPageLanguage? {
            loginParameter.preferredWebPageLanguage
        }
        var onlyWebLogin: Bool {
            loginParameter.onlyWebLogin
        }
        var promptBotID: String? {
            loginParameter.promptBotID
        }
    }

    /// Observes application switching to foreground.
    ///
    /// If the app switching happens during login process, we want to
    /// inspect the event of switched back from another app (Safari or LINE or any other)
    /// If the framework container app has not been started up by an `open(url:)`, we think current
    /// login process fails and we need to call the completion closure with a `.userCancelled` error.
    @MainActor
    class AppSwitchingObserver {
        // A token holds current observing. It will be released and trigger remove observer
        // when this `AppSwitchingObserver` gets released.
        var token: NotificationToken?

        // Controls whether we really need the trigger. By setting this to `false`, `onTrigger` will not be
        // called even a `.UIApplicationDidBecomeActive` event received.
        var valid: Bool = true

        let onTrigger = Delegate<(), Void>()

        init() { }

        func startObserving() {
            token = NotificationCenter.default
                .addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil)
            {
                [weak self] _ in
                Task { @MainActor in
                    guard let `self` = self else { return }
                    guard self.valid else { return }
                    self.onTrigger.call()
                }
            }
        }
    }

    let configuration: LoginConfiguration
    let scopes: Set<LoginPermission>
    let parameters: LoginManager.Parameters
    private let flowFactory: LoginFlowFactory
    private let lineAvailabilityChecker: LINEAvailabilityChecker

    // Flows of login process. A flow will be `nil` until it is running, so we could tell which one should take
    // responsibility to handle a url callback response.

    // LINE Client app auth flow captured by LINE universal link.
    var appUniversalLinkFlow: AppUniversalLinkFlowType? {
        didSet {
            if appUniversalLinkFlow != nil && loginRoute == nil {
                loginRoute = .appUniversalLink
            }
        }
    }
    // LINE Client app auth flow by LINE customize URL scheme.
    var appAuthSchemeFlow: AppAuthSchemeFlowType? {
        didSet {
            if appAuthSchemeFlow != nil && loginRoute == nil {
                loginRoute = .appAuthScheme
            }
        }
    }

    // Web login flow with Safari View Controller or Mobile Safari
    var webLoginFlow: WebLoginFlowType? {
        didSet {
            // Dismiss safari view controller (if exists) when reset web login flow.
            if webLoginFlow == nil {
                oldValue?.dismiss()
            }

            if webLoginFlow != nil && loginRoute == nil {
                loginRoute = .webLogin
            }
        }
    }

    /// Describes how the authentication flow is initiated for this login result.
    ///
    /// If the LINE app was launched to obtain this result, the value will be either `.appUniversalLink` or
    /// `.appAuthScheme`, depending on how the LINE app was opened. If authentication occurred via a web page within
    /// the LINE SDK, the value will be `.webLogin`. If the authentication flow is never or not yet initiated, the value
    /// will be `nil`.
    ///
    /// This value is `nil` until the process starts the auth flow actually. You can access this value safely when an
    /// auth result is retrieved.
    public private(set) var loginRoute: LoginRoute?

    // When we leave current app, we need to set the switching observer
    // to intercept cancel event (switching back but without a token url response)
    var appSwitchingObserver: AppSwitchingObserver?

    weak var presentingViewController: UIViewController?

    /// A random piece of data for current process. Used to verify with server `state` response.
    let processID: String

    /// A string used to prevent replay attacks. This value will be returned in an ID token.
    let IDTokenNonce: String?

    let pkce: PKCE

    let onSucceed = Delegate<(token: AccessToken, response: LoginProcessURLResponse), Void>()
    let onFail = Delegate<Error, Void>()

    init(
        configuration: LoginConfiguration,
        scopes: Set<LoginPermission>,
        parameters: LoginManager.Parameters,
        viewController: UIViewController?,
        // This should be able to be a non-nil value with DefaultLoginFlowFactory() as its default value. But
        // CocaoPods lint does not like when Swift 4.2 language version is used.
        // Revert this later when we can drop support for Swift 4.2:
        // flowFactory: LoginFlowFactory = DefaultLoginFlowFactory(),
        flowFactory: LoginFlowFactory? = nil,
        lineAvailabilityChecker: LINEAvailabilityChecker = DefaultLINEAvailabilityChecker()
    ) {
        self.configuration = configuration
        self.processID = Data.randomData(bytesCount: 32).base64URLEncoded
        self.pkce = PKCE()
        self.scopes = scopes
        self.parameters = parameters
        self.presentingViewController = viewController
        self.flowFactory = flowFactory ?? DefaultLoginFlowFactory()
        self.lineAvailabilityChecker = lineAvailabilityChecker

        if scopes.contains(.openID) {
            IDTokenNonce = self.parameters.IDTokenNonce ?? Data.randomData(bytesCount: 32).base64URLEncoded
        } else {
            IDTokenNonce = nil
        }
    }

    func start() {
        let parameters = FlowParameters(
            channelID: configuration.channelID,
            universalLinkURL: configuration.universalLinkURL,
            scopes: scopes,
            pkce: pkce,
            processID: processID,
            nonce: IDTokenNonce,
            loginParameter: parameters
        )
        #if targetEnvironment(macCatalyst)
        // On macCatalyst, we only support web login
        startWebLoginFlow(parameters)
        #else
        if parameters.onlyWebLogin {
            startWebLoginFlow(parameters)
        } else {
            startAppUniversalLinkFlow(parameters)
        }
        #endif
    }

    /// Stops the login process. The login process will fail with a `.forceStopped` error.
    public func stop() {
        invokeFailure(error: LineSDKError.authorizeFailed(reason: .forceStopped))
        loginRoute = nil
        appSwitchingObserver?.valid = false
        appSwitchingObserver = nil
    }

    // App switching observer should only work when external app switching happens during login process.
    // That means, we should not call this when login with SFSafariViewController.
    private func setupAppSwitchingObserver() {
        let observer = AppSwitchingObserver()
        observer.onTrigger.delegate(on: self) { (self, _) in
            // This trigger will be called during `UIApplicationDidBecomeActive` event.
            // There is some (UI or main thread) bugs on earlier iOS system that users cannot pop up an alert
            // at this time. So we wait for a while before report the cancel event to framework users.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.invokeFailure(error: LineSDKError.authorizeFailed(reason: .userCancelled))
            }
        }
        appSwitchingObserver = observer

        observer.startObserving()
    }

    private func startAppUniversalLinkFlow(_ parameters: FlowParameters) {
        let appUniversalLinkFlow = flowFactory.createAppUniversalLinkFlow(parameter: parameters)
        appUniversalLinkFlow.onNext.delegate(on: self) { [unowned appUniversalLinkFlow] (self, started) in
            // Can handle app universal link flow. Store the flow for later resuming use.
            if started {
                self.setupAppSwitchingObserver()
                self.appUniversalLinkFlow = appUniversalLinkFlow
            } else {
                // LINE universal link handling failed for some reason. Fallback to LINE v2 auth or web login.
                if self.canUseLineAuthV2 {
                    self.startAppAuthSchemeFlow(parameters)
                } else {
                    self.startWebLoginFlow(parameters)
                }
            }
        }

        appUniversalLinkFlow.start()
    }

    private func startAppAuthSchemeFlow(_ parameters: FlowParameters) {
        let appAuthSchemeFlow = flowFactory.createAppAuthSchemeFlow(parameter: parameters)
        appAuthSchemeFlow.onNext.delegate(on: self) { [unowned appAuthSchemeFlow] (self, started) in
            if started {
                self.setupAppSwitchingObserver()
                self.appAuthSchemeFlow = appAuthSchemeFlow
            } else {
                self.startWebLoginFlow(parameters)
            }
        }

        appAuthSchemeFlow.start()
    }

    private func startWebLoginFlow(_ parameters: FlowParameters) {
        let webLoginFlow = flowFactory.createWebLoginFlow(parameter: parameters)
        webLoginFlow.onNext.delegate(on: self) { [unowned webLoginFlow] (self, result) in
            switch result {
            case .safariViewController:
                self.webLoginFlow = webLoginFlow
            case .error(let error):
                // Starting login flow failed. There is no more
                // fallback methods or cannot find correct view controller.
                // This should normally not happen, but in case we throw an error out.
                self.invokeFailure(error: error)
            }
        }
        webLoginFlow.onCancel.delegate(on: self) { (self, _) in
            self.invokeFailure(error: LineSDKError.authorizeFailed(reason: .userCancelled))
        }

        webLoginFlow.start(in: presentingViewController)
    }

    nonisolated func canHandleURL(url: URL) -> Bool {
        let isValidUniversalLinkURL = configuration.isValidUniversalLinkURL(url: url)
        let isValidCustomizeURL = configuration.isValidCustomizeURL(url: url)
        return isValidUniversalLinkURL || isValidCustomizeURL
    }

    func resumeOpenURL(url: URL) -> Bool {
        guard canHandleURL(url: url) else {
            invokeFailure(error: LineSDKError.authorizeFailed(reason: .callbackURLSchemeNotMatching))
            return false
        }

        // It is the callback url we could handle, so the app switching observer should be invalidated.
        appSwitchingObserver?.valid = false

        // Wait for a while before request access token.
        //
        // When switching back to SDK container app from another app, with url scheme or universal link,
        // the URL Session is not available yet (sending a request causes "53: Software caused connection abort" or
        // "-1005 The network connection was lost.", seems only happening on some iOS 12 devices).
        // So as a workaround, we need wait for a while before continuing.
        //
        // ref: https://github.com/AFNetworking/AFNetworking/issues/4279
        //
        // https://github.com/AFNetworking/AFNetworking/issues/4279#issuecomment-447108981
        // It seems that plan A in the comment above also works great (even when the background execution time
        // expired). But I cannot explain why the `URLSession` can retry the request even when background task ends.
        // Maybe it is some internal implementation. Delay the request now works fine so we choose it as a workaround.
        //
        // In some edge cases, the network would be still lost after 0.3 sec of delay. But it should be very rare.
        // So an auto retry for NSURLErrorNetworkConnectionLost (-1005) is applied to make sure the error not happen.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            do {
                let response = try LoginProcessURLResponse(from: url, validatingWith: self.processID)
                self.exchangeToken(response: response, canRetryOnNetworkLost: true)
            } catch {
                self.invokeFailure(error: error)
            }
        }

        return true
    }

    nonisolated func nonisolatedResumeOpenURL(url: URL) -> Bool {
        guard canHandleURL(url: url) else {
            Task { @MainActor in
                invokeFailure(error: LineSDKError.authorizeFailed(reason: .callbackURLSchemeNotMatching))
            }
            return false
        }

        Task { @MainActor in
            // It is the callback url we could handle, so the app switching observer should be invalidated.
            appSwitchingObserver?.valid = false

            // Wait for a while before request access token.
            //
            // When switching back to SDK container app from another app, with url scheme or universal link,
            // the URL Session is not available yet (sending a request causes "53: Software caused connection abort" or
            // "-1005 The network connection was lost.", seems only happening on some iOS 12 devices).
            // So as a workaround, we need wait for a while before continuing.
            //
            // ref: https://github.com/AFNetworking/AFNetworking/issues/4279
            //
            // https://github.com/AFNetworking/AFNetworking/issues/4279#issuecomment-447108981
            // It seems that plan A in the comment above also works great (even when the background execution time
            // expired). But I cannot explain why the `URLSession` can retry the request even when background task ends.
            // Maybe it is some internal implementation. Delay the request now works fine so we choose it as a workaround.
            //
            // In some edge cases, the network would be still lost after 0.3 sec of delay. But it should be very rare.
            // So an auto retry for NSURLErrorNetworkConnectionLost (-1005) is applied to make sure the error not happen.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                do {
                    let response = try LoginProcessURLResponse(from: url, validatingWith: self.processID)
                    self.exchangeToken(response: response, canRetryOnNetworkLost: true)
                } catch {
                    self.invokeFailure(error: error)
                }
            }
        }

        return true
    }

    private func exchangeToken(response: LoginProcessURLResponse, canRetryOnNetworkLost: Bool) {

        let tokenExchangeRequest = PostExchangeTokenRequest(
            channelID: self.configuration.channelID,
            code: response.requestToken,
            codeVerifier: self.pkce.codeVerifier,
            redirectURI: Constant.thirdPartyAppReturnURL,
            optionalRedirectURI: self.configuration.universalLinkURL?.absoluteString)

        Task {
            do {
                let token = try await Session.shared.send(tokenExchangeRequest)
                self.invokeSuccess(result: token, response: response)
            } catch {
                let error = error as? LineSDKError ?? .untypedError(error: error)
                if error.isURLSessionErrorCode(sessionErrorCode: NSURLErrorNetworkConnectionLost) && canRetryOnNetworkLost {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.exchangeToken(response: response, canRetryOnNetworkLost: false)
                    }
                } else {
                    self.invokeFailure(error: error)
                }
            }
        }
    }

    private var canUseLineAuthV2: Bool {
        return lineAvailabilityChecker.isLINEInstalled
    }

    private func resetFlows() {
        appUniversalLinkFlow = nil
        appAuthSchemeFlow = nil
        webLoginFlow = nil
    }

    private func invokeSuccess(result: AccessToken, response: LoginProcessURLResponse) {
        resetFlows()
        onSucceed.call((result, response))
    }

    private func invokeFailure(error: Error) {
        resetFlows()
        onFail.call(error)
    }
}

@MainActor
class AppUniversalLinkFlow: AppUniversalLinkFlowType {

    let url: URL
    let onNext = Delegate<Bool, Void>()
    private let applicationOpener: ApplicationOpener

    init(parameter: LoginProcess.FlowParameters, applicationOpener: ApplicationOpener = UIApplication.shared) {
        let universalURLBase = URL(string: Constant.lineWebAuthUniversalURL)!
        url = universalURLBase.appendedLoginQuery(parameter)
        self.applicationOpener = applicationOpener
    }

    func start() {
        applicationOpener.open(url, options: [.universalLinksOnly: true]) {
            opened in
            self.onNext.call(opened)
        }
    }
}

@MainActor
class AppAuthSchemeFlow: AppAuthSchemeFlowType {

    let url: URL
    let onNext = Delegate<Bool, Void>()
    private let applicationOpener: ApplicationOpener

    init(parameter: LoginProcess.FlowParameters, applicationOpener: ApplicationOpener = UIApplication.shared) {
        url = Constant.lineAppAuthURLv2.appendedURLSchemeQuery(parameter)
        self.applicationOpener = applicationOpener
    }

    func start() {
        applicationOpener.open(url, options: [:]) {
            opened in
            self.onNext.call(opened)
        }
    }
}

@MainActor
class WebLoginFlow: NSObject, WebLoginFlowType {

    enum Next {
        case safariViewController
        case error(Error)
    }

    let url: URL
    let onNext = Delegate<Next, Void>()
    let onCancel = Delegate<(), Void>()

    weak var safariViewController: UIViewController?

    init(parameter: LoginProcess.FlowParameters) {
        var component = URLComponents(string: Constant.lineWebAuthURL)!
        if parameter.loginParameter.initialWebAuthenticationMethod == .qrCode {
            if let _ = component.fragment {
                assertionFailure("Multiple fragment is not yet supported. Require review or report to developer.")
            }
            component.fragment = "/qr"
        }
        let baseURL = component.url!
        url = baseURL.appendedLoginQuery(parameter)
    }

    func start(in viewController: UIViewController?) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .overFullScreen
        safariViewController.modalTransitionStyle = .coverVertical
        safariViewController.delegate = self
        safariViewController.dismissButtonStyle = .cancel

        self.safariViewController = safariViewController

        guard let presenting = viewController ?? .topMost else {
            self.onNext.call(.error(LineSDKError.authorizeFailed(reason: .malformedHierarchy)))
            return
        }
        presenting.present(safariViewController, animated: true) {
            self.onNext.call(.safariViewController)
        }
    }

    func dismiss() {
        self.safariViewController?.dismiss(animated: true)
    }
}

extension WebLoginFlow: @preconcurrency SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        // macCatalyst calls `didFinish` immediately when open page in Safari.
        // It should not be a cancellation.
        #if !targetEnvironment(macCatalyst)
        // This happens when user tap "Cancel" in the SFSafariViewController.
        onCancel.call()
        #endif
    }
}

// Helpers for creating urls for login process
extension String {

    static func returnUri(_ parameter: LoginProcess.FlowParameters) -> String {

        var parameters: [String: Any] = [
            "response_type": "code",
            "sdk_ver": Constant.SDKVersion,
            "client_id": parameter.channelID,
            "scope": (parameter.scopes.map { $0.rawValue }).joined(separator: " "),
            "code_challenge": parameter.pkce.codeChallenge,
            "code_challenge_method": parameter.pkce.codeChallengeMethod,
            "state": parameter.processID,
            "redirect_uri": Constant.thirdPartyAppReturnURL,
        ]

        if let url = parameter.universalLinkURL {
            parameters["optional_redirect_uri"] = url.absoluteString
        }
        if let nonce = parameter.nonce {
            parameters["nonce"] = nonce
        }
        if let botPrompt = parameter.botPrompt {
            parameters["bot_prompt"] = botPrompt.rawValue
        }
        if let promptBotID = parameter.promptBotID {
            parameters["prompt_bot_id"] = promptBotID
        }
        let base = URL(string: "/oauth2/v2.1/authorize/consent")!
        let encoder = URLQueryEncoder(parameters: parameters)
        return encoder.encoded(for: base).absoluteString
    }
}

extension URL {
    func appendedLoginQuery(_ flowParameters: LoginProcess.FlowParameters) -> URL {
        let returnUri = String.returnUri(flowParameters)
        var parameters: [String: Any] = [
            "returnUri": returnUri,
            "loginChannelId": flowParameters.channelID
        ]
        if let lang = flowParameters.preferredWebPageLanguage {
            parameters["ui_locales"] = lang.rawValue
        }
        if flowParameters.onlyWebLogin {
            parameters["disable_ios_auto_login"] = true
        }

        let encoder = URLQueryEncoder(parameters: parameters)
        return encoder.encoded(for: self)
    }

    func appendedURLSchemeQuery(_ flowParameters: LoginProcess.FlowParameters) -> URL {
        let loginBase = URL(string: Constant.lineWebAuthUniversalURL)!
        let loginUrl = loginBase.appendedLoginQuery(flowParameters)
        let parameters = [
            "loginUrl": "\(loginUrl)"
        ]
        let encoder = URLQueryEncoder(parameters: parameters)
        return encoder.encoded(for: self)
    }
}

extension UIWindow {
    static func findKeyWindow() -> UIWindow? {
        if let window = (UIApplication.shared.windows.filter {$0.isKeyWindow}.first), window.windowLevel == .normal {
            // A key window of main app exists, go ahead and use it
            return window
        }

        // Otherwise, try to find a normal level window
        let window = UIApplication.shared.windows.first { $0.windowLevel == .normal }
        guard let result = window else {
            Log.print("Cannot find a valid UIWindow at normal level. Current windows: \(UIApplication.shared.windows)")
            return nil
        }
        return result
    }
}

extension UIViewController {
    static var topMost: UIViewController? {
        let keyWindow = UIWindow.findKeyWindow()
        if let window = keyWindow, !window.isKeyWindow {
            Log.print("Cannot find a key window. Making window \(window) to keyWindow. " +
                "This might be not what you want, please check your window hierarchy.")
            window.makeKey()
        }
        guard var topViewController = keyWindow?.rootViewController else {
            Log.print("Cannot find a root view controller in current window. " +
                "Please check your view controller hierarchy.")
            return nil
        }

        while let currentTop = topViewController.presentedViewController {
            topViewController = currentTop
        }

        return topViewController
    }
}
