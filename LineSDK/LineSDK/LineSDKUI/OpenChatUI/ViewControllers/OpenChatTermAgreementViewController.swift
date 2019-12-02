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
import WebKit

class OpenChatTermAgreementViewController: UIViewController {
    
    enum Design {
        static var backgroundColor: UIColor { return .white }
        
        static var agreeButtonBackgroundColor: UIColor { return .init(hex6: 0x38C65C) }
        static var agreeButtonTextColor: UIColor { return .white }
        static var agreeButtonFont: UIFont { return .boldSystemFont(ofSize: 16) }
        static var agreeButtonCornerRadius: CGFloat { return 5.0 }
        
        static var detailLinkTextColor: UIColor { return .init(hex6: 0x07BF3F) }
        static var detailLinkFont: UIFont { return .systemFont(ofSize: 13, weight: .medium) }
        static var detailLinkUnderlineColor: UIColor { return .init(hex6: 0x07BF3F) }
        
        static var navigationBarTintColor: UIColor { return .white }
        static var navigationBarTextColor: UIColor { return .black }
    }
    
    let onAgreed = Delegate<OpenChatTermAgreementViewController, Void>()
    let onClose = Delegate<OpenChatTermAgreementViewController, Void>()
    
    // Hold `OpenChatController` to prevent unexpected release.
    var controller: OpenChatController?
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.backgroundColor = Design.backgroundColor
        webView.navigationDelegate = self
        return webView
    }()
    
    private lazy var agreeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Agree", for: .normal)
        button.setTitleColor(Design.agreeButtonTextColor, for: .normal)
        button.backgroundColor = Design.agreeButtonBackgroundColor
        button.layer.cornerRadius = Design.agreeButtonCornerRadius
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(agreeTerm), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var detailLinkButton: UIButton = {
        
        let button = UIButton()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Design.detailLinkFont,
            .foregroundColor: Design.detailLinkTextColor,
            .underlineStyle: NSNumber(value: NSUnderlineStyle.single.rawValue),
            .underlineColor: Design.detailLinkUnderlineColor,
        ]
        let text = NSAttributedString(string: "Read the complete OpenChat Terms of Use", attributes: attributes)
        
        button.setAttributedTitle(text, for: .normal)
        if #available(iOS 11.0, *) {
            button.contentHorizontalAlignment = .leading
        } else {
            button.contentHorizontalAlignment = .left
        }
        
        button.addTarget(self, action: #selector(showDetailTerm), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Design.backgroundColor
        
        setupNavigationBar()
        setupSubviews()
        setupLayouts()
        
        webView.load(.init(url: URL(string: "https://terms.line.me/line_Square_TOU_summary/sp?lang=en")!))
    }
    
    private func setupNavigationBar() {
        
        title = "Terms of Use and policies"
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.barTintColor = Design.navigationBarTintColor
        navigationController?.navigationBar.tintColor = Design.navigationBarTextColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Design.navigationBarTextColor]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(bundleNamed: "navi_icon_close"),
            style: .plain,
            target: self,
            action: #selector(closeTerm)
        )
        
    }
    
    private func setupSubviews() {
        view.addSubview(webView)
        view.addSubview(agreeButton)
        view.addSubview(detailLinkButton)
    }
    
    private func setupLayouts() {
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        agreeButton.translatesAutoresizingMaskIntoConstraints = false
        detailLinkButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Agree Button
        NSLayoutConstraint.activate([
            agreeButton.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: -18),
            agreeButton.leadingAnchor.constraint(equalTo: safeLeadingAnchor, constant: 18),
            agreeButton.trailingAnchor.constraint(equalTo: safeTrailingAnchor, constant: -18),
            agreeButton.heightAnchor.constraint(equalToConstant: 48)
        ])
        
        // Link Button
        NSLayoutConstraint.activate([
            detailLinkButton.leadingAnchor.constraint(equalTo: agreeButton.leadingAnchor),
            detailLinkButton.trailingAnchor.constraint(equalTo: agreeButton.trailingAnchor),
            detailLinkButton.heightAnchor.constraint(equalToConstant: 24),
            detailLinkButton.bottomAnchor.constraint(equalTo: agreeButton.topAnchor, constant: -24)
        ])
        
        // Web View
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: safeTopAnchor),
            webView.leadingAnchor.constraint(equalTo: safeLeadingAnchor),
            webView.trailingAnchor.constraint(equalTo: safeTrailingAnchor),
            webView.bottomAnchor.constraint(equalTo: detailLinkButton.topAnchor, constant: -12)
        ])
        
        
    }
    
    @objc private func agreeTerm() {
        onAgreed.call(self)
    }
    
    @objc private func closeTerm() {
        onClose.call(self)
    }
    
    @objc private func showDetailTerm() {
        
    }
}

extension OpenChatTermAgreementViewController: WKNavigationDelegate {
    
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
