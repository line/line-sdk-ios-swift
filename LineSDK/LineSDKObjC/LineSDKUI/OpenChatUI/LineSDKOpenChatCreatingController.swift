//
//  LineSDKOpenChatCreatingController.swift
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

@objcMembers
@MainActor
public class LineSDKOpenChatCreatingController: NSObject {
    
    let _value: OpenChatCreatingController
    
    public override init() {
        _value = OpenChatCreatingController()
    }
    
    var delegateProxy: LineSDKOpenChatCreatingControllerDelegateProxy?
    
    public var delegate: LineSDKOpenChatCreatingControllerDelegate? {
        get { return delegateProxy?.proxy }
        set {
            delegateProxy = newValue.map { .init(proxy: $0, owner: self) }
            _value.delegate = delegateProxy
        }
    }
    
    public var suggestedCategory: Int {
        get { return _value.suggestedCategory.rawValue }
        set {
            guard let category = OpenChatCategory(rawValue: newValue) else {
                return
            }
            _value.suggestedCategory = category
        }
    }
    
    public func loadAndPresent(
        in viewController: UIViewController,
        presentedHandler handler: @escaping (UIViewController?, Error?) -> Void
    )
    {
        _value.loadAndPresent(in: viewController) { result in
            result.match(with: handler)
        }
    }
    
    public static func localAuthorizationStatusForCreatingOpenChat() -> LineSDKAuthorizationStatus
    {
        return LineSDKAuthorizationStatus.status(
            from: OpenChatCreatingController.localAuthorizationStatusForCreatingOpenChat()
        )
    }
}

class LineSDKOpenChatCreatingControllerDelegateProxy: OpenChatCreatingControllerDelegate {
    weak var proxy: LineSDKOpenChatCreatingControllerDelegate?
    unowned var owner: LineSDKOpenChatCreatingController
    
    init(proxy: LineSDKOpenChatCreatingControllerDelegate, owner: LineSDKOpenChatCreatingController) {
        self.proxy = proxy
        self.owner = owner
    }
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didCreateChatRoom room: OpenChatRoomInfo,
        withCreatingItem item: OpenChatRoomCreatingItem
    )
    {
        proxy?.openChatCreatingController?(owner, didCreateChatRoom: .init(room), withCreatingItem: .init(item))
    }
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didFailWithError error: LineSDKError,
        withCreatingItem item: OpenChatRoomCreatingItem,
        presentingViewController: UIViewController
    )
    {
        proxy?.openChatCreatingController?(
            owner,
            didFailWithError: error,
            withCreatingItem: .init(item),
            presentingViewController: presentingViewController
        )
    }
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        shouldPreventUserTermAlertFrom presentingViewController: UIViewController
    ) -> Bool {
        return proxy?.openChatCreatingController?(owner, shouldPreventUserTermAlertFrom: presentingViewController)
            ?? false
    }
    
    func openChatCreatingControllerDidCancelCreating(_ controller: OpenChatCreatingController) {
        proxy?.openChatCreatingControllerDidCancelCreating?(owner)
    }
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        willPresentCreatingNavigationController navigationController: OpenChatCreatingNavigationController)
    {
        proxy?.openChatCreatingController?(owner, willPresentCreatingNavigationController: navigationController)
    }
}
