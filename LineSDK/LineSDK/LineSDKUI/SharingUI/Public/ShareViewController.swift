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

/**
 A view controller that provides a default UI for selecting friends and groups,
 then share some `Message`s to the selected targets.

 ## Overview

 A `ShareViewController` allows users to share a message to LINE via a default UI.
 An authorized user can browse, search, and select up to 10 users or groups in a tab-based table view UI.
 After choosing their share targets, the user taps "Send" to share a preset `Message` to the targets. 
 The message appears to the target recipients as having been sent by the user themselves.

 `ShareViewController` is a subclass of `UINavigationController`, so you need to create and present it modally.
 To use `ShareViewController`, follow these steps:

 1. Verify that the user has granted your app the necessary permissions. `ShareViewController` will show both
 Friends and Groups tabs. To get the friend list and group list, and send a message, you need
 `LoginPermission.oneTimeShare`. Use `ShareViewController.localAuthorizationStatusForSendingMessage(to:)` to check
 whether you have a valid token with the necessary permissions. If you don't have them, don't create and
 show the `ShareViewController`, but instead prompt your user to grant your app the needed permissions.

 2. Create a `ShareViewController` instance. `ShareViewController` can't be initialized from Storyboard or
 XIB. Use the provided initializer `init()`.

 3. Specify `messages` to tell the `ShareViewController` the `Message` values you want to share.

 4. Present the created `ShareViewController` modally by calling `present(_:animated:completion:)`.

 You can customize the `ShareViewController` navigation bar style and status bar content style to match your app.
 Use `navigationBarTintColor`, `navigationBarTextColor`, and `statusBarStyle` to do so.

 ## Share Delegate

 `ShareViewController` will deliver results of user interaction to a delegate object. To get these related events,
 you must provide a delegate that conforms to the `ShareViewControllerDelegate` protocol, and set it to `shareDelegate`
 property.

 See `ShareViewControllerDelegate` for more information.

 - Warning:
 Although `ShareViewController` is marked as `open`, we recommend against creating a subclass for it. The class is
 intended to be used as-is, to ensure a consistent sharing experience across all LINE and LINE SDK integrations. Users
 expect sharing messages to friends and groups in LINE to work the same across different apps. Nevertheless, if you 
 absolutely need a custom sharing interaction, you can create it using the related APIs.
 */
open class ShareViewController: UINavigationController {

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

    /// The delegate object of this share view controller.
    ///
    /// The delegate receives events when the friends/groups list loading fails, user cancels the sharing view
    /// controller or the sharing finishes successfully. You can choose to implement one or more methods to offer
    /// your users a better experience when an event happens.
    ///
    /// For information about the methods you can implement for your delegate object,
    /// see `ShareViewControllerDelegate`.
    ///
    public weak var shareDelegate: ShareViewControllerDelegate?

    /// The `Message` objects about to be sent.
    ///
    /// - Note:
    /// If you didn't specify the `shareDelegate` for `ShareViewController` or you didn't implement the
    /// `shareViewController(_:messagesForSendingToTargets:)` method in the delegate object, the value from
    /// this property will be used as the messages to be sent.
    ///
    /// You must either set this property to a non-nil value, or implement the 
    /// `shareViewController(_:messagesForSendingToTargets:)` delegate method and return a valid message array. If you 
    /// don't, a trap will be triggered. If you implemented both, the returned value from delegate method will overwrite 
    /// the value in this property.
    ///
    public var messages: [MessageConvertible]? {
        set { rootViewController.messages = newValue }
        get { return rootViewController.messages }
    }

    private let rootViewController = ShareRootViewController()

    // MARK: - Initializers

    /// Creates a `ShareViewController` with default behavior. Always use this initializer to create a
    /// `ShareViewController` instance.
    public init() {
        super.init(nibName: nil, bundle: nil)
        setupRootDelegates()
        setupPresentationDelegate()
        self.viewControllers = [rootViewController]
        updateNavigationStyles()
    }

    /// `ShareViewController` can't be created from Storyboard or XIB file. This method merely throws a
    /// fatal error.
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup & Style

    /// :nodoc:
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    private func setupRootDelegates() {
        rootViewController.onCancelled.delegate(on: self) { (self, _) in
            if let shareDelegate = self.shareDelegate {
                self.dismiss(animated: true) {
                    shareDelegate.shareViewControllerDidCancelSharing(self)
                }
            } else {
                self.dismiss(animated: true)
            }
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
                    `shareViewController(:messageForSendingToTargets:)` before sharing a message.)
                    """
                )
            }

            return messages
        }
        rootViewController.onSendingSuccess.delegate(on: self) { (self, success) in
            self.shareDelegate?.shareViewController(
                self,
                didSendMessages: success.messages,
                toTargets: success.targets)
        }
        rootViewController.onSendingFailure.delegate(on: self) { (self, failure) in
            self.shareDelegate?.shareViewController(
                self,
                didFailSendingMessages: failure.messages,
                toTargets: failure.targets,
                withError: failure.error)
        }
        rootViewController.onShouldDismiss.delegate(on: self) { (self, _) in
            return self.shareDelegate?.shareViewControllerShouldDismissAfterSending(self) ?? true
        }
    }

    private func setupPresentationDelegate() {
        presentationController?.delegate = self
    }

    private func updateNavigationStyles() {
        navigationBar.shadowImage = UIImage()
        navigationBar.barTintColor = navigationBarTintColor
        navigationBar.tintColor = navigationBarTextColor
        navigationBar.titleTextAttributes = [.foregroundColor: navigationBarTextColor]
    }
}

/// Represents the authorization status for sharing messages.
/// Before creating and presenting a message sharing UI, we strongly recommend checking whether your app
/// has a valid token and the necessary permissions to share messages.
///
/// `ShareViewController.localAuthorizationStatusForSendingMessage()` returns a `MessageShareAuthorizationStatus` value
/// to indicate the current authorization status for sharing messages.
///
/// - lackOfToken:        There is no valid token in the local token store. The user hasn't logged in and authorized
///                       your app yet.
/// - lackOfPermissions:  There is a valid token, but it doesn't contain the necessary permissions for sharing a message. 
///                       The associated value is an array of `LoginPermission`, containing all lacking permissions.
/// - authorized:         The token exists locally and contains the necessary permissions to share messages.
///
public enum MessageShareAuthorizationStatus {
    
    /// There is no valid token in the local token store. The user hasn't logged in and authorized your app yet.
    case lackOfToken
    
    /// There is a valid token, but it doesn't contain the necessary permissions for sharing a message.
    /// The associated value is an array of `LoginPermission`, containing all lacking permissions.
    case lackOfPermissions([LoginPermission])
    
    /// The token exists locally and contains the necessary permissions to share messages.
    case authorized
}

// MARK: - Authorization Helpers
extension ShareViewController {

    /// Gets the local authorization status for sending messages to friends and groups.
    ///
    /// - Returns: The local authorization status based on the currently stored token and the permissions specified in that token.
    ///
    /// - Note:
    ///   If the return value is `.authorized`, you can present a `ShareViewController` instance for message sharing.
    ///   But `.authorized` status doesn't necessarily mean sharing would succeed; there may be problems with the 
    ///   token or permissions. 
    ///   The token status is stored locally and may not have been synchronized with the server-side status.
    ///   The token may have expired or been revoked by the server or via another client.
    ///
    /// To get the correct result about sharing behavior, specify `ShareViewController.shareDelegate` and implement
    /// the methods in `ShareViewControllerDelegate`.
    ///
    public static func localAuthorizationStatusForSendingMessage()
        -> MessageShareAuthorizationStatus
    {
        guard let token = AccessTokenStore.shared.current else {
            return .lackOfToken
        }

        return localAuthorizationStatusForSendingMessage(permissions: token.permissions)
    }

    static func localAuthorizationStatusForSendingMessage(permissions: [LoginPermission])
        -> MessageShareAuthorizationStatus
    {
        let lackPermissions = [.oneTimeShare].filter {
            !permissions.contains($0)
        }

        guard lackPermissions.isEmpty else {
            return .lackOfPermissions(lackPermissions)
        }
        return .authorized
    }
}

/// :nodoc:
extension ShareViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        shareDelegate?.shareViewControllerDidCancelSharing(self)
    }

    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return rootViewController.selectedCount == 0
    }
}
