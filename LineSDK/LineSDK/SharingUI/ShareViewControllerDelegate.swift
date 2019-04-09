//
//  ShareViewControllerDelegate.swift
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

/**
 A set of methods that your delegate object could implement to receive share view controller events when user interacts
 with the interface.

 ## Overview

 The methods of this protocol notify your delegate when there is an event happens in the owner `ShareViewController`.
 It is not a must that you provide a delgate object for `ShareViewController`. However, to know events like loading
 fails, user cancellation or message sent successfully, you need to implement the related methods.
*/
public protocol ShareViewControllerDelegate: AnyObject {

    /// Tells the delegate that the loading process fails for a specified type with an error.
    ///
    /// - Parameters:
    ///   - controller: The controller object managing the share interface.
    ///   - shareType: The type which fails to load.
    ///   - error: A value contains information about the detail of the error.
    ///
    /// The `ShareViewController` will automatically load the user's friends and groups list, and use these data to
    /// fill up the table view respectively. If an error happens during the loading process, this delegate method will
    /// be called.
    ///
    /// You can check the `error` parameter to determine what to do next. Usually, the loading failure could be caused
    /// by a bad networking connection, invalid server responses or an API error. The `ShareViewController` does not
    /// provide a way to retry the loading, so you may need to dismiss the current share view controller and let your
    /// user to choose to present a new share view controller or discard the sharing action.
    ///
    /// This method can be called multiple times, since there are multiple list loading in the `ShareViewController`.
    /// Each invocation contains a `shareType` parameter. For a single `shareType`, this method will be called no
    /// more than once.
    ///
    /// See `LineSDKError` for more about handling the errors.
    ///
    func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError error: LineSDKError)

    /// Tells the delegate that the user cancelled the sharing action.
    ///
    /// - Parameter controller: The controller object managing the share interface.
    ///
    /// This method is called when the user cancels sharing action by tapping the "Close" button in the sharing UI.
    ///
    /// Your delegate’s implementation of this method should dismiss the share view controller by calling the
    /// `dismiss(animated:completion:)` method on either the `controller` or on its presenting view controller.
    ///
    /// If you didn't set a delegate object for `ShareViewController` or you didn't implement this method in the
    /// delegate object, the `ShareViewController` will be dismissed with animation for you.
    ///
    func shareViewControllerDidCancelSharing(_ controller: ShareViewController)

    /// Tells the delegate that the message sending fails due to an error.
    ///
    /// - Parameters:
    ///   - controller: The controller object managing the share interface.
    ///   - messages: An array of `Message` values which should be sent.
    ///   - targets: An array of `ShareTarget` values to which the `messages` should be sent to.
    ///   - error: A value contains information about the detail of the error.
    ///
    /// This method is called when the user taps the "Send" button but an error happens during the network request
    /// for sending the messages.
    ///
    /// It means there is a problem when connecting to server, or the server refuses the sending request. There is no
    /// message sent to selected users or groups.
    ///
    /// Check the `error` parameter to know the detail about the error. You may also want to dismiss the current share
    /// view controller and show an error message to the user. See `LineSDKError` for more about handling the errors.
    ///
    /// - Note:
    /// By default, when the message sent and the response received, the share view controller will be dismissed
    /// automatically, unless you implemented the `shareViewControllerShouldDismissAfterSending(_:)` method
    /// in the delegate object and returns `false` there. You can implement that and return `false`, then dismiss the
    /// share view controller yourself if it is necessary.
    ///
    func shareViewController(
        _ controller: ShareViewController,
        didFailSendingMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        withError error: LineSDKError)

    /// Tells the delegate that the message sending succeeded and the messages are delivered to server.
    ///
    /// - Parameters:
    ///   - controller: The controller object managing the share interface.
    ///   - messages: An array of `Message` values which were sent.
    ///   - targets: An array of `ShareTarget` values to which the `messages` should be sent to.
    ///   - results: The sending result which indicate delivering state of the message.
    ///
    /// This method is called when user taps the "Send" button and the server accepted the messages. Delivering the
    /// `messages` to server does not means it is delivered to the `targets`. There is a chance that the selected
    /// target friends or groups block your channel or current user to send message to them, or the target friends or
    /// groups can choose to not receive any messages from an unauthorized channel themselves. In these cases, the
    /// `results` contains `.discarded` as its `status` value in the corresponding result. Check the `results` if
    /// you care about whether the messages are delivered to the selected targets or not.
    ///
    /// - Note:
    /// By default, when the message sent and the response received, the share view controller will be dismissed
    /// automatically, unless you implemented the `shareViewControllerShouldDismissAfterSending(_:)` method
    /// in the delegate object and returns `false` there. You can implement that and return `false`, then dismiss the
    /// share view controller yourself if it is necessary.
    ///
    func shareViewController(
        _ controller: ShareViewController,
        didSendMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        sendingResults results: [ShareSendingResult])

    /// Controls whether the share view controller should dismiss itself after sending messages.
    ///
    /// - Parameter controller: The controller object managing the share interface.
    /// - Returns: Whether the share view controller should dismiss itself after sending messages.
    ///
    /// By default, when the message sent and the response received, the share view controller will be dismissed
    /// automatically, unless you implemented this method in the delegate object and returns `false`.
    /// You can implement it and return `false`, then dismiss the share view controller yourself.
    ///
    /// - Note:
    /// Use this method to get control of the dismiss for share view controller. In the completion handler of your own
    /// dismiss call, you can choose to display an alert in UI to notify users the result of sharing, for example.
    ///
    func shareViewControllerShouldDismissAfterSending(_ controller: ShareViewController) -> Bool

    /// Returns an array of `Message` or `MessageConvertible` for a set of given selected targets to share.
    ///
    /// - Parameters:
    ///   - controller: The controller object managing the share interface.
    ///   - targets: The selected `ShareTarget` values to which user want to send messages.
    /// - Returns: An array of messages to be sent.
    ///
    /// This method is called when user taps the "Send" button and the message sending request is about to be sent to
    /// server. If implemented, the returned `MessageConvertible` array will be sent as the shared messages to selected
    /// targets. It provides the last chance to modify and prepare the messages to send.
    ///
    /// If you didn't set a delegate object for `ShareViewController` or you didn't implement this method in the
    /// delegate object, the value from `ShareViewController.messages` property will be used as the messages to be sent.
    /// You need at least either set the `ShareViewController.messages` to a non-nil value, or implmenet this method
    /// and return a valid message array. Otherwise, a trap will be triggered. If you implemented both, the returned
    /// value from this method will overwrite the `messages` in `ShareViewController`.
    ///
    func shareViewController(
        _ controller: ShareViewController,
        messagesForSendingToTargets targets: [ShareTarget]) -> [MessageConvertible]

}

extension ShareViewControllerDelegate {
    public func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError error: LineSDKError) { }

    public func shareViewControllerDidCancelSharing(_ controller: ShareViewController) {
        controller.dismiss(animated: true)
    }

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
    public func shareViewControllerShouldDismissAfterSending(_ controller: ShareViewController) -> Bool {
        return true
    }
}
