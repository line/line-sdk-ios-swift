//
//  OpenChatCreatingControllerDelegate.swift
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

/**
 A set of methods that your delegate object could implement to receive open chat controller events when user interacts
 with the interface.
 
 The methods of this protocol notify your delegate when an event happens in the owner `OpenChatCreatingController`.
 Although specifying a delegate object for `OpenChatCreatingController` isn't strictly required, we strongly recommend
 that you do so.
 
 Without implementing the delegate methods, you can't receive information about events like network failure, user
 cancellation or open chat creating done.
 */
public protocol OpenChatCreatingControllerDelegate: AnyObject {
    
    /// Tells the delegate that the new open chat room is created successfully.
    /// - Parameters:
    ///   - controller: The controller object for this event.
    ///   - room: Information of the created chat room.
    ///   - item: The basic setting of the room when creating.
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didCreateChatRoom room: OpenChatRoomInfo,
        withCreatingItem item: OpenChatRoomCreatingItem
    )
    
    /// Tells the delegate that an error happens during the room creation request.
    /// - Parameters:
    ///   - controller: The controller object for this event.
    ///   - error: A value containing the details of the error.
    ///   - item: The basic setting of the room when creating.
    ///   - presentingViewController: The view controller which presents the current room creating view controller.
    ///                               Present your error handling UI with this view controller, if needed.
    ///
    /// - Note:
    /// This delegate method will only be called during the creation operation, after the `OpenChatCreatingController`
    /// collected all necessary open chat room information from user input. The collected information is in the
    /// `item` parameter.
    ///
    /// If a user term related error happens before the LINE SDK has a chance to collect user input, another delegate
    /// method, `openChatCreatingController(_:didEncounterUserAgreementError:presentingViewController:)` will be called.
    ///
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didFailWithError error: LineSDKError,
        withCreatingItem item: OpenChatRoomCreatingItem,
        presentingViewController: UIViewController
    )
    
    /// Tells the delegate that an error happens when checking the user agreement status for open chat.
    /// - Parameters:
    ///   - controller: The controller object for this event.
    ///   - error: A value containing the details of the error.
    ///   - presentingViewController: The view controller which presents the current room creating view controller.
    ///                               Present your error handling UI with this view controller, if needed.
    /// - Returns:
    /// A flag indicates whether LINE SDK should prevent displaying a default alert when the user agreement is not
    /// accepted yet.
    ///
    /// - Note:
    /// To create an open chat room, the user must accept the user agreement term of Open Chat. An
    /// `OpenChatCreatingController` will check the agreement status and determine whether the user already agreed with
    /// it.
    ///
    /// This delegate method will only be called during checking user agreement status before the user can input the
    /// room information or create the room actually.
    ///
    /// If not implemented, a default alert will be shown to ask the user to check their agreement status, or open the
    /// LINE app if it is installed, to agree the term. You can override this behavior and UI by providing your own
    /// implementation of this delegate method, and return a `true` to tell LINE SDK you have handled the case.
    ///
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        shouldPreventUserTermAlertFrom presentingViewController: UIViewController
    ) -> Bool
    
    /// Tells the delegate that the user cancelled the open chat creating action.
    /// - Parameter controller: The controller object for this event.
    func openChatCreatingControllerDidCancelCreating(_ controller: OpenChatCreatingController)
    
    /// Tells the delegate that the open chat creating view controller is about to be presented. It is a chance that
    /// you can do some customization for style of the presented view controller to match your app's UI better.
    /// - Parameters:
    ///   - controller: The controller object for this event.
    ///   - navigationController: The `OpenChatCreatingNavigationController` which is about to show.
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        willPresentCreatingNavigationController navigationController: OpenChatCreatingNavigationController
    )
}

public extension OpenChatCreatingControllerDelegate {
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didCreateChatRoom room: OpenChatRoomInfo,
        withCreatingItem item: OpenChatRoomCreatingItem
    )
    {}
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didFailWithError error: LineSDKError,
        withCreatingItem item: OpenChatRoomCreatingItem,
        presentingViewController: UIViewController
    )
    {}
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        shouldPreventUserTermAlertFrom presentingViewController: UIViewController
    ) -> Bool
    {
        return false
    }
    
    func openChatCreatingControllerDidCancelCreating(_ controller: OpenChatCreatingController) {}
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        willPresentCreatingNavigationController navigationController: OpenChatCreatingNavigationController
    )
    {}
}
