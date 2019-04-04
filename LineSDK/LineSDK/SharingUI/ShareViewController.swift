//
//  ShareViewController.swift
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

public typealias ShareSendingResult = PostMultisendMessagesRequest.Response.SendingResult

public protocol ShareViewControllerDelegate: AnyObject {
    func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError error: LineSDKError)

    func shareViewControllerDidCancelSharing(_ controller: ShareViewController)

    func shareViewController(
        _ controller: ShareViewController,
        didFailSendingMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        withError error: LineSDKError)

    func shareViewController(
        _ controller: ShareViewController,
        didSendMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        sendingResults results: [ShareSendingResult])

    func shareViewController(
        _ controller: ShareViewController,
        messagesForSendingToTargets targets: [ShareTarget]) -> [MessageConvertible]

    func shareViewControllerShouldDismiss(_ controller: ShareViewController) -> Bool
}

extension ShareViewControllerDelegate {
    public func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError error: LineSDKError) { }
    public func shareViewControllerDidCancelSharing(_ controller: ShareViewController) { }
    public func shareViewController(
        _ controller: ShareViewController,
        didFailSendingMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        withError error: LineSDKError) { }
    public func shareViewController(
        _ controller: ShareViewController,
        didSendMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        sendingResults results: [ShareSendingResult]) { }
    public func shareViewController(
        _ controller: ShareViewController,
        messagesForSendingToTargets targets: [ShareTarget]) -> [MessageConvertible]
    {
        guard let messages = controller.messages else {
            Log.fatalError(
                """
                You need at least set the `ShareViewController.message` or implement
                `shareViewController(:messageForSendingToTargets:)` before sharing a message.")
                """
            )
        }
        return messages
    }
    public func shareViewControllerShouldDismiss(_ controller: ShareViewController) -> Bool {
        return true
    }
}

public enum MessageShareTargetType: Int, CaseIterable {
    case friends
    case groups

    var title: String {
        switch self {
        case .friends: return Localization.string("shareRecipient.section.friends.title")
        case .groups: return Localization.string("shareRecipient.section.groups.title")
        }
    }

    var requiredGraphPermission: LoginPermission? {
        switch self {
        case .friends: return .friends
        case .groups: return .groups
        }
    }
}

public enum MessageShareAuthorizationStatus {
    case lackOfToken
    case lackOfPermissions([LoginPermission])
    case authorized
}

public class ShareViewController: UINavigationController {

    enum Design {
        static var navigationBarTintColor: UIColor { return .init(hex6: 0x283145) }
        static var preferredStatusBarStyle: UIStatusBarStyle  { return  .lightContent }
        static var navigationBarTextColor:  UIColor { return  .white }
    }

    public var navigationBarTintColor = Design.navigationBarTintColor { didSet { updateNavigationStyles() } }
    public var navigationBarTextColor = Design.navigationBarTextColor { didSet { updateNavigationStyles() } }
    public var statusBarStyle = Design.preferredStatusBarStyle { didSet { updateNavigationStyles() } }

    public weak var shareDelegate: ShareViewControllerDelegate?

    public var messages: [MessageConvertible]? {
        set { rootViewController.messages = newValue }
        get { return rootViewController.messages }
    }

    private let rootViewController = ShareRootViewController()

    // MARK: - Initializers
    public init() {

        super.init(nibName: nil, bundle: nil)
        setupRootDelegates()
        self.viewControllers = [rootViewController]
        updateNavigationStyles()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup & Style
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    private func setupRootDelegates() {
        rootViewController.onCancelled.delegate(on: self) { (self, _) in
            self.shareDelegate?.shareViewControllerDidCancelSharing(self)
        }
        rootViewController.onLoadingFailed.delegate(on: self) { (self, value) in
            let (type, error) = value
            self.shareDelegate?.shareViewController(self, didFailLoadingListType: type, withError: error)
        }
        rootViewController.onSendingMessage.delegate(on: self) { (self, targets) in

            if let messages = self.shareDelegate?.shareViewController(self, messagesForSendingToTargets: targets) {
                return messages
            }

            guard let messages = self.messages else {
                Log.fatalError(
                    """
                    You need at least set the `ShareViewController.message` or implement
                    `shareViewController(:messageForSendingToTargets:)` before sharing a message.")
                    """
                )
            }

            return messages
        }
        rootViewController.onSendingSuccess.delegate(on: self) { (self, success) in
            self.shareDelegate?.shareViewController(
                self,
                didSendMessages: success.messages,
                toTargets: success.targets,
                sendingResults: success.results)
        }
        rootViewController.onSendingFailure.delegate(on: self) { (self, failure) in
            self.shareDelegate?.shareViewController(
                self,
                didFailSendingMessages: failure.messages,
                toTargets: failure.targets,
                withError: failure.error)
        }
        rootViewController.onShouldDismiss.delegate(on: self) { (self, _) in
            return self.shareDelegate?.shareViewControllerShouldDismiss(self) ?? true
        }
    }

    private func updateNavigationStyles() {
        navigationBar.shadowImage = UIImage()
        navigationBar.barTintColor = navigationBarTintColor
        navigationBar.tintColor = navigationBarTextColor
        navigationBar.titleTextAttributes = [.foregroundColor: navigationBarTextColor]
    }

}

// MARK: - Authorization Helpers
extension ShareViewController {
    public static func authorizationStatusForSendingMessage(to type: MessageShareTargetType)
        -> MessageShareAuthorizationStatus
    {
        guard let token = AccessTokenStore.shared.current else {
            return .lackOfToken
        }

        var lackPermissions = [LoginPermission]()
        if let required = type.requiredGraphPermission, !token.permissions.contains(required) {
            lackPermissions.append(required)
        }
        if !token.permissions.contains(.messageWrite) {
            lackPermissions.append(.messageWrite)
        }
        guard lackPermissions.isEmpty else {
            return .lackOfPermissions(lackPermissions)
        }
        return .authorized
    }
}
