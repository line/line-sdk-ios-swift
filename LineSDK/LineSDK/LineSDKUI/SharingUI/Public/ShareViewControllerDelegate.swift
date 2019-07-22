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

 The methods of this protocol notify your delegate when an event happens in the owner `ShareViewController`.
 Although specifying a delegate object for `ShareViewController` isn't strictly required, we strongly recommend
 that you do so. Without implementing the delegate methods, you can't retrieve information about events like 
 loading failure, user cancellation, or message sending success.
*/
public protocol ShareViewControllerDelegate: AnyObject {

    /// Tells the delegate that the loading process fails for a specified type with an error.
    ///
    /// - Parameters:
    ///   - controller: The controller object managing the share interface.
    ///   - shareType: The type which fails to load.
    ///   - error: A value containing the details of the error.
    ///
    /// The `ShareViewController` will automatically load the user's friends and groups list, and use them to populate 
    /// the respective table views. If an error happens during the loading process, this delegate method is called.
    ///
    /// You can check the `error` parameter to decide what to do next. The loading failure could be caused by a bad 
    /// network connection, invalid server responses, or an API error. `ShareViewController` doesn't offer a way to 
    /// retry loading, so you may need to dismiss the current share view controller instance and prompt your user choose 
    /// to start a new sharing action or cancel altogether.
    ///
    /// This method can be called multiple times, since there are multiple lists loading in the `ShareViewController`.
    /// Each invocation contains a `shareType` parameter. For a single `shareType`, this method will be called no more 
    /// than once.
    ///
    /// See `LineSDKError` for more about error handling.
    ///
    func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError error: LineSDKError)

    /// Tells the delegate that the user cancelled the sharing action.
    ///
    /// - Parameter controller: The controller object managing the share interface.
    ///
    /// When the user cancels sharing action by tapping the "Close" button in the sharing UI, the `ShareViewController`
    /// will be dismissed with an animation and this delegate method is called after the dismissing animation finished.
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
    /// This method is called when the user taps "Send" but an error happens during the network request for sending the 
    /// messages.
    ///
    /// It means there is a problem while connecting to the server, or the server refused the request. No message is 
    /// sent to selected users or groups.
    ///
    /// Check the `error` parameter for error details. You may also want to dismiss the current share view controller 
    /// and show an error message to the user. See `LineSDKError` for more about error handling.
    ///
    /// - Note:
    /// By default, after the message is sent and the response received, the share view controller is dismissed
    /// automatically. You can prevent this by implementing the `shareViewControllerShouldDismissAfterSending(_:)` 
    /// method in the delegate object and returning `false` there. You can then dismiss the share view controller 
    /// yourself if necessary.
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
    ///
    /// This method is called when the user taps "Send" and the server accepts the messages. Delivering the `messages` 
    /// to the server doesn't mean they'll be actually delivered to the `targets`. The target friends or groups may
    /// have blocked your channel or the current user from sending them messages. They can also choose to block
    /// messages from unauthorized channels.
    ///
    /// - Note:
    /// By default, after the message is sent and the response received, the share view controller is dismissed
    /// automatically. You can prevent this by implementing the `shareViewControllerShouldDismissAfterSending(_:)` 
    /// method in the delegate object and returning `false` there. You can then dismiss the share view controller 
    /// yourself if necessary.
    ///
    func shareViewController(
        _ controller: ShareViewController,
        didSendMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget])

    /// Controls whether the share view controller should dismiss itself after sending messages.
    ///
    /// - Parameter controller: The controller object managing the share interface.
    /// - Returns: Whether the share view controller should dismiss itself after sending messages.
    ///
    /// By default, after the message is sent and the response received, the share view controller is dismissed
    /// automatically. You can prevent this by implementing the `shareViewControllerShouldDismissAfterSending(_:)` 
    /// method in the delegate object and returning `false` there. You can then dismiss the share view controller 
    /// yourself if necessary.
    ///
    /// - Note:
    /// Use this method to control dismissal of the share view controller. In the completion handler of your own dismiss 
    /// call, you can choose to display an alert in UI to notify users the result of sharing, for example.
    ///
    func shareViewControllerShouldDismissAfterSending(_ controller: ShareViewController) -> Bool

    /// Returns an array of `Message` or `MessageConvertible` for a set of given selected targets to share.
    ///
    /// - Parameters:
    ///   - controller: The controller object managing the share interface.
    ///   - targets: The selected `ShareTarget` values to which user want to send messages.
    /// - Returns: An array of messages to be sent.
    ///
    /// This method is called when the user taps "Send" and the message sending request is about to be sent to the 
    /// server. If implemented, the messages in the returned `MessageConvertible` array are sent to the selected targets. 
    /// This step provides a final chance to modify and prepare the messages to send.
    ///
    /// If you didn't set a delegate object for `ShareViewController` or you didn't implement this method in the
    /// delegate object, the value from `ShareViewController.messages` property will be used as the messages to be sent.
    /// You must either set the `ShareViewController.messages` to a non-nil value, or implement this method and return a 
    /// valid message array. If you don't, a trap will be triggered. If you implemented both, the returned value from 
    /// this method will overwrite the `messages` in `ShareViewController`.
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

    public func shareViewControllerDidCancelSharing(_ controller: ShareViewController) {}

    public func shareViewController(
        _ controller: ShareViewController,
        didFailSendingMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        withError error: LineSDKError) { }

    public func shareViewController(
        _ controller: ShareViewController,
        didSendMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget]) { }

    public func shareViewController(
        _ controller: ShareViewController,
        messagesForSendingToTargets targets: [ShareTarget]) -> [MessageConvertible]
    {
        guard let messages = controller.messages else {
            Log.fatalError(
                """
                You need at least set the `ShareViewController.message` or implement
                `shareViewController(:messageForSendingToTargets:)` before sharing a message.)
                """
            )
        }
        return messages
    }
    public func shareViewControllerShouldDismissAfterSending(_ controller: ShareViewController) -> Bool {
        return true
    }
}
