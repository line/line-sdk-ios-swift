//
//  OpenChatController.swift
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

public protocol OpenChatControllerDelegate: AnyObject {
    func openChatController(
        _ controller: OpenChatController,
        didCreateChatRoom room: OpenChatRoomInfo,
        withCreatingItem: OpenChatRoomCreatingItem
    )
    
    func openChatController(
        _ controller: OpenChatController,
        didFailWithError error: LineSDKError
    )
    
    func openChatController(
        _ controller: OpenChatController,
        didEncounterUserAgreementError error: LineSDKError,
        presentingViewController: UIViewController
    )
    
    func openChatControllerDidCancelCreating(_ controller: OpenChatController)
}

public class OpenChatController {
    
    enum Design {
        static var navigationBarTintColor: UIColor {
            return .compatibleColor(light: 0x283145, dark: 0x161B26)
        }
        static var preferredStatusBarStyle: UIStatusBarStyle  { return .lightContent }
        static var navigationBarTextColor:  UIColor { return .white }
    }

    /// The bar tint color of the navigation bar.
    public var navigationBarTintColor = Design.navigationBarTintColor { didSet { updateNavigationStyles() } }

    /// The color of text, including navigation bar title and bar button text, on the navigation bar.
    public var navigationBarTextColor = Design.navigationBarTextColor { didSet { updateNavigationStyles() } }

    /// The preferred status bar style of this navigation controller.
    public var statusBarStyle = Design.preferredStatusBarStyle { didSet { updateNavigationStyles() } }

    
    public weak var delegate: OpenChatControllerDelegate?
    
    private weak var currentNavigationViewController: UINavigationController?
    
    public init() {
        
    }
    
    deinit {
        print("Deinit")
    }
    
    public func loadAndPresent(in viewController: UIViewController) {
        let checkTermRequest = GetOpenChatTermAgreementStatusRequest()
        Session.shared.send(checkTermRequest) { result in
            switch result {
            case .success(let response):
                if !response.agreed {
                    self.presentCreatingViewController(in: viewController)
                } else {
                    self.presentTermAgreementViewController(in: viewController)
                }
            case .failure(let error):
                self.delegate?.openChatController(self, didFailWithError: error)
            }
        }
    }
    
    func presentTermAgreementViewController(in viewController: UIViewController) {
        let (navigation, termAgreementViewController) = OpenChatTermAgreementViewController.createViewController(self)
        
        termAgreementViewController.onAgreed.delegate(on: self) { (self, vc) in
            vc.dismiss(animated: true) {
                self.presentCreatingViewController(in: viewController)
            }
        }
        termAgreementViewController.onClose.delegate(on: self) { (self, vc) in
            vc.dismiss(animated: true) {
                self.delegate?.openChatControllerDidCancelCreating(self)
            }
        }
        
        currentNavigationViewController = navigation
        updateNavigationStyles()
        
        navigation.modalPresentationStyle = .fullScreen
        viewController.present(navigation, animated: true)
    }
    
    func presentCreatingViewController(in viewController: UIViewController) {
        let (navigation, creatingViewController) = OpenChatCreatingViewController.createViewController(self)
        
        currentNavigationViewController = navigation
        updateNavigationStyles()

        navigation.modalPresentationStyle = .fullScreen
        viewController.present(navigation, animated: true)
    }
    
    private func updateNavigationStyles() {
        guard let currentNav = currentNavigationViewController else { return }
        updateNavigationStyles(currentNav)
    }
    
    private func updateNavigationStyles(_ navigationController: UINavigationController) {
        navigationController.navigationBar.shadowImage = UIImage()
        navigationController.navigationBar.barTintColor = navigationBarTintColor
        navigationController.navigationBar.tintColor = navigationBarTextColor
        navigationController.navigationBar.titleTextAttributes = [.foregroundColor: navigationBarTextColor]
    }
}

public enum OpenChatAuthorizationStatus {
    case lackOfToken
    case lackOfPermissions([LoginPermission])
    case authorized
}

extension OpenChatController {
    public static func localAuthorizationStatusForSendingMessage() -> OpenChatAuthorizationStatus {
        guard let token = AccessTokenStore.shared.current else {
            return .lackOfToken
        }

        return localAuthorizationStatusForOpenChat(permissions: token.permissions)
    }
    
    static func localAuthorizationStatusForOpenChat(permissions: [LoginPermission])
        -> OpenChatAuthorizationStatus
    {
        let lackPermissions = [.openChatTermStatus, .openChatTermAgree, .openChatRoomCreate].filter {
            !permissions.contains($0)
        }

        guard lackPermissions.isEmpty else {
            return .lackOfPermissions(lackPermissions)
        }
        return .authorized
    }
}
