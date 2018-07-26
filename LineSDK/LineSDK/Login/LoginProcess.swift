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

public class LoginProcess {
    let configuration: LoginConfiguration
    let scopes: Set<LoginPermission>
    
    var appUniversalLinkFlow: AppUniversalLinkFlow?
    var appAuthSchemeFlow: AppAuthSchemeFlow?
    var webLoginFlow: WebLoginFlow? {
        didSet {
            // Dismiss safari view controller (if exists) when reset web login flow
            if webLoginFlow == nil {
                oldValue?.dismiss()
            }
        }
    }
    
    weak var presentingViewController: UIViewController?
    
    let processID: String
    
    var otpHolder: OneTimePassword?
    
    var otp: OneTimePassword {
        guard let value = otpHolder else { Log.fatalError("The one time password does not exist.") }
        return value
    }
    
    let onSucceed = Delegate<AccessToken, Void>()
    let onFail = Delegate<Error, Void>()
    
    init(configuration: LoginConfiguration, scopes: Set<LoginPermission>, viewController: UIViewController?) {
        self.configuration = configuration
        self.processID = UUID().uuidString
        self.scopes = scopes
        self.presentingViewController = viewController
    }
    
    func start() {
        let otpRequest = PostOTPRequest(channelID: configuration.channelID)
        Session.shared.send(otpRequest) { result in
            switch result {
            case .success(let otp):
                self.otpHolder = otp
                if self.canUseLineAuthV2 {
                    self.startAppUniversalLinkFlow()
                } else {
                    // TODO: Determine what we want to do, if canUseLineAuthV1 is true (maybe we need some pop up for user to upgrade LINE)
                    // Now, just jump to web login process.
                    self.startWebLoginFlow()
                }
            case .failure(let error):
                self.invokeFailure(error: error)
            }
        }
    }
    
    private func startAppUniversalLinkFlow() {
        let appUniversalLinkFlow = AppUniversalLinkFlow(
            channelID: configuration.channelID,
            scopes: scopes,
            otp: otp,
            processID: processID)
        appUniversalLinkFlow.onNext.delegate(on: self) { (self, started) in
            // Can handle app universal link flow. Store the flow for later resuming use.
            if started {
                self.appUniversalLinkFlow = appUniversalLinkFlow
            } else {
                // LINE universal link handling failed for some reason. Fallback to LINE v2 auth
                if self.canUseLineAuthV2 {
                    self.startAppAuthSchemeFlow()
                } else {
                    self.startWebLoginFlow()
                }
            }
        }
        
        appUniversalLinkFlow.start()
    }
    
    private func startAppAuthSchemeFlow() {
        let appAuthSchemeFlow = AppAuthSchemeFlow(
            channelID: configuration.channelID,
            scopes: scopes,
            otp: otp,
            processID: processID)
        appAuthSchemeFlow.onNext.delegate(on: self) { (self, started) in
            if started {
                self.appAuthSchemeFlow = appAuthSchemeFlow
            } else {
                self.startWebLoginFlow()
            }
        }
        
        appAuthSchemeFlow.start()
    }
    
    private func startWebLoginFlow() {
        let webLoginFlow = WebLoginFlow(
            channelID: configuration.channelID,
            scopes: scopes,
            otp: otp,
            processID: processID)
        webLoginFlow.onNext.delegate(on: self) { (self, error) in
            if let error = error {
                // Starting login flow failed. There is no more
                // fallback methods or cannot find correct view controller.
                // This should normally not happen, but in case we throw an error out.
                self.invokeFailure(error: error)
            } else {
                self.webLoginFlow = webLoginFlow
            }
        }
        webLoginFlow.onCancel.delegate(on: self) { (self, _) in
            self.invokeFailure(error: LineSDKError.authorizeFailed(reason: .userCancelled))
        }
        
        webLoginFlow.start(in: presentingViewController)
    }
    
    func resumeOpenURL(url: URL, sourceApplication: String?) -> Bool {
        guard configuration.isValidURLScheme(url: url) else {
            invokeFailure(error: LineSDKError.authorizeFailed(reason: .callbackURLSchemeNotMatching))
            return false
        }
        
        guard let sourceApp = sourceApplication, configuration.isValidSourceApplication(appID: sourceApp) else {
            invokeFailure(error: LineSDKError.authorizeFailed(reason: .invalidSourceApplication))
            return false
        }
        
        do {
            let response = try LoginProcessURLResponse(from: url, validatingWith: processID)
            let tokenExchageRequest = PostTokenExchangeRequest(
                channelID: configuration.channelID,
                code: response.requestToken,
                otpValue: otp.otp,
                redirectURI: Constant.thirdPartyAppRetrurnURL)
            Session.shared.send(tokenExchageRequest) { tokenResult in
                switch tokenResult {
                case .success(let token): self.invokeSuccess(result: token)
                case .failure(let error): self.invokeFailure(error: error)
                }
            }
        } catch {
            invokeFailure(error: error)
        }
        
        return true
    }
    
    private var canUseLineAuthV1: Bool {
        guard let url = URL(string: Constant.lineAppAuthURLv1) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    private var canUseLineAuthV2: Bool {
        guard let url = URL(string: Constant.lineAppAuthURLv2) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func resetFlows() {
        appUniversalLinkFlow = nil
        appAuthSchemeFlow = nil
        webLoginFlow = nil
    }
    
    private func invokeSuccess(result: AccessToken) {
        resetFlows()
        onSucceed.call(result)
    }
    
    private func invokeFailure(error: Error) {
        resetFlows()
        onFail.call(error)
    }
}

class AppUniversalLinkFlow {
    
    let url: URL
    let onNext = Delegate<Bool, Void>()
    
    init(channelID: String, scopes: Set<LoginPermission>, otp: OneTimePassword, processID: String) {
        let universalURLBase = URL(string: Constant.lineWebAuthUniversalURL)!
        url = universalURLBase.appendedLoginQuery(channelID: channelID,
                                                  scopes: scopes,
                                                  otpID: otp.otpId,
                                                  state: processID)
    }
    
    func start() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [UIApplicationOpenURLOptionUniversalLinksOnly: true]) {
                opened in
                self.onNext.call(opened)
            }
        } else {
            self.onNext.call(false)
        }
    }
}

class AppAuthSchemeFlow {
    
    let url: URL
    let onNext = Delegate<Bool, Void>()
    
    init(channelID: String, scopes: Set<LoginPermission>, otp: OneTimePassword, processID: String) {
        let appAuthURLBase = URL(string: "\(Constant.lineAuthV2Scheme)://authorize/")!
        url = appAuthURLBase.appendedURLSchemeQuery(channelID: channelID,
                                                    scopes: scopes,
                                                    otpID: otp.otpId,
                                                    state: processID)
    }
    
    func start() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [UIApplicationOpenURLOptionUniversalLinksOnly: true]) {
                opened in
                self.onNext.call(opened)
            }
        } else {
            let opened = UIApplication.shared.openURL(url)
            self.onNext.call(opened)
        }
    }
}

class WebLoginFlow: NSObject {
    
    let url: URL
    let onNext = Delegate<Error?, Void>()
    let onCancel = Delegate<(), Void>()
    
    weak var safariViewController: UIViewController?
    
    init(channelID: String, scopes: Set<LoginPermission>, otp: OneTimePassword, processID: String) {
        let webLoginURLBase = URL(string: Constant.lineWebAuthURL)!
        url = webLoginURLBase.appendedLoginQuery(channelID: channelID,
                                                  scopes: scopes,
                                                  otpID: otp.otpId,
                                                  state: processID)
    }
    
    func start(in viewController: UIViewController?) {
        if #available(iOS 9.0, *) {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.modalPresentationStyle = .overFullScreen
            safariViewController.modalTransitionStyle = .coverVertical
            safariViewController.delegate = self
            
            self.safariViewController = safariViewController
            
            guard let presenting = viewController ?? .topMost else {
                self.onNext.call(LineSDKError.authorizeFailed(reason: .malformedHierarchy))
                return
            }
            presenting.present(safariViewController, animated: true) {
                self.onNext.call(nil)
            }
        } else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:]) { opened in
                    let error = opened ? nil : LineSDKError.authorizeFailed(reason: .exhaustedLoginFlow)
                    self.onNext.call(error)
                }
            } else {
                let opened = UIApplication.shared.openURL(url)
                let error = opened ? nil : LineSDKError.authorizeFailed(reason: .exhaustedLoginFlow)
                self.onNext.call(error)
            }
        }
    }
    
    func dismiss() {
        self.safariViewController?.dismiss(animated: true)
    }
}

@available(iOS 9.0, *)
extension WebLoginFlow: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        onCancel.call()
    }
}

// Helpers for creating urls in login flows
extension String {
    static func returnUri(channelID: String,
                          scopes: Set<LoginPermission>,
                          otpID: String,
                          state: String,
                          appID: String) -> String
    {
        let result =
            "/oauth2/v2.1/authorize/consent?response_type=code&sdk_ver=\(Constant.SDKVersion)" +
                "&client_id=\(channelID)&scope=\((scopes.map { $0.rawValue }).joined(separator: " "))" +
        "&otpId=\(otpID)&state=\(state)&redirect_uri=\(Constant.thirdPartySchemePrefix).\(appID)://authorize/"
        return result
    }
}

extension URL {
    func appendedLoginQuery(channelID: String, scopes: Set<LoginPermission>, otpID: String, state: String, appID: String? = nil) -> URL {
        guard let appID = appID ?? Bundle.main.bundleIdentifier else {
            Log.fatalError("You need to specify a bundle ID in your app's Info.plist")
        }
        
        let returnUri = String.returnUri(channelID: channelID,
                                         scopes: scopes,
                                         otpID: otpID,
                                         state: state,
                                         appID: appID)
        let parameters: [String: Any] = [
            "returnUri": returnUri,
            "loginChannelId": channelID
        ]
        let encoder = URLQueryEncoder(parameters: parameters, allowed: .urlHostAllowed)
        return encoder.encoded(for: self)
    }
    
    func appendedURLSchemeQuery(channelID: String, scopes: Set<LoginPermission>, otpID: String, state: String, appID: String? = nil) -> URL {
        guard let appID = appID ?? Bundle.main.bundleIdentifier else {
            Log.fatalError("You need to specify a bundle ID in your app's Info.plist")
        }
        let returnUri = String.returnUri(channelID: channelID,
                                         scopes: scopes,
                                         otpID: otpID,
                                         state: state,
                                         appID: appID)
        let loginUrl = "\(Constant.lineWebAuthUniversalURL)?returnUri=\(returnUri)]&loginChannelId=\(channelID)"
        let parameters = [
            "loginUrl": "\(loginUrl)"
        ]
        let encoder = URLQueryEncoder(parameters: parameters)
        return encoder.encoded(for: self)
    }
}

extension UIWindow {
    static func findKeyWindow() -> UIWindow? {
        if let window = UIApplication.shared.keyWindow, window.windowLevel == UIWindowLevelNormal {
            // A key window of main app exists, go ahead and use it
            return window
        }
        
        // Otherwise, try to find a normal level window
        let window = UIApplication.shared.windows.first { $0.windowLevel == UIWindowLevelNormal }
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
            Log.print("Cannot find a key window. Making window \(window) to keyWindow. This might be not what you want, please check your window hierarchy.")
            window.makeKey()
        }
        guard var topViewController = keyWindow?.rootViewController else {
            Log.print("Cannot find a root view controll in current window. Please check your view controller hierarchy.")
            return nil
        }
        
        while let currentTop = topViewController.presentedViewController {
            topViewController = currentTop
        }
        
        return topViewController
    }
}
