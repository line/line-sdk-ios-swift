//
//  LineSDKShareViewController.swift
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
#if !LineSDKCocoaPods && !LineSDKBinary
import LineSDK
#endif

@objcMembers
public class LineSDKShareViewController: NSObject {

    private var _binaryCompatibleViewController: ShareViewController
    public var viewController: UIViewController {
        return _binaryCompatibleViewController
    }
    
    var delegateProxy: LineSDKShareViewControllerDelegateProxy?

    public var shareNavigationBarTintColor: UIColor {
        get { return _binaryCompatibleViewController.navigationBarTintColor }
        set { _binaryCompatibleViewController.navigationBarTintColor = newValue }
    }

    public var shareNavigationBarTextColor: UIColor {
        get { return _binaryCompatibleViewController.navigationBarTextColor }
        set { _binaryCompatibleViewController.navigationBarTextColor = newValue }
    }

    public var shareStatusBarStyle: UIStatusBarStyle {
        get { return _binaryCompatibleViewController.statusBarStyle }
        set { _binaryCompatibleViewController.statusBarStyle = newValue }
    }

    public var shareMessages: [LineSDKMessage]? {
        get {
            return _binaryCompatibleViewController.messages?.compactMap { .message(with: $0) }
        }
        set {
            _binaryCompatibleViewController.messages = newValue?.compactMap { $0.unwrapped }
        }
    }

    public var shareProxyDelegate: LineSDKShareViewControllerDelegate? {
        get { return delegateProxy?.proxy }
        set {
            delegateProxy = newValue.map { .init(proxy: $0, owner: self) }
            _binaryCompatibleViewController.shareDelegate = delegateProxy
        }
    }
    
    public override init() {
        _binaryCompatibleViewController = ShareViewController()
    }

    @objc public static func localAuthorizationStatusForSendingMessage()
        -> [LineSDKMessageShareAuthorizationStatus]
    {
        return LineSDKMessageShareAuthorizationStatus.status(
            from: ShareViewController.localAuthorizationStatusForSendingMessage()
        )
    }
}

class LineSDKShareViewControllerDelegateProxy: ShareViewControllerDelegate {

    weak var proxy: LineSDKShareViewControllerDelegate?
    unowned var owner: LineSDKShareViewController

    init(proxy: LineSDKShareViewControllerDelegate, owner: LineSDKShareViewController) {
        self.proxy = proxy
        self.owner = owner
    }

    func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError error: LineSDKError)
    {
        proxy?.shareViewController?(owner, didFailLoadingListType: .init(shareType), withError: error)
    }

    func shareViewControllerDidCancelSharing(_ controller: ShareViewController) {
        if let proxy = proxy {
            proxy.shareViewControllerDidCancelSharing?(owner) ?? owner.viewController.dismiss(animated: true)
        } else {
            owner.viewController.dismiss(animated: true)
        }
    }

    func shareViewController(
        _ controller: ShareViewController,
        didFailSendingMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        withError error: LineSDKError)
    {
        proxy?.shareViewController?(
            owner,
            didFailSendingMessages: messages.compactMap { LineSDKMessage.message(with: $0) },
            toTargets: targets.map { $0.sdkShareTarget },
            withError: error)
    }

    func shareViewController(
        _ controller: ShareViewController,
        didSendMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget])
    {
        proxy?.shareViewController?(
            owner,
            didSendMessages: messages.compactMap { LineSDKMessage.message(with: $0) },
            toTargets: targets.map { $0.sdkShareTarget }
        )
    }

    func shareViewController(
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
        guard let proxy = proxy else { return messages }
        let targets = targets.map { $0.sdkShareTarget }
        guard let sdkMessages = proxy.shareViewController?(owner, messagesForSendingToTargets: targets) else {
            return messages
        }
        return sdkMessages.map { $0.unwrapped }
    }

    func shareViewControllerShouldDismissAfterSending(_ controller: ShareViewController) -> Bool {
        return proxy?.shareViewControllerShouldDismissAfterSending?(owner) ?? true
    }
}
