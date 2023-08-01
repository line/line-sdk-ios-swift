//
//  LoginButton.swift
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

import UIKit

/// Defines methods that allow you to handle different login statuses if you use the predefined LINE Login
/// button by using the `LoginButton` class.
public protocol LoginButtonDelegate: AnyObject {

    /// Called after the login action is started. Since LINE Login is an asynchronous operation, you might
    /// want to show an indicator or another visual effect to prevent the user from taking other actions.
    func loginButtonDidStartLogin(_ button: LoginButton)

    /// Called if the login action succeeds.
    ///
    /// - Parameters:
    ///   - button: The button used to start the login action.
    ///   - loginResult: The successful login result.
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult)

    /// Called if the login action fails.
    ///
    /// - Parameters:
    ///   - button: The button used to start the login action.
    ///   - error: The strong typed `LineSDKError` of the failed login.
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError)

    /// - Warning: Deprecated. Use the same delegate method which receives `LineSDKError` instead.
    ///            It provides a strongly typed and consistent error for the login failure.
    ///
    /// Called if the login action fails.
    ///
    /// - Parameters:
    ///   - button: The button used to start the login action.
    ///   - error: The error of the failed login.
    func loginButton(_ button: LoginButton, didFailLogin error: Error)
}

/// :nodoc:
public extension LoginButtonDelegate {
    func loginButtonDidStartLogin(_ button: LoginButton) { }
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) { }
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        loginButton(button, didFailLogin: error as Error)
    }
    func loginButton(_ button: LoginButton, didFailLogin error: Error) { }
}

/// Represents a login button which executes the login function when the user taps the button.
///
/// - Note:
/// To change the size of the button, use the `buttonSize` property instead of setting its frame or giving
/// it some size constraints.
open class LoginButton: UIButton {

    /// Represents the size of the login button.
    ///
    /// - small: The size of the login button is small.
    /// - normal: The size of the login button is normal.
    public enum ButtonSize {
        /// The size of the login button is small.
        case small
        /// The size of the login button is normal.
        case normal

        struct Constant {
            let separatorWidth: Float
            let iconWidth: Float
            let iconHeight: Float
            let bubbleWidth: Float
            let leftPadding: Float
            let rightPadding: Float
        }

        var constant: Constant {
            switch self {
            case .small:
                return Constant(
                    separatorWidth: 1,
                    iconWidth: 32,
                    iconHeight: 32,
                    bubbleWidth: 22,
                    leftPadding: 25,
                    rightPadding: 25
                )
            case .normal:
                return Constant(
                    separatorWidth: 1,
                    iconWidth: 44,
                    iconHeight: 44,
                    bubbleWidth: 32,
                    leftPadding: 35,
                    rightPadding: 35
                )
            }
        }

        func sizeForTitleSize(_ titleSize: CGSize) -> CGSize {
            let width = CGFloat(
                constant.iconWidth + constant.separatorWidth + constant.leftPadding + constant.rightPadding
            )
            return CGSize(width: titleSize.width + width, height: CGFloat(constant.iconHeight))
        }
    }

    /// Conforms to the `LoginButtonDelegate` protocol and implements the methods defined in the protocol
    /// to handle different login states.
    public weak var delegate: LoginButtonDelegate?

    /// Determines the view controller that presents the login view controller. If the value is `nil`, the most 
    /// top view controller in the current view controller hierarchy will be used.
    public weak var presentingViewController: UIViewController?

    /// Represents a set of permissions.
    /// The default value is `[.profile]`.
    public var permissions: Set<LoginPermission> = [.profile]

    /// Represents the parameters used during login.
    /// The default value is `nil`.
    public var parameters: LoginManager.Parameters = .init()

    /// The size of the login button. The default value is `normal`.
    public var buttonSize: ButtonSize = .normal {
        didSet {
            // update button style after buttonSize is changed
            updateButtonStyle()
        }
    }

    /// The text on the login button. Its value is "Log in with LINE" in the English environment and
    /// localized for different environments.
    /// The button will be resized if you change this property.
    public var buttonText: String? {
        didSet {
            // update button style after buttonText is changed
            updateButtonStyle()
        }
    }

    /// Creates a predefined LINE Login button.
    public init() {
        super.init(frame: .zero)
        setup()
    }

    /// Creates a predefined LINE Login button.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // Setup the default style of `LoginButton`.
    func setup() {
        // set accessibility label for sample UI test
        accessibilityLabel = "login.button"
        
        titleLabel?.font = .boldSystemFont(ofSize: 11)
        titleLabel?.textAlignment = .center
        setTitleColor(.white, for: .normal)
        
        // Without animation to prevent blinking on first setup.
        UIView.performWithoutAnimation {
            buttonText = Localization.string("linesdk.login.button.login")
            buttonSize = .normal
        }
        
        addTarget(self, action:#selector(login), for: .touchUpInside)
    }

    // This method is called when the style of `LoginButton` is changed.
    // It will update the appearance of button to new style you set.
    func updateButtonStyle() {
        let imagesPairs: [(String, UIControl.State)]
        switch buttonSize {
        case .small:
            imagesPairs = [
                ("small_btn_login_base",    .normal),
                ("small_btn_login_press",   .highlighted),
                ("small_btn_login_disable", .disabled)]
        case .normal:
            imagesPairs = [
                ("normal_btn_login_base",    .normal),
                ("normal_btn_login_press",   .highlighted),
                ("normal_btn_login_disable", .disabled)]
        }
        
        imagesPairs.forEach { (imageName, state) in
            setBackgroundImage(UIImage(bundleNamed: imageName), for: state)
        }

        titleEdgeInsets = UIEdgeInsets(
            top:    CGFloat(buttonSize.constant.bubbleWidth / 2),
            left:   CGFloat(buttonSize.constant.iconWidth +
                            buttonSize.constant.separatorWidth +
                            buttonSize.constant.leftPadding),
            bottom: CGFloat(buttonSize.constant.bubbleWidth / 2),
            right:  CGFloat(buttonSize.constant.rightPadding)
        )
        
        setTitle(buttonText, for: .normal)
        
        let titleSize = titleLabel?.intrinsicContentSize ?? .zero
        frame.size = buttonSize.sizeForTitleSize(titleSize)
        invalidateIntrinsicContentSize()
    }

    /// Overrides the getter of the `intrinsicContentSize` property to support automatic layout.
    override open var intrinsicContentSize: CGSize {
        let titleSize = titleLabel?.intrinsicContentSize ?? .zero
        return buttonSize.sizeForTitleSize(titleSize)
    }

    /// Executes the login action when the user taps the login button.
    @objc open func login() {
        LoginManager.shared.login(
            permissions: permissions,
            in: presentingViewController,
            parameters: parameters
        ) {
            result in
            switch result {
            case .success(let loginResult):
                self.delegate?.loginButton(self, didSucceedLogin: loginResult)
            case .failure(let error):
                self.delegate?.loginButton(self, didFailLogin: error)
            }
        }
        delegate?.loginButtonDidStartLogin(self)
    }
    
    // MARK: - Deprecated
    
    /// - Warning: Deprecated. Use `LoginManager.Parameters`.
    ///
    /// Represents a set of options. The default value is empty.
    @available(
    *, deprecated,
    message: "Convert this value into a `LoginManager.Parameters` and use `parameters` instead.")
    public var options: LoginManagerOptions = []
}
