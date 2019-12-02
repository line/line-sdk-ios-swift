//
//  OpenChatTermAgreementViewController.swift
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

class OpenChatTermAgreementViewController: UIViewController {
    let onAgreed = Delegate<OpenChatTermAgreementViewController, Void>()
    let onClose = Delegate<OpenChatTermAgreementViewController, Void>()
    
    // Hold `OpenChatController` to prevent unexpected release.
    var controller: OpenChatController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                title: Localization.string("common.action.close"),
                style: .plain,
                target: self,
                action: #selector(closeButtonTapped)
        )
        
        view.backgroundColor = .LineSDKSystemBackground
        
        let button = UIButton(type: .custom)
        button.setTitle("Click me", for: .normal)
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        
        button.widthAnchor.constraint(equalToConstant: 100).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    @objc func buttonClicked() {
        onAgreed.call(self)
    }
    
    @objc private func closeButtonTapped() {
        onClose.call(self)
    }
}

extension OpenChatTermAgreementViewController {
    static func createViewController(
            _ controller: OpenChatController
        ) -> (UINavigationController, OpenChatTermAgreementViewController)
        {
            let viewController = OpenChatTermAgreementViewController()
            viewController.controller = controller
            let navigation = UINavigationController(rootViewController: viewController)
            return (navigation, viewController)
        }
    }
