//
//  API+Internal.swift
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


// MARK: - Graph API
extension API {
    /// Gets a friend list of the user. Unless already having granted the channel,
    /// users who've configured the privacy filter are excluded from the list.
    /// This API returns a maximum of 200 users per request.
    ///
    /// - Parameters:
    ///   - sort: Sorting method for the returned friend list.
    ///           Only a value of `name` is supported. If not specified, the sort will be determined by server.
    ///   - pageToken: If a `pageToken` value is included in the previous API call's completion closure,
    ///                pass it here to get the following page of the user's friend list. Otherwise, pass `nil` to get
    ///                the first page.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The completion closure to be invoked when the API finishes.
    ///
    /// - Note: `.friends` permission is required.
    ///
    public static func getFriends(
        sort: GetFriendsRequest.Sort? = nil,
        pageToken: String?,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<GetFriendsRequest.Response, LineSDKError>) -> Void)
    {
        let request = GetFriendsRequest(sort: sort, pageToken: pageToken)
        Session.shared.send(request, callbackQueue: queue, completionHandler:completion)
    }
    
    /// Gets a list of the user's friends who have already approved the channel,
    /// regardless each user's privacy filter setting.
    /// This API returns a maximum of 200 users per request.
    ///
    /// - Parameters:
    ///   - pageToken: If a `pageToken` value is included in the previous API call's completion closure,
    ///                pass it here to get the following page of the user's friend list. Otherwise, pass `nil` to get
    ///                the first page.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The closure to be invoked when the approver list is returned.
    ///
    /// - Note: `.friends` permission is required.
    ///
    public static func getApproversInFriends(
        pageToken: String?,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<GetApproversInFriendsRequest.Response, LineSDKError>) -> Void)
    {
        let request = GetApproversInFriendsRequest(pageToken: pageToken)
        Session.shared.send(request, callbackQueue: queue, completionHandler:completion)
    }
    
    /// Gets a list of groups that the user belongs to.
    /// This API returns a maximum of 200 groups per request.
    ///
    /// - Parameters:
    ///   - pageToken: If a `pageToken` value is included in the previous API call's completion closure,
    ///                pass it here to get the following page of the user's friend list. Otherwise, pass `nil` to get
    ///                the first page.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The closure to be invoked when the list is returned.
    ///
    /// - Note: `.groups` permission is required.
    ///
    public static func getGroups(
        pageToken: String?,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<GetGroupsRequest.Response, LineSDKError>) -> Void)
    {
        let request = GetGroupsRequest(pageToken: pageToken)
        Session.shared.send(request, callbackQueue: queue, completionHandler:completion)
    }
    
    /// Gets a list of users in the specified group who've already approved the channel.
    /// Note that this API does not take friendship status into account.
    /// This API returns a maximum of 200 users per request.
    ///
    /// - Parameters:
    ///   - groupID: The specified group identifier
    ///   - pageToken: If a `pageToken` value is included in the previous API call's completion closure,
    ///                pass it here to get the following page of the user's friend list. Otherwise, pass `nil` to get
    ///                the first page.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The closure to be invoked when the list is returned.
    ///
    /// - Note: `.friends` and `.groups` permission is required.
    ///
    public static func getApproversInGroup(
        groupID: String,
        pageToken: String?,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<GetApproversInGroupRequest.Response, LineSDKError>) -> Void)
    {
        let request = GetApproversInGroupRequest(groupID: groupID, pageToken: pageToken)
        Session.shared.send(request, callbackQueue: queue, completionHandler:completion)
    }
}


// MARK: - Messaging API
extension API {
    
    /// Sends messages to a certain chat destination on behalf of the current authorized user.
    ///
    /// - Parameters:
    ///   - messages: `Messages`s will be sent. Up to 5 elements.
    ///   - chatID: A chat ID to send messages to. It could be an ID of user, room, group or square chat ID.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The completion closure to be invoked when the API finishes.
    ///
    /// - Note:
    ///   `.messageWrite` permission is required to use this API. If your token does not contain enough permission,
    ///   a `LineSDKError.responseFailed` with `.invalidHTTPStatusAPIError` reason will occur, and with 403 as its
    ///   HTTP status code. You could use `LineSDKError.isPermissionError` to check for this eroor.
    ///   Please confirm your channel permissions before you use this API.
    ///
    ///   You could send at most 5 messages to a user in a single call. Line SDK does not check the elements count in
    ///   `messages` when sending. However, you could expect a 400 error if you contain more that 5 messages in the
    ///   request.
    ///
    ///   There would be a few cases that API call is successful but message is not delivered. In these cases,
    ///   the `status` in response would be `.discarded` instead of `.ok`. See `MessageSendingStatus` for more.
    ///
    public static func sendMessages(
        _ messages: [MessageConvertible],
        to chatID: String,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<PostSendMessagesRequest.Response, LineSDKError>) -> Void)
    {
        let request = PostSendMessagesRequest(chatID: chatID, messages: messages)
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }
    
    /// Sends messages to multiple users on behalf of the current authorized user.
    ///
    /// - Parameters:
    ///   - messages: `Messages`s will be sent. Up to 5 elements.
    ///   - userIDs: An array of users' ID to where messages will be sent. Up to 10 elements.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The completion closure to be invoked when the API finishes.
    ///
    /// - Note:
    ///   `.messageWrite` permission is required to use this API. If your token does not contain enough permission,
    ///   a `LineSDKError.responseFailed` with `.invalidHTTPStatusAPIError` reason will occur, and with 403 as its
    ///   HTTP status code. You could use `LineSDKError.isPermissionError` to check for this eroor.
    ///   Please confirm your channel permissions before you use this API.
    ///
    ///   You could send at most 5 messages, and to at most 10 users in a single call. Line SDK does not check the
    ///   elements count in `messages` or `userIDs` when sending. However, you could expect a 400 error if you contain
    ///   more elements than allowed.
    ///
    ///   There would be a few cases that API call is successful but message is not delivered. In these cases,
    ///   the `status` in response would be `.discarded` instead of `.ok`. See `MessageSendingStatus` for more.
    ///   To know the message delivery result for each receiver, please check the response `results`, which is an array
    ///   of [SendingResult]`. See `SendingResult` for more.
    ///
    public static func multiSendMessages(
        _ messages: [MessageConvertible],
        to userIDs: [String],
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<PostMultisendMessagesRequest.Response, LineSDKError>) -> Void)
    {
        let request = PostMultisendMessagesRequest(userIDs: userIDs, messages: messages)
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }
}

// MARK: - Sharing Related API
extension API {
    public static func getMessageSendingOneTimeToken(
        userIDs: [String],
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHander completion: @escaping (Result<MessageSendingToken, LineSDKError>) -> Void)
    {
        let request = PostMessageSendingTokenIssueRequest(userIDs: userIDs)
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }

    public static func multiSendMessages(
        _ messages: [MessageConvertible],
        withMessageToken token: MessageSendingToken,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<Unit, LineSDKError>) -> Void)
    {
        let request = PostMultisendMessagesWithTokenRequest(token: token, messages: messages)
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }
}
