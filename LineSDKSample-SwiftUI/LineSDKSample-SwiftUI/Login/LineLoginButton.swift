//
//  LineLoginButton.swift
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

import LineSDK
import SwiftUI

struct LineLoginButton: UIViewRepresentable {
    let permissions: Set<LoginPermission>

    fileprivate var onLoginSucceed: ((LoginResult) -> Void)?
    fileprivate var onLoginFail: ((LineSDKError) -> Void)?
    fileprivate var onLoginStart: (() -> Void)?

    init(permissions: Set<LoginPermission> = [.profile]) {
        self.permissions = permissions
    }

    // MARK: - Wrapping view

    func makeUIView(context: Context) -> LoginButton {
        let button = LoginButton()
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.delegate = context.coordinator
        return button
    }

    func updateUIView(_ uiView: LoginButton, context: Context) {}

    // MARK: - Coordinating

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - LoginButton Delegating

    func onLoginSuccess(perform: @escaping (LoginResult) -> Void) -> Self {
        modified(\.onLoginSucceed, with: perform)
    }

    func onLoginFail(perform: @escaping (LineSDKError) -> Void) -> Self {
        modified(\.onLoginFail, with: perform)
    }

    func onLoginStart(perform: @escaping () -> Void) -> Self {
        modified(\.onLoginStart, with: perform)
    }

    private func modified<Value>(_ keyPath: WritableKeyPath<Self, Value>, with value: Value) -> Self {
        var modified = self
        modified[keyPath: keyPath] = value
        return modified
    }
}

extension LineLoginButton {
    class Coordinator: NSObject, LoginButtonDelegate {
        private let parent: LineLoginButton

        init(parent: LineLoginButton) {
            self.parent = parent
        }

        // MARK: - LoginButtonDelegate

        func loginButtonDidStartLogin(_ button: LoginButton) {
            parent.onLoginStart?()
        }

        func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
            parent.onLoginSucceed?(loginResult)
        }

        func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
            parent.onLoginFail?(error)
        }
    }
}
