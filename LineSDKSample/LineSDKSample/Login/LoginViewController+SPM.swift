//
//  LoginViewController+SPM.swift
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
import LineSDK

extension Notification.Name {
    static let userDidLogin = Notification.Name("com.linecorp.linesdk_sample.userDidLogin")
}

class LoginViewController: UIViewController, IndicatorDisplay {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let loginButton = UIButton(type: .system)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        loginButton.setTitle("Login with LINE", for: .normal)
        
        view.addSubview(loginButton)

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    @objc func login() {
        showIndicator()
        LoginManager.shared.login(permissions: [.profile, .friends, .groups, .messageWrite, .openID], in: self) {
            result in
            self.hideIndicator()
            switch result {
            case .success(let loginResult):
                UIAlertController.present(in: self, successResult: "\(loginResult)") {
                    NotificationCenter.default.post(name: .userDidLogin, object: loginResult)
                }
            case .failure(let error):
                UIAlertController.present(in: self, error: error)
            }

        }
    }
}
