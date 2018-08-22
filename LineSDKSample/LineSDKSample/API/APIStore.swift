//
//  APIStore.swift
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

import Foundation
import LineSDK

enum APICategory: Int {
    case auth
    case graph
    case messaging
    
    static let count = 3
}

class APIStore {
    static let shared = APIStore()
    
    private(set) var authAPIs: [APIItem] = []
    private(set) var graphAPIs: [APIItem] = []
    private(set) var messagingAPIs: [APIItem] = []
    
    private init() {
        refresh()
        let center = NotificationCenter.default
        center.addObserver(forName: .LineSDKAccessTokenDidUpdate , object: nil, queue: nil) { _ in
            self.refresh()
        }
        center.addObserver(forName: .LineSDKAccessTokenDidRemove , object: nil, queue: nil) { _ in
            self.refresh()
        }
    }
    
    func refresh() {
        authAPIs = [
            .init(
                title: "Get User Profile",
                request: GetUserProfileRequest()
            ),
            .init(
                title: "Verify Token",
                request: GetVerifyTokenRequest(accessToken: AccessTokenStore.shared.current?.value ?? ""),
                avaliable: AccessTokenStore.shared.current != nil
            )
        ]
        
        graphAPIs = [
            .init(title: "Get Friends" ,
                  request: GetFriendsRequest()
            ),
            .init(title: "Get Approvers in Friends",
                  request: GetApproversInFriendsRequest()
            ),
            .init(title: "Get Groups",
                  request: GetGroupsRequest()
            ),
            .getApproversInGroup
        ]
        
        messagingAPIs = [
            .sendTextMessage,
            .multiSendTextMessage,
            .sendFlexMessage
        ]
    }
    
    func numberOfAPIs(in category: APICategory) -> Int {
        switch category {
        case .auth: return authAPIs.count
        case .graph: return graphAPIs.count
        case .messaging: return messagingAPIs.count
        }
    }
    
    func api(in category: APICategory, at index: Int) -> APIItem {
        switch category {
        case .auth: return authAPIs[index]
        case .graph: return graphAPIs[index]
        case .messaging: return messagingAPIs[index]
        }
    }
}

struct APIItem {
    
    typealias AnyResultBlock = ((UIViewController, (Result<Any>) -> Void)) -> Void
    
    let block: AnyResultBlock
    
    let path: String
    let title: String
    
    let avaliable: Bool
    
    init<T: Request>(title: String, request: T, avaliable: Bool = true) {
        self.init(title: title, path: request.path, avaliable: avaliable) { (controller, handler) in
            Session.shared.send(request) { result in handler(result.map { $0 as Any }) }
        }
    }
    
    init(title: String, path: String, avaliable: Bool = true, block: @escaping AnyResultBlock) {
        self.title = title
        self.path = path
        
        self.block = block
        self.avaliable = avaliable
    }
    
    func execute(with controller: UIViewController, handler: @escaping (Result<Any>) -> Void) -> Void {
        block((controller, handler))
    }
}

extension APIItem {
    static var sendTextMessage: APIItem {
        let mock = PostSendMessagesRequest(chatID: "", messages: [])
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            selectUserFromFriendList(in: controller) { result in
                switch result {
                case .success(let chatID):
                    let message = TextMessage(text: "Hello")
                    let sendMessage = PostSendMessagesRequest(chatID: chatID, messages: [message])
                    Session.shared.send(sendMessage) { messageResult in handler(messageResult.map { $0 as Any }) }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
        
        return APIItem(title: "Send text message to a friend", path: mock.path, avaliable: true, block: block)
    }
    
    static var multiSendTextMessage: APIItem {
        let mock = PostMultisendMessagesRequest(userIDs: [], messages: [])
        let block: AnyResultBlock = { arg in
            let (_, handler) = arg
            let getFriends = GetFriendsRequest()
            Session.shared.send(getFriends) { res in
                switch res {
                case .success(let value):
                    guard !value.friends.isEmpty else {
                        let error = LineSDKError.generalError(
                            reason: .parameterError(
                                parameterName: "friends",
                                description: "You need at least one friend to use this API."))
                        handler(.failure(error))
                        return
                    }
                    let userIDs = value.friends.prefix(5).map { $0.userId }
                    let message = TextMessage(text: "Hello")
                    let sendMessage = PostMultisendMessagesRequest(userIDs: userIDs, messages: [message])
                    Session.shared.send(sendMessage) { messageResult in handler(messageResult.map { $0 as Any }) }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
        
        return APIItem(title: "Multisend text message to first five friends", path: mock.path, avaliable: true, block: block)
    }
    
    static var sendFlexMessage: APIItem {
        let mock = PostSendMessagesRequest(chatID: "", messages: [])
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            selectUserFromFriendList(in: controller) { result in
                switch result {
                case .success(let chatID):
                    selectFlexMessage(in: controller) { message in
                        let sendMessage = PostSendMessagesRequest(chatID: chatID, messages: [message])
                        Session.shared.send(sendMessage) { messageResult in handler(messageResult.map { $0 as Any }) }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
        return APIItem(title: "Send flex message to a friend", path: mock.path, avaliable: true, block: block)
    }

    static var getApproversInGroup: APIItem {
        let path = GetApproversInGroupRequest(groupID: "[groupID]").path
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            selectGroupFromGroupList(in: controller, handler: { result in
                switch result {
                case .success(let groupID):
                    let request = GetApproversInGroupRequest(groupID: groupID)
                    Session.shared.send(request) { response in
                        handler(response.map { $0 as Any })
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            })
        }
        return APIItem(title: "Get Approvers in given Group", path: path, avaliable: true, block: block)
    }
}

func selectUserFromFriendList(in viewController: UIViewController, handler: @escaping (Result<String>) -> Void) {
    let getFriends = GetFriendsRequest()
    Session.shared.send(getFriends) { res in
        
        switch res {
        case .success(let value):
            guard !value.friends.isEmpty else {
                let error = LineSDKError.generalError(
                    reason: .parameterError(
                        parameterName: "friends",
                        description: "You need at least one friend to use this API."))
                handler(.failure(error))
                return
            }
            
            let alert = UIAlertController(title: "Friends", message: nil, preferredStyle: .actionSheet)
            value.friends.prefix(5).forEach { friend in
                alert.addAction(.init(title: friend.displayName, style: .default) { _ in
                    handler(.success(friend.userId))
                    })
            }
            viewController.present(alert, animated: true)
        case .failure(let error):
            handler(.failure(error))
        }
    }
}

func selectGroupFromGroupList(in viewController: UIViewController, handler: @escaping (Result<String>) -> Void) {
    let request = GetGroupsRequest()
    Session.shared.send(request) { res in

        switch res {
        case .success(let value):
            guard !value.groups.isEmpty else {
                let error = LineSDKError.generalError(
                    reason: .parameterError(
                        parameterName: "groups",
                        description: "You need at least one group to use this API."))
                handler(.failure(error))
                return
            }

            let alert = UIAlertController(title: "Groups", message: nil, preferredStyle: .actionSheet)
            value.groups.prefix(5).forEach { group in
                alert.addAction(.init(title: group.groupName, style: .default) { _ in
                    handler(.success(group.groupID))
                    })
            }
            viewController.present(alert, animated: true)
        case .failure(let error):
            handler(.failure(error))
        }
    }
}

func selectFlexMessage(in viewController: UIViewController, handler: @escaping (Message) -> Void) {
    let alert = UIAlertController(title: "Message", message: nil, preferredStyle: .actionSheet)

    alert.addAction(.init(title: "Simple Bubble", style: .default) { _ in
        let simpleBubble: Message = {
            var box = FlexBoxComponent(layout: .vertical)
            box.addComponent(FlexTextComponent(text: "Hello"))
            box.addComponent(FlexTextComponent(text: "World"))
            return FlexBubbleContainer(body: box).messageWithAltText("this is a flex message")
        }()
        handler(simpleBubble)
    })
    
    viewController.present(alert, animated: true)

}


