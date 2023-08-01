//
//  OpenChatCreatingController.swift
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

/// A controller which manages open chat creating operations.
///
/// It checks whether the Open Chat user term has been accepted by current user. If accepted, LINE SDK shows a standard
/// open chat creating interface to collect information from user input, then try to create the open chat room based on
/// them. Otherwise, the user is prompted to agree the term first before an open chat room can be created.
///
/// It is encouraged to call `OpenChatCreatingController.localAuthorizationStatusForCreatingOpenChat()` first and check
/// the authorization status to make sure your user has authorized you to create an open chat. Then call
/// `loadAndPresent(in:presentedHandler:)` to show the built-in UI to collect user information and create the open chat
/// room.
///
/// To get the result of the creating controller or have more control of the behaviors, implement methods in
/// `OpenChatCreatingControllerDelegate` and set `delegate` property of an `OpenChatCreatingController` instance.
///
/// - Note:
/// The class is intended to be used as-is and to provide a default open chat creating experience across all LINE and
/// LINE SDK integrations. Users expect a consistent UI and interaction across different apps when using the Open Chat
/// features. But if it's so important for you to provide a fully customized sharing interaction, you can still use the
///  related APIs to create your own UIs.
///
public class OpenChatCreatingController {
    
    /// The delegate object of this open chat creating controller.
    ///
    /// The delegate receives events when user encounters an error during open chat creating, user cancels the creating,
    /// or the creating finishes successfully. You can choose to implement one or more methods to offer your users a
    /// better experience when an event happens.
    ///
    /// For information about the methods you can implement for your delegate object,
    /// see `OpenChatCreatingControllerDelegate`.
    ///
    public weak var delegate: OpenChatCreatingControllerDelegate?
    
    /// The suggested category shows as the default category when user creates a new open chat room.
    ///
    /// - Note:
    /// Users can select a category in UI from a predefined list of `OpenChatCategory`s. It determines which category
    /// the created room should belong to. The `suggestedCategory` value will be show as the selected state when the
    /// user opens open chat creating UI.
    ///
    /// It does not prevent users from selecting another category from the list.
    public var suggestedCategory: OpenChatCategory = .notSelected
    
    /// Creates a `OpenChatCreatingController` with default behavior. Always use this initializer to create an
    /// `OpenChatCreatingController` instance.
    public init() { }
    
    /// Loads the user term agreement status and shows the open chat room UI if possible.
    /// - Parameters:
    ///   - viewController: A presenting view controller from which the open chat creating view controller should be
    ///                     presented from. Normally, it should be your current top-most view controller which takes
    ///                     responsibility of user interaction.
    ///   - handler: A block called when the open chat creating view controller presenting action is done with a result.
    ///
    /// - Note:
    /// If the `handler` is called with a `.failure` case, it means there is no view controller from LINE SDK
    /// shown. A few reasons can cause it, such as term agreement status cannot be retrieved due to network error.
    /// On the other hand, a `.success` case and its associated value means a view controller from LINE SDK is
    /// presented. But it does not mean that the open chat room is created. To handle either the creating failure or
    /// success case for the whole process, you need to use the methods in `OpenChatCreatingControllerDelegate`.
    ///
    /// For either result, it is a chance for you to remove any blocking UI you may add to your view controller, like
    /// this in your view controller:
    ///
    /// ```
    /// self.showLoadingIndicator()
    /// OpenChatCreatingController.loadAndPresent(in: self) { _ in
    ///     self.hideLoadingIndicator()
    /// }
    /// ```
    public func loadAndPresent(
        in viewController: UIViewController,
        presentedHandler handler: ((Result<UIViewController, LineSDKError>) -> Void)? = nil
    )
    {
        let checkTermRequest = GetOpenChatTermAgreementStatusRequest()
        Session.shared.send(checkTermRequest) { result in
            switch result {
            case .success(let response):
                if response.agreed {
                    self.presentCreatingViewController(in: viewController, handler: handler)
                } else {
                    let shouldPreventAlert = self.delegate?.openChatCreatingController(
                        self, shouldPreventUserTermAlertFrom: viewController)
                        ?? false
                    if !shouldPreventAlert {
                        self.presentTermAgreementAlert(in: viewController, handler: handler)
                    }
                }
                
            case .failure(let error):
                handler?(.failure(error))
            }
        }
    }
    
    func presentTermAgreementAlert(
        in viewController: UIViewController,
        handler: ((Result<UIViewController, LineSDKError>) -> Void)? = nil
    )
    {
        let alert = UIAlertController(
            title: nil,
            message: Localization.string("openchat.not.agree.with.terms"),
            preferredStyle: .alert
        )

        if Constant.isLINEInstalled {
            alert.addAction(
                .init(title: Localization.string("common.cancel"), style: .cancel)
            )
            alert.addAction(
                .init(title: Localization.string("open.line"), style: .default) { _ in
                    UIApplication.shared.openLINEApp()
                }
            )
        } else {
            alert.addAction(
                .init(title: Localization.string("common.ok"), style: .cancel)
            )
        }
        viewController.present(alert, animated: true) { handler?(.success(alert)) }
    }
    
    func presentCreatingViewController(
        in viewController: UIViewController,
        handler: ((Result<UIViewController, LineSDKError>) -> Void)?
    )
    {
        let (navigation, roomInfoFormViewController) = OpenChatRoomInfoViewController.createViewController(self)
        roomInfoFormViewController.suggestedCategory = suggestedCategory

        roomInfoFormViewController.onClose.delegate(on: self) { (self, vc) in
            vc.dismiss(animated: true) {
                self.delegate?.openChatCreatingControllerDidCancelCreating(self)
            }
        }
        roomInfoFormViewController.onNext.delegate(on: self) { [unowned navigation] (self, item) in
            let userInfoFormViewController = OpenChatUserProfileViewController()
            
            var itemCopy = item
            if let cachedName = UserDefaultsValue.cachedOpenChatUserProfileName {
                itemCopy.userName = cachedName
            }
            userInfoFormViewController.formItem = itemCopy
            
            userInfoFormViewController.onProfileDone.delegate(on: self) { [unowned navigation] (self, item) in
                
                let room = OpenChatRoomCreatingItem(form: item)
                let createRoomRequest = PostOpenChatCreateRequest(room: room)
                
                let indicator = LoadingIndicator.add(to: navigation.view)
                Session.shared.send(createRoomRequest) { result in
                    indicator.remove()
                    switch result {
                    case .success(let response):
                        UserDefaultsValue.cachedOpenChatUserProfileName = room.creatorDisplayName
                        navigation.dismiss(animated: true) {
                            self.delegate?.openChatCreatingController(
                                self, didCreateChatRoom: response, withCreatingItem: room
                            )
                        }
                    case .failure(let error):
                        self.delegate?.openChatCreatingController(
                            self,
                            didFailWithError: error,
                            withCreatingItem: room,
                            presentingViewController: navigation
                        )
                    }
                }
            }
            
            navigation.pushViewController(userInfoFormViewController, animated: true)
        }
        
        navigation.modalPresentationStyle = .fullScreen
        
        delegate?.openChatCreatingController(self, willPresentCreatingNavigationController: navigation)
        viewController.present(navigation, animated: true) { handler?(.success(navigation)) }
    }
}

extension OpenChatCreatingController {
    
    /// Gets the local authorization status for creating an open chat room.
    ///
    /// - Returns: The local authorization status based on the currently stored token and the permissions specified
    ///            in that token.
    ///
    /// - Note:
    ///   If the return value is `.authorized`, you can present a `OpenChatCreatingController` instance for creating a
    ///   room. But `.authorized` status doesn't necessarily mean the creating would succeed; there may be problems with
    ///   the token or permissions.
    ///   
    ///   The token status is stored locally and may not have been synchronized with the server-side status.
    ///   The token may have expired or been revoked by the server or via another client.
    ///
    /// To get the correct result about creating behavior, specify `OpenChatCreatingController.delegate` and implement
    /// the methods in `OpenChatCreatingControllerDelegate`.
    ///
    public static func localAuthorizationStatusForCreatingOpenChat() -> AuthorizationStatus {
        guard let token = AccessTokenStore.shared.current else {
            return .lackOfToken
        }

        return localAuthorizationStatusForOpenChat(permissions: token.permissions)
    }
    
    static func localAuthorizationStatusForOpenChat(permissions: [LoginPermission])
        -> AuthorizationStatus
    {
        let lackPermissions = Set([.openChatTermStatus, .openChatRoomCreateAndJoin]).filter {
            !permissions.contains($0)
        }

        guard lackPermissions.isEmpty else {
            return .lackOfPermissions(lackPermissions)
        }
        return .authorized
    }
}
