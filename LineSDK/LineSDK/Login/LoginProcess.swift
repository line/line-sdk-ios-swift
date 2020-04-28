//
//  LoginProcess.swift
//
//  Copyright (c) 2016-present, LINE Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LINE Corporation.
//
//  As with any software that integrates with the LINE Corporation platform, your use of this software
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
public class LoginProcess {
    struct FlowParameters {
        let channelID: String
        let universalLinkURL: URL?
        let scopes: Set<LoginPermission>
        let pkce: PKCE
        let processID: String
        let nonce: String?
        let botPrompt: LoginManager.BotPrompt?
        let preferredWebPageLanguage: LoginManager.WebPageLanguage?
        let onlyWebLogin: Bool
    }
    
    /// Observes application switching to foreground.
    /// - Note:
    /// If the app switching happens during login process, we want to
    /// inspect the event of switched back from another app (Safari or LINE or any other)
    /// If the framework container app has not been started up by an `open(url:)`, we think current
    /// login process fails and we need to call the completion closure with a `.userCancelled` error.
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
                guard let `self` = self else { return }
                guard self.valid else { return }
                self.onTrigger.call()
            }
        }
    }
    
    let configuration: LoginConfiguration
    let scopes: Set<LoginPermission>
    let parameters: LoginManager.Parameters
    
    // Flows of login process. A flow will be `nil` until it is running, so we could tell which one should take
    // responsibility to handle a url callback response.
    
    // LINE Client app auth flow captured by LINE universal link.
    var appUniversalLinkFlow: AppUniversalLinkFlow?
    // LINE Client app auth flow by LINE customize URL scheme.
    var appAuthSchemeFlow: AppAuthSchemeFlow?
    // Web login flow with Safari View Controller or Mobile Safari
    var webLoginFlow: WebLoginFlow? {
        didSet {
            // Dismiss safari view controller (if exists) when reset web login flow.
            if webLoginFlow == nil {
                oldValue?.dismiss()
            }
        }
    }
    
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
        viewController: UIViewController?)
    {
        self.configuration = configuration
        self.processID = Data.randomData(bytesCount: 32).base64URLEncoded
        self.pkce = PKCE()
        self.scopes = scopes
        self.parameters = parameters
        self.presentingViewController = viewController
        
        if scopes.contains(.openID) {
            IDTokenNonce = self.parameters.IDTokenNonce ?? Data.randomData(bytesCount: 32).base64URLEncoded
        } else {
            IDTokenNonce = nil
        }
    }
    
    func start() {
        let parameters = FlowParameters(
            channelID: self.configuration.channelID,
            universalLinkURL: self.configuration.universalLinkURL,
            scopes: self.scopes,
            pkce: self.pkce,
            processID: self.processID,
            nonce: self.IDTokenNonce,
            botPrompt: self.parameters.botPromptStyle,
            preferredWebPageLanguage: self.parameters.preferredWebPageLanguage,
            onlyWebLogin: self.parameters.onlyWebLogin
        )
        #if targetEnvironment(macCatalyst)
        // On macCatalyst, we only support web login
        self.startWebLoginFlow(parameters)
        #else
        if self.parameters.onlyWebLogin {
            self.startWebLoginFlow(parameters)
        } else {
            self.startAppUniversalLinkFlow(parameters)
        }
        #endif
    }
    
    /// Stops the login process. The login process will fail with a `.forceStopped` error.
    public func stop() {
        invokeFailure(error: LineSDKError.authorizeFailed(reason: .forceStopped))
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
        let appUniversalLinkFlow = AppUniversalLinkFlow(parameter: parameters)
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
        let appAuthSchemeFlow = AppAuthSchemeFlow(parameter: parameters)
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
        let webLoginFlow = WebLoginFlow(parameter: parameters)
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
    
    func resumeOpenURL(url: URL) -> Bool {

        let isValidUniversalLinkURL = configuration.isValidUniversalLinkURL(url: url)
        let isValidCustomizeURL = configuration.isValidCustomizeURL(url: url)
        
        guard isValidUniversalLinkURL || isValidCustomizeURL else
        {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            do {
                let response = try LoginProcessURLResponse(from: url, validatingWith: self.processID)
                let tokenExchangeRequest = PostExchangeTokenRequest(
                    channelID: self.configuration.channelID,
                    code: response.requestToken,
                    codeVerifier: self.pkce.codeVerifier,
                    redirectURI: Constant.thirdPartyAppReturnURL,
                    optionalRedirectURI: self.configuration.universalLinkURL?.absoluteString)
                Session.shared.send(tokenExchangeRequest) { tokenResult in
                    switch tokenResult {
                    case .success(let token): self.invokeSuccess(result: token, response: response)
                    case .failure(let error): self.invokeFailure(error: error)
                    }
                }
            } catch {
                self.invokeFailure(error: error)
            }
        }

        return true
    }
    
    private var canUseLineAuthV2: Bool {
        return UIApplication.shared.canOpenURL(Constant.lineAppAuthURLv2)
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

class AppUniversalLinkFlow {
    
    let url: URL
    let onNext = Delegate<Bool, Void>()
    
    init(parameter: LoginProcess.FlowParameters) {
        let universalURLBase = URL(string: Constant.lineWebAuthUniversalURL)!
        url = universalURLBase.appendedLoginQuery(parameter)
    }
    
    func start() {
        UIApplication.shared.open(url, options: [.universalLinksOnly: true]) {
            opened in
            self.onNext.call(opened)
        }
    }
}

class AppAuthSchemeFlow {
    
    let url: URL
    let onNext = Delegate<Bool, Void>()
    
    init(parameter: LoginProcess.FlowParameters) {
        url = Constant.lineAppAuthURLv2.appendedURLSchemeQuery(parameter)
    }
    
    func start() {
        UIApplication.shared.open(url, options: [:]) {
            opened in
            self.onNext.call(opened)
        }
    }
}

class WebLoginFlow: NSObject {
    
    enum Next {
        case safariViewController
        case error(Error)
    }
    
    let url: URL
    let onNext = Delegate<Next, Void>()
    let onCancel = Delegate<(), Void>()
    
    weak var safariViewController: UIViewController?
    
    init(parameter: LoginProcess.FlowParameters) {
        let webLoginURLBase = URL(string: Constant.lineWebAuthURL)!
         url = webLoginURLBase.appendedLoginQuery(parameter)
    }
    
    func start(in viewController: UIViewController?) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .overFullScreen
        safariViewController.modalTransitionStyle = .coverVertical
        safariViewController.delegate = self
        if #available(iOS 11.0, *) {
            safariViewController.dismissButtonStyle = .cancel
        }

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

extension WebLoginFlow: SFSafariViewControllerDelegate {
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
        if let window = UIApplication.shared.keyWindow, window.windowLevel == .normal {
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
