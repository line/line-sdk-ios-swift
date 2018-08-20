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
            )
        ]
        
        messagingAPIs = [
            .sendTextMessage,
            .multiSendTextMessage
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
    
    typealias AnyResultBlock = (@escaping (Result<Any>) -> Void) -> Void
    
    let block: AnyResultBlock
    
    let path: String
    let title: String
    
    let avaliable: Bool
    
    init<T: Request>(title: String, request: T, avaliable: Bool = true) {
        self.init(title: title, path: request.path, avaliable: avaliable) { handler in
            Session.shared.send(request) { result in handler(result.map { $0 as Any }) }
        }
    }
    
    init(title: String, path: String, avaliable: Bool = true, block: @escaping AnyResultBlock) {
        self.title = title
        self.path = path
        
        self.block = block
        self.avaliable = avaliable
    }
    
    func execute(handler: @escaping (Result<Any>) -> Void) -> Void {
        block(handler)
    }
}

extension APIItem {
    static var sendTextMessage: APIItem {
        let mock = PostSendMessagesRequest(chatID: "", messages: [])
        let block: AnyResultBlock = { handler in
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
                    let chatID = value.friends[0].userId
                    let message = Message.textMessage(text: "Hello")
                    let sendMessage = PostSendMessagesRequest(chatID: chatID, messages: [message])
                    Session.shared.send(sendMessage) { messageResult in handler(messageResult.map { $0 as Any }) }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
        
        return APIItem(title: "Send text message to first friend", path: mock.path, avaliable: true, block: block)
    }
    
    static var multiSendTextMessage: APIItem {
        let mock = PostMultisendMessagesRequest(userIDs: [], messages: [])
        let block: AnyResultBlock = { handler in
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
                    let message = Message.textMessage(text: "Hello")
                    let sendMessage = PostMultisendMessagesRequest(userIDs: userIDs, messages: [message])
                    Session.shared.send(sendMessage) { messageResult in handler(messageResult.map { $0 as Any }) }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
        
        return APIItem(title: "Multisend text message to first five friends", path: mock.path, avaliable: true, block: block)
    }
}
