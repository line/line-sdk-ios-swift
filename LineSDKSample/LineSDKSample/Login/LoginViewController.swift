//
//  ViewController.swift
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
import LineSDK

extension Notification.Name {
    static let userDidLogin = Notification.Name("com.linecorp.linesdk_sample.userDidLogin")
}

class LoginViewController: UIViewController, IndicatorDisplay {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let loginButton = LoginButton()
        
        loginButton.delegate = self
        loginButton.presentingViewController = self

        // You could set the permissions you need or use default permissions
        loginButton.permissions = [.profile, .friends, .groups, .oneTimeShare, .openID]

        view.addSubview(loginButton)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        hideIndicator()
        UIAlertController.present(in: self, successResult: "\(loginResult)") {
            NotificationCenter.default.post(name: .userDidLogin, object: loginResult)
        }
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        hideIndicator()
        #if targetEnvironment(macCatalyst)
        // For macCatalyst app, we allow process discarding so just ignore this error.
        if case .generalError(reason: .processDiscarded(let p)) = error {
            print("Process discarded: \(p)")
            return
        }
        #endif
        
        UIAlertController.present(in: self, error: error)
    }
    
    func loginButtonDidStartLogin(_ button: LoginButton) {
        #if !targetEnvironment(macCatalyst)
        showIndicator()
        #endif
    }
    
}
