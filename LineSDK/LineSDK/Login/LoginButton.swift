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

    /// This method would be called after login action did start.
    func loginButtonDidStartLogin(_ button: LoginButton)

    /// This method would be called if the login action did succeed.
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult)

    /// This method would be called if the login action did fail.
    func loginButton(_ button: LoginButton, didFailLogin error: Error)
}

/// `LoginButton` is a UIButton which executes login function when user taps on it.
open class LoginButton: UIButton {

    /// Specifies the size of a `LoginButton`.
    ///
    /// - small: the small-sized `LoginButton`.
    /// - normal: the normal-sized `LoginButton`.
    public enum ButtonSize {
        case small
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

    /// The object conforms to `LoginButtonDelegate` and implements the methods defined in `LoginButtonDelegate`
    /// to handle different login states.
    public weak var delegate: LoginButtonDelegate?

    /// This property would be a parameter of login action which presents the login alert view controller.
    /// If its value is `nil`, the most top view controller in current view controller hierarchy will be used.
    public weak var presentingViewController: UIViewController?

    /// The set of permissions is a parameter of login action.
    /// The default permissions is [.profile].
    public var permissions: Set<LoginPermission> = [.profile]

    /// The set of options is a parameter of login action.
    /// The default options is empty.
    public var options: LoginManagerOptions = []

    /// The size of `LoginButton`. The default button size is normal. The buton will be resized if you change
    /// this property.
    public var buttonSize: ButtonSize = .normal {
        didSet {
            // update button style after buttonSize is changed
            updateButtonStyle()
        }
    }

    /// The text on the `LoginButton`. Its value is a localized string which is `Log in with LINE` in English.
    /// The buton will be resized if you change this property.
    public var buttonText: String? {
        didSet {
            // update button style after buttonText is changed
            updateButtonStyle()
        }
    }

    public init() {
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    /// Setup the default style of `LoginButton`.
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

    /// This method is called when the style of `LoginButton` is changed. It will update the appearance of button
    /// to new style you set.
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

    /// Override the getter of intrinsicContentSize to support auto layout.
    override open var intrinsicContentSize: CGSize {
        let titleSize = titleLabel?.intrinsicContentSize ?? .zero
        return buttonSize.sizeForTitleSize(titleSize)
    }

    /// Execute this function to do login action when user taps on `LoginButton`.
    @objc open func login() {
        if LoginManager.shared.isAuthorizing {
            // Authorizing process is on-going so not to call login again
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
