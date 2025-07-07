//
//  ViewController.swift
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

    let loginSettings = LoginSettings()
    var loginButton: LoginButton!
    var webLoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loginButton = setupLoginButton()
        webLoginButton = setupWebLoginButton()
    }

    private func setupLoginButton() -> LoginButton {
        let loginButton = LoginButton()

        loginButton.delegate = self
        loginButton.presentingViewController = self

        view.addSubview(loginButton)

        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        return loginButton
    }

    private func setupWebLoginButton() -> UIButton {
        let webLoginButton = UIButton(type: .system)
        webLoginButton.setTitle("Web Login", for: .normal)
        webLoginButton.addTarget(self, action: #selector(webLoginButtonTapped), for: .touchUpInside)

        view.addSubview(webLoginButton)
        webLoginButton.translatesAutoresizingMaskIntoConstraints = false
        webLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        webLoginButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20).isActive = true
        return webLoginButton
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSettings" {
            let viewController = (segue.destination as! UINavigationController).topViewController as! LoginSettingsViewController
            viewController.loginSettings = loginSettings
            viewController.delegate = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLoginButtonData()
    }

    func updateLoginButtonData() {
        loginButton.permissions = loginSettings.permissions
        loginButton.parameters = loginSettings.parameters
    }

    @objc
    func webLoginButtonTapped() {
        showIndicator()
        var parameters = loginSettings.parameters
        parameters.onlyWebLogin = true
        parameters.preferredWebPageLanguage = .japanese
        LoginManager.shared.login(
            permissions: loginSettings.permissions,
            in: self,
            parameters: parameters,
            completionHandler: { [weak self] result in
                self?.handleLoginResult(result)
            }
        )
    }
}

extension LoginViewController: LoginSettingsViewControllerDelegate {
    func loginSettingsViewControllerWillDisappear(_ viewController: LoginSettingsViewController) {
        updateLoginButtonData()
    }
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        handleLoginResult(.success(loginResult))
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        handleLoginResult(.failure(error))
    }

    func loginButtonDidStartLogin(_ button: LoginButton) {
        #if !targetEnvironment(macCatalyst)
        showIndicator()
        #endif
    }
}

extension LoginViewController {
    func handleLoginResult(_ result: Result<LoginResult, LineSDKError>) {
        hideIndicator()
        switch result {
        case .success(let loginResult):
            UIAlertController.present(in: self, successResult: "\(loginResult)") {
                NotificationCenter.default.post(name: .userDidLogin, object: loginResult)
            }
        case .failure(let error):
#if targetEnvironment(macCatalyst)
            // For macCatalyst app, we allow process discarding so just ignore this error.
            if case .generalError(reason: .processDiscarded(let p)) = error {
                print("Process discarded: \(p)")
                return
            }
#endif
            UIAlertController.present(in: self, error: error)
        }
    }
}
