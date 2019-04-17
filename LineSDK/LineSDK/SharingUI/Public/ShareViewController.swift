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

/// Represents the sending results when sending messages to friends or groups through `ShareViewController`.
/// In the result, a destination user or group ID of this result and a `MessageSendingStatus` will be contained.
/// See `MessageSendingStatus` for more information on the sending status.
public typealias ShareSendingResult = PostMultisendMessagesRequest.Response.SendingResult

/**
 A view controller that provides a default UI for selecting friends and groups,
 then share a `Message` to the selected targets.

 ## Overview

 A `ShareViewController` allows users to use a default user interface to share a message to LINE.
 An authorized user can browse, search and select up to 10 users or groups in a tab based table view UI.
 After selecting share target, the user can tap the "Send" button to share a preset `Message` to the selected
 targets. These messages will be delivered to target users or groups in the name of the user himself/herself.

 The `ShareViewController` is a subclass of `UINavigationController`, so you need to create and present it modally.
 To use the `ShareViewController`, follow these steps:

 1. Verify that the user has authorized your app with enough permission. `ShareViewController` will show both
 Friends and Groups tabs. To get the friend list and group list, you need `LoginPermission.friends` and
 `Login.groups`. To send a message, it also requires `LoginPermisson.messageWrite`.
 Use `ShareViewController.localAuthorizationStatusForSendingMessage(to:)` to check whether you have a valid token with
 enough permissions. If you do not have enough permissions, you should not create and show the `ShareViewController`,
 but prompt your user to authorize your app with these permissions.

 2. Create a `ShareViewController` instance. `ShareViewController` does not support to be initialized from Storyboard or
 XIB. You need to create one with the provided initializer `init()`.

 3. Set `messages` to tell the `ShareViewController` the `Message` values you want to share.

 4. Presents the created `ShareViewController` in a modal way. Do this modally by calling the
 `present(_:animated:completion:)`.

 You can customize the `ShareViewController` navigation bar style and status bar content style to match your app.
 Use `navigationBarTintColor`, `navigationBarTextColor` and `statusBarStyle` for this purpose.

 ## Share Delegate

 `ShareViewController` will deliver results of user interaction to a delegate object. To get these related events,
 you must provide a delegate that conforms to the `ShareViewControllerDelegate` protocol, and set it to `shareDelegate`
 property.

 See `ShareViewControllerDelegate` for more information.

 - Warning:
 Although `ShareViewController` is marked as `open`, it is not recommended to create a subclass for it. This class is
 intended to be used as-is and provide a default sharing experience across all LINE and LINE SDK integrations. The users
 may expect the same UI and interaction when they want to share a message to friends and groups in LINE.
 If it is important for you to provide a fully customized sharing interaction, you can use the related APIs to create
 your own UIs.
 */
open class ShareViewController: UINavigationController {

    enum Design {
        static var navigationBarTintColor: UIColor { return .init(hex6: 0x283145) }
        static var preferredStatusBarStyle: UIStatusBarStyle  { return  .lightContent }
        static var navigationBarTextColor:  UIColor { return  .white }
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
    /// controller or the sharing finishes successfully. You can choose to implement one or more methods to provide
    /// your users better experience when an event happens.
    ///
    /// For information about the methods you can implement for your delegate object,
    /// see `ShareViewControllerDelegate`.
    ///
    public weak var shareDelegate: ShareViewControllerDelegate?

    /// The `Message`s are about to be sent.
    ///
    /// - Note:
    /// If you didn't set the `shareDelegate` for `ShareViewController` or you didn't implement the
    /// `shareViewController(_:messagesForSendingToTargets:)` method in the delegate object, the value from
    /// this property will be used as the messages to be sent.
    ///
    /// You need at least either set this property to a non-nil value, or implement the
    /// `shareViewController(_:messagesForSendingToTargets:)` delegate method and return a valid message array.
    /// Otherwise, a trap will be triggered. If you implemented both, the returned value from delegate method will
    /// overwrite value in this property.
    ///
    public var messages: [MessageConvertible]? {
        set { rootViewController.messages = newValue }
        get { return rootViewController.messages }
    }

    private let rootViewController = ShareRootViewController()

    // MARK: - Initializers

    /// Creates a `ShareViewController` with default behavior. You should always use this initializer to create a
    /// `ShareViewController` instance.
    public init() {
        super.init(nibName: nil, bundle: nil)
        setupRootDelegates()
        self.viewControllers = [rootViewController]
        updateNavigationStyles()
    }

    /// `ShareViewController` does not support to be created from Storyboard or XIB file. This method just throw a
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
                shareDelegate.shareViewControllerDidCancelSharing(self)
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
            return self.shareDelegate?.shareViewControllerShouldDismissAfterSending(self) ?? true
        }
    }

    private func updateNavigationStyles() {
        navigationBar.shadowImage = UIImage()
        navigationBar.barTintColor = navigationBarTintColor
        navigationBar.tintColor = navigationBarTextColor
        navigationBar.titleTextAttributes = [.foregroundColor: navigationBarTextColor]
    }
}

/// Represents the authorization status for sharing messages.
/// Before creating and presenting a message sharing UI, it is strongly recommended to check whether your app
/// has a valid token and enough permissions to share messages.
///
/// `ShareViewController.localAuthorizationStatusForSendingMessage(to:)` returns a `MessageShareAuthorizationStatus` value
/// to indicated the current authorization status for a certain sharing target.
///
/// - lackOfToken: There is no valid token in the token store locally. The user does not log in and authorize
///                your app yet.
/// - lackOfPermissions: There is a valid token, but it does not contain enough permission to share a message. The
///                      associated value is an array of `LoginPermission`, which contains all lacked permissions.
/// - authorized: The token exists locally and it contains all necessary permissions to perform sharing.
///
public enum MessageShareAuthorizationStatus {
    case lackOfToken
    case lackOfPermissions([LoginPermission])
    case authorized
}

// MARK: - Authorization Helpers
extension ShareViewController {

    /// Gets the local authorization status for sending message to friends and groups.
    ///
    /// - Returns: The local authorization status from current stored token and its permissions.
    ///
    /// - Note:
    ///
    /// If the return value is `.authorized`, you can present an `ShareViewController` instance for sharing purpose.
    /// But even if you get `.authorized` status, it is not enough to get a conclusion that the sharing would success
    /// without a token or permission issue. The token status is a local state and might not be synchronized with the
    /// server status. It is still possible that the token is expired or revoked by server or from another client.
    ///
    /// To get the accurate result of sharing behavior, set the `ShareViewController.shareDelegate` and implement
    /// methods in `ShareViewControllerDelegate`.
    ///
    public static func localAuthorizationStatusForSendingMessage()
        -> MessageShareAuthorizationStatus
    {
        guard let token = AccessTokenStore.shared.current else {
            return .lackOfToken
        }

        let lackPermissions = [.friends, .groups, .messageWrite].filter {
            token.permissions.contains($0)
        }

        guard lackPermissions.isEmpty else {
            return .lackOfPermissions(lackPermissions)
        }
        return .authorized
    }
}
