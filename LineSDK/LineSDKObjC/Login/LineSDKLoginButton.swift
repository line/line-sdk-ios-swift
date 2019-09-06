//
//  LineSDKLoginButton.swift
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

#if !LineSDKCocoaPods
import LineSDK
#endif

@objc public protocol LineSDKLoginButtonDelegate: class {
    func loginButtonDidStartLogin(_ button: LineSDKLoginButton)
    func loginButton(_ button: LineSDKLoginButton, didSucceedLogin loginResult: LineSDKLoginResult?)
    func loginButton(_ button: LineSDKLoginButton, didFailLogin error: Error?)
}

@objcMembers
public class LineSDKLoginButton: LoginButton {

    @objc public enum LineSDKLoginButtonSize: Int {
        case small
        case normal
        
        init(_ value: LoginButton.ButtonSize) {
            switch value {
            case .normal: self = .normal
            case .small: self = .small
            }
        }
        
        var unwrapped: LoginButton.ButtonSize {
            switch self {
            case .small: return .small
            case .normal: return .normal
            }
        }
    }
    
    public weak var loginDelegate: LineSDKLoginButtonDelegate?
    public weak var buttonPresentingViewController: UIViewController?

    public var loginPermissions: Set<LineSDKLoginPermission> = [.profile]
    public var loginManagerOptions: [LineSDKLoginManagerOptions]?

    public var buttonSizeValue: LineSDKLoginButtonSize {
        set {
            buttonSize = newValue.unwrapped
        }
        get {
            return LineSDKLoginButtonSize(buttonSize)
        }
    }

    public var buttonTextValue: String? {
        set {
            buttonText = newValue
        }
        get {
            return buttonText
        }
    }

    override public func login() {
        if LineSDKLoginManager.sharedManager.isAuthorizing {
            // Don't allow login to be called again if authorization is already in progress.
            return
        }
        isUserInteractionEnabled = false
        LineSDKLoginManager.sharedManager.login(
            permissions: loginPermissions,
            inViewController: buttonPresentingViewController,
            options: loginManagerOptions
        ) {
            result, error in
            if error == nil {
                self.loginDelegate?.loginButton(self, didSucceedLogin: result)
            } else {
                self.loginDelegate?.loginButton(self, didFailLogin: error)
            }
            self.isUserInteractionEnabled = true
        }
        self.loginDelegate?.loginButtonDidStartLogin(self)
    }
}
