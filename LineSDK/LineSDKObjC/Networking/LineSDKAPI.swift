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

#if !LineSDKCocoaPods && !LineSDKBinary
import LineSDK
#endif

@objcMembers
public class LineSDKAPI: NSObject {
    
    // MARK: - getProfile
    public static func getProfile(
        completionHandler completion: @escaping (LineSDKUserProfile?, Error?) -> Void)
    {
        getProfile(callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func getProfile(
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKUserProfile?, Error?) -> Void)
    {
        API.getProfile(callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKUserProfile.init).match(with: completion)
        }
    }
    
    // MARK: - getFriends
    public static func getFriends(
        pageToken: String?,
        completionHandler completion: @escaping (LineSDKGetFriendsResponse?, Error?) -> Void)
    {
        getFriends(sort: .none, pageToken: pageToken, completionHandler: completion)
    }
    
    public static func getFriends(
        sort: LineSDKGetFriendsRequestSort,
        pageToken: String?,
        completionHandler completion: @escaping (LineSDKGetFriendsResponse?, Error?) -> Void)
    {
        getFriends(sort: sort, pageToken: pageToken, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func getFriends(
        sort: LineSDKGetFriendsRequestSort,
        pageToken: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKGetFriendsResponse?, Error?) -> Void)
    {
        API.getFriends(sort: sort.unwrapped, pageToken: pageToken, callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKGetFriendsResponse.init).match(with: completion)
        }
    }
    
    // MARK: - getApproversInFriends
    public static func getApproversInFriends(
        pageToken: String?,
        completionHandler completion: @escaping (LineSDKGetApproversInFriendsResponse?, Error?) -> Void)
    {
        getApproversInFriends(pageToken: pageToken, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func getApproversInFriends(
        pageToken: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKGetApproversInFriendsResponse?, Error?) -> Void)
    {
        API.getApproversInFriends(pageToken: pageToken, callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKGetApproversInFriendsResponse.init).match(with: completion)
        }
    }
    
    // MARK: - getGroups
    public static func getGroups(
        pageToken: String?,
        completionHandler completion: @escaping (LineSDKGetGroupsResponse?, Error?) -> Void)
    {
        getGroups(pageToken: pageToken, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func getGroups(
        pageToken: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKGetGroupsResponse?, Error?) -> Void)
    {
        API.getGroups(pageToken: pageToken, callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKGetGroupsResponse.init).match(with: completion)
        }
    }
    
    // MARK: - getApproversInGroups
    public static func getApproversInGroup(
        groupID: String,
        pageToken: String?,
        completionHandler completion: @escaping (LineSDKGetApproversInGroupResponse?, Error?) -> Void)
    {
        getApproversInGroup(
            groupID: groupID, pageToken: pageToken, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func getApproversInGroup(
        groupID: String,
        pageToken: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKGetApproversInGroupResponse?, Error?) -> Void)
    {
        API.getApproversInGroup(groupID: groupID, pageToken: pageToken, callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKGetApproversInGroupResponse.init).match(with: completion)
        }
    }
    
    // MARK: - sendMessages
    public static func sendMessages(
        _ messages: [LineSDKMessage],
        to chatID: String,
        completionHandler completion: @escaping (LineSDKPostSendMessagesResponse?, Error?) -> Void)
    {
        sendMessages(messages, to: chatID, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func sendMessages(
        _ messages: [LineSDKMessage],
        to chatID: String,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKPostSendMessagesResponse?, Error?) -> Void)
    {
        API.sendMessages(messages.map { $0.unwrapped }, to: chatID, callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKPostSendMessagesResponse.init).match(with: completion)
        }
    }

    public static func multiSendMessages(
        _ messages: [LineSDKMessage],
        to userIDs: [String],
        completionHandler completion: @escaping (LineSDKPostMultisendMessagesResponse?, Error?) -> Void)
    {
        multiSendMessages(messages, to: userIDs, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }

    public static func multiSendMessages(
        _ messages: [LineSDKMessage],
        to userIDs: [String],
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKPostMultisendMessagesResponse?, Error?) -> Void)
    {
        API.multiSendMessages(messages.map { $0.unwrapped }, to: userIDs, callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKPostMultisendMessagesResponse.init).match(with: completion)
        }
    }
    
    // MARK: - Friendship
    public static func getBotFriendshipStatus(
        completionHandler completion: @escaping (LineSDKGetBotFriendshipStatusResponse?, Error?) -> Void)
    {
        getBotFriendshipStatus(callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func getBotFriendshipStatus(
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKGetBotFriendshipStatusResponse?, Error?) -> Void)
    {
        API.getBotFriendshipStatus(callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKGetBotFriendshipStatusResponse.init).match(with: completion)
        }
    }

    // MARK: - Sharing
    public static func getMessageSendingOneTimeToken(
        userIDs: [String],
        completionHander completion: @escaping (LineSDKMessageSendingToken?, Error?) -> Void)
    {
        getMessageSendingOneTimeToken(
            userIDs: userIDs, callbackQueue: .currentMainOrAsync, completionHander: completion)
    }

    public static func getMessageSendingOneTimeToken(
        userIDs: [String],
        callbackQueue queue: LineSDKCallbackQueue,
        completionHander completion: @escaping (LineSDKMessageSendingToken?, Error?) -> Void)
    {
        API.getMessageSendingOneTimeToken(userIDs: userIDs, callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKMessageSendingToken.init).match(with: completion)
        }
    }

    public static func multiSendMessages(
        _ messages: [LineSDKMessage],
        withMessageToken token: LineSDKMessageSendingToken,
        completionHandler completion: @escaping (Error?) -> Void)
    {
        multiSendMessages(
            messages, withMessageToken: token, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }

    public static func multiSendMessages(
        _ messages: [LineSDKMessage],
        withMessageToken token: LineSDKMessageSendingToken,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (Error?) -> Void)
    {
        API.multiSendMessages(
            messages.map { $0.unwrapped },
            withMessageToken: token._value,
            callbackQueue: queue.unwrapped) { result in result.matchFailure(with: completion) }
    }
}

// MARK: - getGroups
extension LineSDKAPI {
    // MARK: - refreshAccessToken
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods in `LineSDKAuthAPI` instead.
        """,
    renamed: "LineSDKAuthAPI.refreshAccessToken"
    )
    public static func refreshAccessToken(
        completionHandler completion: @escaping (LineSDKAccessToken?, Error?) -> Void)
    {
        refreshAccessToken(callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods in `LineSDKAuthAPI` instead.
        """,
    renamed: "LineSDKAuthAPI.refreshAccessToken"
    )
    public static func refreshAccessToken(
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKAccessToken?, Error?) -> Void)
    {
        LineSDKAuthAPI.refreshAccessToken(callbackQueue: queue, completionHandler: completion)
    }
    
    // MARK: - revokeAccessToken
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods in `LineSDKAuthAPI` instead.
        """,
    renamed: "LineSDKAuthAPI.revokeAccessToken"
    )
    public static func revokeAccessToken(
        completionHandler completion: @escaping (Error?) -> Void)
    {
        revokeAccessToken(nil, completionHandler: completion)
    }
    
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods in `LineSDKAuthAPI` instead.
        """,
    renamed: "LineSDKAuthAPI.revokeAccessToken"
    )
    public static func revokeAccessToken(
        _ token: String?,
        completionHandler completion: @escaping (Error?) -> Void)
    {
        revokeAccessToken(token, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods in `LineSDKAuthAPI` instead.
        """,
    renamed: "LineSDKAuthAPI.revokeAccessToken"
    )
    public static func revokeAccessToken(
        _ token: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (Error?) -> Void)
    {
        LineSDKAuthAPI.revokeAccessToken(token, callbackQueue: queue, completionHandler: completion)
    }
    
    // MARK: - verifyAccessToken
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods in `LineSDKAuthAPI` instead.
        """,
    renamed: "LineSDKAuthAPI.verifyAccessToken"
    )
    public static func verifyAccessToken(
        completionHandler completion: @escaping (LineSDKAccessTokenVerifyResult?, Error?) -> Void)
    {
        verifyAccessToken(nil, completionHandler: completion)
    }
    
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods in `LineSDKAuthAPI` instead.
        """,
    renamed: "LineSDKAuthAPI.verifyAccessToken"
    )
    public static func verifyAccessToken(
        _ token: String?,
        completionHandler completion: @escaping (LineSDKAccessTokenVerifyResult?, Error?) -> Void)
    {
        verifyAccessToken(token, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods in `LineSDKAuthAPI` instead.
        """,
    renamed: "LineSDKAuthAPI.verifyAccessToken"
    )
    public static func verifyAccessToken(
        _ token: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKAccessTokenVerifyResult?, Error?) -> Void)
    {
        LineSDKAuthAPI.verifyAccessToken(token, callbackQueue: queue, completionHandler: completion)
    }
}
