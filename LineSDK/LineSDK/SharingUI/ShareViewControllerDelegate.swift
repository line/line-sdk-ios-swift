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
