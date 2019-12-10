//
//  OpenChatController.swift
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

public protocol OpenChatControllerDelegate: AnyObject {
    func openChatController(
        _ controller: OpenChatController,
        didCreateChatRoom room: OpenChatRoomInfo,
        withCreatingItem item: OpenChatRoomCreatingItem
    )
    
    func openChatController(
        _ controller: OpenChatController,
        didFailWithError error: LineSDKError,
        withCreatingItem item: OpenChatRoomCreatingItem,
        presentingViewController: UIViewController
    )
    
    func openChatController(
        _ controller: OpenChatController,
        didEncounterUserAgreementError error: LineSDKError,
        presentingViewController: UIViewController
    )
    
    func openChatControllerDidCancelCreating(_ controller: OpenChatController)
    
    func openChatController(
        _ controller: OpenChatController,
        willPresentCreatingNavigationController navigationController: OpenChatCreatingNavigationController
    )
}

public class OpenChatController {
    
    public weak var delegate: OpenChatControllerDelegate?
    public var suggestedCategory: OpenChatCategory = .notSelected
        
    public init() { }
    
    deinit {
        print("Deinit")
    }
    
    public func loadAndPresent(
        in viewController: UIViewController,
        presentedHandler handler: ((Result<Void, LineSDKError>) -> Void)? = nil
    )
    {
        let checkTermRequest = GetOpenChatTermAgreementStatusRequest()
        Session.shared.send(checkTermRequest) { result in
            switch result {
            case .success(let response):
                if !response.agreed {
                    self.presentTermAgreementViewController(in: viewController, handler: handler)
                } else {
                    self.presentCreatingViewController(in: viewController, handler: handler)
                }
                
            case .failure(let error):
                handler?(.failure(error))
            }
        }
    }
    
    func presentTermAgreementViewController(
        in viewController: UIViewController,
        handler: ((Result<Void, LineSDKError>) -> Void)? = nil
    )
    {
        let (navigation, termAgreementViewController) = OpenChatTermAgreementViewController.createViewController(self)
        
        termAgreementViewController.onAgreed.delegate(on: self) { [unowned navigation] (self, vc) in
            let indicator = LoadingIndicator.add(to: navigation.view)
            let request = PutOpenChatTermAgreementUpdateRequest(agreed: true)
            Session.shared.send(request) { result in
                indicator.remove()
                switch result {
                case .success:
                    vc.dismiss(animated: true) {
                        self.presentCreatingViewController(in: viewController, handler: nil)
                    }
                case .failure(let error):
                    self.delegate?.openChatController(
                        self,
                        didEncounterUserAgreementError: error,
                        presentingViewController: navigation
                    )
                }
            }
        }
        
        termAgreementViewController.onClose.delegate(on: self) { (self, vc) in
            vc.dismiss(animated: true) {
                self.delegate?.openChatControllerDidCancelCreating(self)
            }
        }

        navigation.modalPresentationStyle = .fullScreen
        viewController.present(navigation, animated: true) { handler?(.success(())) }
    }
    
    func presentCreatingViewController(
        in viewController: UIViewController,
        handler: ((Result<Void, LineSDKError>) -> Void)?
    )
    {
        let (navigation, roomInfoFormViewController) = OpenChatRoomInfoViewController.createViewController(self)
        roomInfoFormViewController.suggestedCategory = suggestedCategory

        roomInfoFormViewController.onClose.delegate(on: self) { (self, vc) in
            vc.dismiss(animated: true) {
                self.delegate?.openChatControllerDidCancelCreating(self)
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
                            self.delegate?.openChatController(self, didCreateChatRoom: response, withCreatingItem: room)
                        }
                    case .failure(let error):
                        self.delegate?.openChatController(
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
        
        delegate?.openChatController(self, willPresentCreatingNavigationController: navigation)
        viewController.present(navigation, animated: true) { handler?(.success(())) }
    }
    
}

public enum OpenChatAuthorizationStatus {
    case lackOfToken
    case lackOfPermissions(Set<LoginPermission>)
    case authorized
}

extension OpenChatController {
    public static func localAuthorizationStatusForSendingMessage() -> OpenChatAuthorizationStatus {
        guard let token = AccessTokenStore.shared.current else {
            return .lackOfToken
        }

        return localAuthorizationStatusForOpenChat(permissions: token.permissions)
    }
    
    static func localAuthorizationStatusForOpenChat(permissions: [LoginPermission])
        -> OpenChatAuthorizationStatus
    {
        let lackPermissions = Set([.openChatTermStatus, .openChatTermAgree, .openChatRoomCreate]).filter {
            !permissions.contains($0)
        }

        guard lackPermissions.isEmpty else {
            return .lackOfPermissions(lackPermissions)
        }
        return .authorized
    }
}
