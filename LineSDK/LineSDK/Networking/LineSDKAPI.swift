//
//  LineSDKAPI.swift
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

/// Utility class for calling the LINE APIs.
///
/// - Note:
/// For most of APIs, using interfaces in `LineSDKAPI` is equivalent with
/// using underlying `Request` and sending it by a `Session`. However, some methods in `LineSDKAPI` provide useful
/// side effects like operating on keychain or redirecting final result in a more reasonable way.
///
/// Unless you know the detail or want to extend LineSDK to send arbitrary unimplemented LINE API,
/// using `LineSDKAPI` to interact with LINE's APIs are highly recommended.
///
public struct LineSDKAPI {
    /// Refreshes the access token with a provided `refreshToken`.
    ///
    /// - Parameters:
    ///   - refreshToken: Refresh token. Optional. The SDK will use the current refresh token if not provided.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The completion closure to be executed when the API finishes.
    /// - Note:
    ///   If the token refresh process finishes without an issue, the received new token will be stored in keychain
    ///   automatically for later use. And you will get a `.LineSDKAccessTokenDidUpdate` notification. Normally,
    ///   there is no need for you to invoke this method manually, since all APIs will try refresh expired token
    ///   if needed.
    ///
    public static func refreshAccessToken(
        _ refreshToken: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<AccessToken>) -> Void)
    {
        guard let token = refreshToken ?? AccessTokenStore.shared.current?.refreshToken else {
            queue.execute { completion(.failure(LineSDKError.requestFailed(reason: .lackOfAccessToken))) }
            return
        }
        let request = PostRefreshTokenRequest(channelID: LoginConfiguration.shared.channelID, refreshToken: token)
        Session.shared.send(request, callbackQueue: queue) { result in
            switch result {
            case .success(let token):
                do {
                    try AccessTokenStore.shared.setCurrentToken(token)
                    completion(.success(token))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Revokes the access token.
    ///
    /// - Parameters:
    ///   - token: The access token which needs to be revoked. The SDK will use current access token if not provided.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The completion closure to be executed when the API finishes.
    /// - Note:
    ///   The revoked token will be removed from keychain for you. The `completion` closure will be called
    ///   with a `.success` if you pass a `nil` for `token`, and at the same time, the current access token does
    ///   not exist. The same thing will also happen when you provide an invalid token to revoke.
    ///
    ///   After a token revoked successfully, it will not be able to use again for LINE APIs. Your user need to
    ///   authorize your app again to issue a new token before using any other APIs.
    ///
    public static func revokeAccessToken(
        _ token: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<()>) -> Void)
    {
        func handleSuccessResult() {
            do {
                try AccessTokenStore.shared.removeCurrentAccessToken()
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
        
        guard let token = token ?? AccessTokenStore.shared.current?.value else {
            // No token input or found in store, just recognize it as success.
            queue.execute { completion(.success(())) }
            return
        }
        let request = PostRevokeTokenRequest(channelID: LoginConfiguration.shared.channelID, accessToken: token)
        Session.shared.send(request, callbackQueue: queue) { result in
            switch result {
            case .success(_):
                handleSuccessResult()
            case .failure(let error):
                guard let sdkError = error as? LineSDKError,
                      case .responseFailed(reason: .invalidHTTPStatusAPIError(let code, _, _)) = sdkError else
                {
                    completion(.failure(error))
                    return
                }
                // We recognize response 400 as a success for revoking (since the token itself is invalid).
                if code == 400 {
                    Log.print(sdkError.localizedDescription)
                    handleSuccessResult()
                }
            }
        }
    }
    
    /// Verifies a token.
    ///
    /// - Parameters:
    ///   - token: The access token which needs to be verified. The SDK will use current access token if not provided.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The completion closure to be executed when the API finishes.
    ///
    public static func verifyAccessToken(
        _ token: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<AccessTokenVerifyResult>) -> Void)
    {
        guard let token = token ?? AccessTokenStore.shared.current?.value else {
            queue.execute { completion(.failure(LineSDKError.requestFailed(reason: .lackOfAccessToken))) }
            return
        }
        let request = GetVerifyTokenRequest(accessToken: token)
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }
    
    /// Gets user's basic profile.
    ///
    /// - Parameters:
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The completion closure to be executed when the API finishes.
    /// - Note: `.profile` permission is required.
    ///
    public static func getProfile(
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<UserProfile>) -> Void)
    {
        let request = GetUserProfileRequest()
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }
}

// MARK: - Social API

extension LineSDKAPI {

    /// Returns a friend list of the user. Unless already having granted the channel,
    /// users who've configured the privacy filter are excluded from the list.
    ///
    /// - Parameters:
    ///   - sort: Sorting method for the returned freind list.
    ///           Only a value of `mid` and `name` is supported with `mid` being set by default.
    ///   - pageToken: If a `pageToken` value is included in the previous API call's completion closure,
    ///                pass it here to get the following page of the user's friend list.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The completion closure to be executed when the API finishes.
    public static func getFriends(
        sort: GetFriendsRequest.Sort? = nil,
        pageToken: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<GetFriendsRequest.Response>) -> Void)
    {
        let request = GetFriendsRequest(sort: sort, pageToken: pageToken)
        Session.shared.send(request, callbackQueue: queue, completionHandler:completion)
    }

    /// Returns a list of the user's friends who have already approved the channel,
    /// regardless each user's privacy filter setting. This API returns a maximum of 200 users per request.
    ///
    /// - Parameters:
    ///   - pageToken: If a `pageToken` value is included in the previous API call's completion block,
    ///                pass it here to get the following page of the list.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The closure to be executed when the approver list is returned.
    public static func getApproversInFriends(
        pageToken: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<GetApproversInFriendsRequest.Response>) -> Void)
    {
        let request = GetApproversInFriendsRequest(pageToken: pageToken)
        Session.shared.send(request, callbackQueue: queue, completionHandler:completion)
    }

    public static func getGroups(
        pageToken: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<GetGroupsRequest.Response>) -> Void)
    {
        let request = GetGroupsRequest(pageToken: pageToken)
        Session.shared.send(request, callbackQueue: queue, completionHandler:completion)
    }

    public static func getApproversInGroup(
        groupID: String,
        pageToken: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<GetApproversInGroupRequest.Response>) -> Void)
    {
        let request = GetApproversInGroupRequest(groupID: groupID, pageToken: pageToken)
        Session.shared.send(request, callbackQueue: queue, completionHandler:completion)
    }
}


// MARK: - Messaging API

extension LineSDKAPI {
    
    /// Sends messages to a certain chat destination on behalf of the current authorized user.
    ///
    /// - Parameters:
    ///   - messages: `Messages`s will be sent. Up to 5 elements.
    ///   - chatID: A chat ID to send messages to. It could be an ID of user, room, group or square chat ID.
    ///   - queue: The callback queue will be used for `completionHandler`.
    ///            By default, `.currentMainOrAsync` will be used. See `CallbackQueue` for more.
    ///   - completion: The completion closure to be executed when the API finishes.
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
        completionHandler completion: @escaping (Result<PostSendMessagesRequest.Response>) -> Void)
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
    ///   - completion: The completion closure to be executed when the API finishes.
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
        _ messages: [Message],
        to userIDs: [String],
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<PostMultisendMessagesRequest.Response>) -> Void)
    {
        let request = PostMultisendMessagesRequest(userIDs: userIDs, messages: messages)
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }
}
