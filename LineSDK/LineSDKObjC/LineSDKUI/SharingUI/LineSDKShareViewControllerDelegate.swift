//
//  LineSDKShareViewControllerDelegate.swift
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

#if !LineSDKCocoaPods && !LineSDKBinary
import LineSDK
#endif

@objc public protocol LineSDKShareViewControllerDelegate: AnyObject {
    @objc optional func shareViewController(
        _ controller: LineSDKShareViewController,
        didFailLoadingListType shareType: LineSDKMessageShareTargetType,
        withError error: Error)
    @objc optional func shareViewControllerDidCancelSharing(_ controller: LineSDKShareViewController)
    @objc optional func shareViewController(
        _ controller: LineSDKShareViewController,
        didFailSendingMessages messages: [LineSDKMessage],
        toTargets targets: [LineSDKShareTarget],
        withError error: Error)

    @objc optional func shareViewController(
        _ controller: LineSDKShareViewController,
        didSendMessages messages: [LineSDKMessage],
        toTargets targets: [LineSDKShareTarget])

    @objc optional func shareViewController(
        _ controller: LineSDKShareViewController,
        messagesForSendingToTargets targets: [LineSDKShareTarget]) -> [LineSDKMessage]

    @objc optional func shareViewControllerShouldDismissAfterSending(
        _ controller: LineSDKShareViewController) -> Bool
}
