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

/// `LoginButtonDelegate` protocol defines methods that allow you to handle different login states if you use
/// `LoginButton` we provide.
public protocol LoginButtonDelegate: class {

    /// This method would be called after login action did start. Since LINE login is an async operation, it is a
    /// good chance to show an indicator or some other visual effect to block your users other actions.
    func loginButtonDidStartLogin(_ button: LoginButton)

    /// This method would be called if the login action did succeed.
    ///
    /// - Parameters:
    ///   - button: The button which is used to trigger the login.
    ///   - loginResult: Successful result of the login.
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult)

    /// This method would be called if the login action did fail.
    ///
    /// - Parameters:
    ///   - button: The button which is used to trigger the login.
    ///   - error: Error happened during the login process.
    func loginButton(_ button: LoginButton, didFailLogin error: Error)
}

/// Represents a login button which executes the login function when the user taps the button.
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

    /// A parameter of the login action that determines from which view controller the login related view controller
    /// to present. If this value is `nil`, the most top view controller in the current view controller hierarchy
    /// will be used.
    public weak var presentingViewController: UIViewController?

    /// A parameter of the login action that represents a set of permissions.
    /// The default value is `[.profile]`.
    public var permissions: Set<LoginPermission> = [.profile]

    /// A parameter of the login action that represents a set of options.
    /// The default value is empty.
    public var options: LoginManagerOptions = []

    /// The size of the login button. The default value is `normal`.
    public var buttonSize: ButtonSize = .normal {
        didSet {
            // update button style after buttonSize is changed
            updateButtonStyle()
        }
    }

    /// The text on the login button. Its value is "Log in with LINE" in the English environment and
    /// localized for different environments.
    /// The buton will be resized if you change this property.
    public var buttonText: String? {
        didSet {
            // update button style after buttonText is changed
            updateButtonStyle()
        }
    }

    /// Creates a predefined LINE Login button. The button size should be fixed. You need
    /// to layout its x and y values.
    public init() {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // Setup the default style of `LoginButton`.
    func setup() {
        // set accessibility label for sample UI test
        accessibilityLabel = "login.button"
        
        titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 11)
        titleLabel?.textAlignment = .center
        setTitleColor(.white, for: .normal)
        
        // Without animation to prevent blinking on first setup.
        UIView.performWithoutAnimation {
            buttonText = NSLocalizedString("linesdk.login.button.login", bundle: .frameworkBundle, comment: "")
            buttonSize = .normal
        }
        
        addTarget(self, action:#selector(login), for: .touchUpInside)
    }

    // This method is called when the style of `LoginButton` is changed.
    // It will update the appearance of button to new style you set.
    func updateButtonStyle() {
        let bundle = Bundle(for: LoginButton.self)
        let imagesPairs: [(String, UIControl.State)]
        switch buttonSize {
        case .small:
            imagesPairs = [
                ("small_btn_login_base", .normal),
                ("small_btn_login_press", .highlighted),
                ("small_btn_login_disable", .disabled)]
        case .normal:
            imagesPairs = [
                ("normal_btn_login_base", .normal),
                ("normal_btn_login_press", .highlighted),
                ("normal_btn_login_disable", .disabled)]
        }
        
        imagesPairs.forEach { (imageName, state) in
            setBackgroundImage(UIImage(named: imageName, in: bundle, compatibleWith: nil), for: state)
        }
        
        titleEdgeInsets = UIEdgeInsets(
            top: CGFloat(buttonSize.constant.bubbleWidth / 2),
            left: CGFloat(buttonSize.constant.iconWidth + buttonSize.constant.separatorWidth + buttonSize.constant.leftPadding),
            bottom: CGFloat(buttonSize.constant.bubbleWidth / 2),
            right: CGFloat(buttonSize.constant.rightPadding)
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

    // Executes the login action when the user taps the login button.
    @objc open func login() {
        if LoginManager.shared.isAuthorizing {
            // Authorizing process is ongoing so not to call login again
            return
        }
        isUserInteractionEnabled = false
        LoginManager.shared.login(
            permissions: permissions,
            in: presentingViewController,
            options: options
        ) {
            result in
            switch result {
            case .success(let loginResult):
                self.delegate?.loginButton(self, didSucceedLogin: loginResult)
            case .failure(let error):
                self.delegate?.loginButton(self, didFailLogin: error)
            }
            self.isUserInteractionEnabled = true
        }
        delegate?.loginButtonDidStartLogin(self)
    }

}
