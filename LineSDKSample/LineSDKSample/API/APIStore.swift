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
import UIKit
import LineSDK

enum ApplicationError: Error, LocalizedError {
    case sdkError(LineSDKError)
    case sampleError(LineSDKSampleError)

    var errorDescription: String? {
        switch self {
        case .sdkError(let error): return error.errorDescription
        case .sampleError(let error): return error.errorDescription
        }
    }
}

enum APICategory: Int, CaseIterable {
    case auth
    case friendship
    case graph
    case messaging
    case openChat
}

class APIStore {
    static let shared = APIStore()
    
    private(set) var authAPIs: [APIItem] = []
    private(set) var friendshipAPIs: [APIItem] = []
    private(set) var graphAPIs: [APIItem] = []
    private(set) var messagingAPIs: [APIItem] = []
    private(set) var openChatAPIs: [APIItem] = []

    private var tokenDidUpdateObserver: NotificationToken?
    private var tokenDidRemoveObserver: NotificationToken?
    
    private init() {
        refresh()
        let center = NotificationCenter.default
        tokenDidUpdateObserver = center.addObserver(forName: .LineSDKAccessTokenDidUpdate , object: nil, queue: nil) {
            _ in
            self.refresh()
        }
        tokenDidRemoveObserver = center.addObserver(forName: .LineSDKAccessTokenDidRemove , object: nil, queue: nil) {
            _ in
            self.refresh()
        }
    }
    
    func numberOfAPIs(in category: APICategory) -> Int {
        switch category {
        case .auth: return authAPIs.count
        case .friendship: return friendshipAPIs.count
        case .graph: return graphAPIs.count
        case .messaging: return messagingAPIs.count
        case .openChat: return openChatAPIs.count
        }
    }
    
    func api(in category: APICategory, at index: Int) -> APIItem {
        switch category {
        case .auth: return authAPIs[index]
        case .friendship: return friendshipAPIs[index]
        case .graph: return graphAPIs[index]
        case .messaging: return messagingAPIs[index]
        case .openChat: return openChatAPIs[index]
        }
    }
}

extension APIStore {
    private func refresh() {
        authAPIs = [
            .init(
                title: "Get User Profile",
                request: GetUserProfileRequest()
            ),
            .init(
                title: "Verify Token",
                request: GetVerifyTokenRequest(accessToken: AccessTokenStore.shared.current?.value ?? ""),
                available: AccessTokenStore.shared.current != nil
            ),
            .refreshToken,
        ]
        
        friendshipAPIs = [
            .init(
                title: "Get Bot Friendship Status",
                request: GetBotFriendshipStatusRequest()
            )
        ]
        
        graphAPIs = [
            .init(
                title: "Get Friends" ,
                request: GetFriendsRequest()
            ),
            .init(
                title: "Get Approvers in Friends",
                request: GetApproversInFriendsRequest()
            ),
            .init(
                title: "Get Groups",
                request: GetGroupsRequest()
            ),
            .getApproversInGroup
        ]
        
        messagingAPIs = [
            .sendTextMessage,
            .multiSendTextMessage,
            .sendFlexMessage
        ]
        
        openChatAPIs = [
            .init(
                title: "Agreement Status",
                request: GetOpenChatTermAgreementStatusRequest()
            ),
            .checkOpenChatRoomStatus,
            .checkOpenChatRoomMembershipState,
            .checkOpenChatRoomJoinType,
            .createOpenChatRoom,
            .joinOpenChatRoom
        ]
    }
}

struct APIItem {
    
    typealias AnyResultBlock = ((UIViewController, (Result<Any, ApplicationError>) -> Void)) -> Void
    
    let block: AnyResultBlock
    
    let path: String
    let method: HTTPMethod
    let title: String
    
    let available: Bool
    
    init<T: Request>(title: String, request: T, available: Bool = true) {
        self.init(title: title, path: request.path, method: request.method, available: available) {
            (controller, handler) in
            Session.shared.send(request) {
                result in
                switch result {
                case .success(let value):
                    handler(.success(value as Any))
                case .failure(let error):
                    handler(.failure(.sdkError(error)))
                }
            }
        }
    }
    
    init<T: Request>(title: String, mock: T, available: Bool = true, block: @escaping AnyResultBlock) {
        self.init(title: title, path: mock.path, method: mock.method, available: available, block: block)
    }
    
    init(title: String, path: String, method: HTTPMethod, available: Bool = true, block: @escaping AnyResultBlock) {
        self.title = title
        self.path = path
        self.method = method
        
        self.block = block
        self.available = available
    }
    
    func execute(with controller: UIViewController, handler: @escaping (Result<Any, ApplicationError>) -> Void) -> Void {
        block((controller, handler))
    }
}

extension APIItem {

    static var refreshToken: APIItem {
        return APIItem(
            title: "Refresh token",
            path: "/oauth2/v2.1/token",
            method: .post,
            available: LoginManager.shared.isAuthorized) { viewController, handler in
                API.Auth.refreshAccessToken { result in
                    switch result {
                    case .success(let token):
                        handler(.success(token))
                    case .failure(let error):
                        handler(.failure(.sdkError(error)))
                    }
                }
            }
    }

    static var sendTextMessage: APIItem {
        let mock = PostSendMessagesRequest(chatID: "", messages: [])
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            selectUserFromFriendList(in: controller) { result in
                switch result {
                case .success(let chatID):
                    let message = TextMessage(text: "Hello")
                    let sendMessage = PostSendMessagesRequest(chatID: chatID, messages: [message])
                    Session.shared.send(sendMessage) {
                        messageResult in
                        switch messageResult {
                        case .success(let value): handler(.success(value))
                        case .failure(let error): handler(.failure(.sdkError(error)))
                        }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
        
        return APIItem(
            title: "Send text message to a friend",
            path: mock.path,
            method: mock.method,
            available: true,
            block: block
        )
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
                        handler(.failure(.sdkError(error)))
                        return
                    }
                    let userIDs = value.friends.prefix(5).map { $0.userID }
                    let message = TextMessage(text: "Hello")
                    let sendMessage = PostMultisendMessagesRequest(userIDs: userIDs, messages: [message])
                    Session.shared.send(sendMessage) {
                        messageResult in
                        switch messageResult {
                        case .success(let value): handler(.success(value))
                        case .failure(let error): handler(.failure(.sdkError(error)))
                        }
                    }
                case .failure(let error):
                    handler(.failure(.sdkError(error)))
                }
            }
        }
        
        return APIItem(
            title: "Multisend text message to first five friends", mock: mock, available: true, block: block
        )
    }
    
    static var sendFlexMessage: APIItem {
        let mock = PostSendMessagesRequest(chatID: "", messages: [])
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            selectUserFromFriendList(in: controller) { result in
                switch result {
                case .success(let chatID):
                    selectFlexMessage(in: controller) { message in
                        switch message {
                        case .success(let m):
                            let sendMessage = PostSendMessagesRequest(chatID: chatID, messages: [m])
                            Session.shared.send(sendMessage) {
                                messageResult in
                                switch messageResult {
                                case .success(let value): handler(.success(value))
                                case .failure(let error): handler(.failure(.sdkError(error)))
                                }
                            }
                        case .failure(let error):
                            handler(.failure(error))
                        }

                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            }
        }
        return APIItem(title: "Send flex message to a friend", mock: mock, available: true, block: block)
    }

    static var getApproversInGroup: APIItem {
        let mock = try! GetApproversInGroupRequest(groupID: "groupID")
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            selectGroupFromGroupList(in: controller, handler: { result in
                switch result {
                case .success(let groupID):
                    API.getApproversInGroup(groupID: groupID, pageToken: nil) { result in
                        switch result {
                        case .success(let value): handler(.success(value))
                        case .failure(let error): handler(.failure(.sdkError(error)))
                        }
                    }
                case .failure(let error):
                    handler(.failure(error))
                }
            })
        }
        return APIItem(title: "Get Approvers in given Group", mock: mock, available: true, block: block)
    }
    
    static var checkOpenChatRoomStatus: APIItem {
        let mock = try! GetOpenChatRoomStatusRequest(openChatId: "openChatId")
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            collectOpenChatMid(in: controller) { result in
                let text = try! result.get()
                API.getOpenChatRoomStatus(openChatId: text) { result in
                    switch result {
                    case .success(let value): handler(.success(value))
                    case .failure(let error): handler(.failure(.sdkError(error)))
                    }
                }
            }
        }
        return APIItem(title: "Check Open Chat Room Status", mock: mock, block: block)
    }

    static var checkOpenChatRoomJoinType: APIItem {
        let mock = try! GetOpenChatRoomJoinTypeRequest(openChatId: "openChatId")
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            collectOpenChatMid(in: controller) { result in
                let text = try! result.get()
                API.getOpenChatRoomJoinType(openChatId: text) { result in
                    switch result {
                    case .success(let value): handler(.success(value))
                    case .failure(let error): handler(.failure(.sdkError(error)))
                    }
                }
            }
        }
        return APIItem(title: "Check Open Chat Room Join Type", mock: mock, block: block)
    }
    
    static var checkOpenChatRoomMembershipState: APIItem {
        let mock = try! GetOpenChatRoomMembershipStateRequest(openChatId: "openChatId")
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            collectOpenChatMid(in: controller) { result in
                let text = try! result.get()
                API.getOpenChatRoomMembershipState(openChatId: text) { result in
                    switch result {
                    case .success(let value): handler(.success(value))
                    case .failure(let error): handler(.failure(.sdkError(error)))
                    }
                }
            }
        }
        return APIItem(title: "Check Open Chat Room Membership State", mock: mock, block: block)
    }
    
    static var createOpenChatRoom: APIItem {
        let room = OpenChatRoomCreatingItem(
            name: "Sample Room",
            roomDescription: "This is just a sample open chat room",
            creatorDisplayName: "onevcat",
            category: OpenChatCategory.notSelected,
            allowSearch: true
        )
        return .init(title: "Create Open Chat Room", request: PostOpenChatCreateRequest(room: room))
    }

    static var joinOpenChatRoom: APIItem {
        let mock = try! PostOpenChatRoomJoinRequest(openChatId: "openChatId", displayName: "displayName")
        let block: AnyResultBlock = { arg in
            let (controller, handler) = arg
            collectionOpenChatIdAndUsername(in: controller) { result in
                let text = try! result.get()
                API.postOpenChatRoomJoin(openChatId: text.0, displayName: text.1) { result in
                    switch result {
                    case .success: handler(.success(APIStatus(code: 204)))
                    case .failure(let error): handler(.failure(.sdkError(error)))
                    }
                }
            }
        }
        return APIItem(title: "Join an Open Chat Room", mock: mock, block: block)
    }
}

struct APIStatus {
    let code: Int
}

func selectUserFromFriendList(
    in viewController: UIViewController,
    handler: @escaping (Result<String, ApplicationError>) -> Void
)
{
    let getFriends = GetFriendsRequest()
    Session.shared.send(getFriends) { res in
        
        switch res {
        case .success(let value):
            guard !value.friends.isEmpty else {
                let error = LineSDKError.generalError(
                    reason: .parameterError(
                        parameterName: "friends",
                        description: "You need at least one friend to use this API."))
                handler(.failure(.sdkError(error)))
                return
            }
            
            let alert = UIAlertController(title: "Friends", message: nil, preferredStyle: .actionSheet)
            value.friends.prefix(5).forEach { friend in
                alert.addAction(.init(title: friend.displayName, style: .default) { _ in
                    handler(.success(friend.userID))
                })
            }
            alert.addAction(.init(title: "Cancel", style: .cancel) { _ in
                handler(.failure(.sampleError(LineSDKSampleError.userCancelAction)))
            })
            alert.setupPopover(in: viewController.view)
            viewController.present(alert, animated: true)
        case .failure(let error):
            handler(.failure(.sdkError(error)))
        }
    }
}

func selectGroupFromGroupList(
    in viewController: UIViewController,
    handler: @escaping (Result<String, ApplicationError>) -> Void
)
{
    let request = GetGroupsRequest()
    Session.shared.send(request) { res in

        switch res {
        case .success(let value):
            guard !value.groups.isEmpty else {
                let error = LineSDKError.generalError(
                    reason: .parameterError(
                        parameterName: "groups",
                        description: "You need at least one group to use this API."))
                handler(.failure(.sdkError(error)))
                return
            }

            let alert = UIAlertController(title: "Groups", message: nil, preferredStyle: .actionSheet)
            value.groups.prefix(5).forEach { group in
                alert.addAction(.init(title: group.groupName, style: .default) { _ in
                    handler(.success(group.groupID))
                    })
            }
            alert.addAction(.init(title: "Cancel", style: .cancel) { _ in
                handler(.failure(.sampleError(LineSDKSampleError.userCancelAction)))
            })
            alert.setupPopover(in: viewController.view)
            viewController.present(alert, animated: true)
        case .failure(let error):
            handler(.failure(.sdkError(error)))
        }
    }
}

func selectFlexMessage(
    in viewController: UIViewController,
    handler: @escaping (Result<Message, ApplicationError>) -> Void
)
{
    let alert = UIAlertController(title: "Message", message: nil, preferredStyle: .actionSheet)

    alert.addAction(.init(title: "Simple Bubble", style: .default) { _ in
        let simpleBubble: Message = {
            var box = FlexBoxComponent(layout: .vertical)
            box.addComponent(FlexTextComponent(text: "Hello"))
            box.addComponent(FlexTextComponent(text: "World"))
            return FlexBubbleContainer(body: box).messageWithAltText("this is a flex message")
        }()
        handler(.success(simpleBubble))
    })

    alert.addAction(.init(title: "Simple Carousel", style: .default, handler: { _ in
        let flexCarousel: Message = {
            var firstBox = FlexBoxComponent(layout: .vertical)
            firstBox.addComponent(FlexTextComponent(text: "Hello"))
            firstBox.addComponent(FlexTextComponent(text: "World"))
            let firstBoxBubbleContainer = FlexBubbleContainer(body: firstBox)
            var secondBox = FlexBoxComponent(layout: .vertical)
            secondBox.addComponent(FlexTextComponent(text: "Hello"))
            secondBox.addComponent(FlexTextComponent(text: "World"))
            let secondBoxBubbleContainer = FlexBubbleContainer(body: secondBox)
            return FlexCarouselContainer(contents: [firstBoxBubbleContainer, secondBoxBubbleContainer]).messageWithAltText("This is a flex carousel message")
        }()
        handler(.success(flexCarousel))
    }))

    alert.addAction(.init(title: "Cancel", style: .cancel) { _ in
        handler(.failure(.sampleError(LineSDKSampleError.userCancelAction)))
    })
    alert.setupPopover(in: viewController.view)
    viewController.present(alert, animated: true)
}

func collectOpenChatMid(
    in viewController: UIViewController,
    handler: @escaping (Result<String, Never>) -> Void
)
{
    let alert = UIAlertController(title: "Open Chat Id", message: nil, preferredStyle: .alert)
    alert.addTextField { $0.placeholder = "Input openChatId..." }
    alert.addAction(
        .init(title: "OK", style: .default) {
            _ in
            guard let text = alert.textFields?.first?.text else { return }
            handler(.success(text))
        }
    )
    alert.addAction(.init(title: "Cancel", style: .cancel))
    viewController.present(alert, animated: true)
}

func collectionOpenChatIdAndUsername(
    in viewController: UIViewController,
    handler: @escaping (Result<(String,String), Never>) -> Void
)
{
    let alert = UIAlertController(title: "Open Chat Id", message: nil, preferredStyle: .alert)
    alert.addTextField { $0.placeholder = "Open Chat Id..." }
    alert.addTextField { $0.placeholder = "Display Name..." }
    alert.addAction(
        .init(title: "OK", style: .default) {
            _ in
            guard let openChatId = alert.textFields?[0].text else { return }
            guard let displayName = alert.textFields?[1].text else { return }
            handler(.success((openChatId, displayName)))
        }
    )
    alert.addAction(.init(title: "Cancel", style: .cancel))
    viewController.present(alert, animated: true)
}

extension UIAlertController {
    func setupPopover(in view: UIView) {
        guard let popoverController = popoverPresentationController else {
            return
        }

        popoverController.sourceView = view
        popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        popoverController.permittedArrowDirections = []
    }
}
