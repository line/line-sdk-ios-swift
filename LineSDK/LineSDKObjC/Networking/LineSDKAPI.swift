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

import LineSDK

@objcMembers
public class LineSDKAPI: NSObject {
    
    // - MARK: refreshAccessToken
    public static func refreshAccessToken(
        completionHandler completion: @escaping (LineSDKAccessToken?, Error?) -> Void)
    {
        refreshAccessToken(nil, completionHandler: completion)
    }
    
    public static func refreshAccessToken(
        _ refreshToken: String?,
        completionHandler completion: @escaping (LineSDKAccessToken?, Error?) -> Void)
    {
        refreshAccessToken(refreshToken, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func refreshAccessToken(
        _ refreshToken: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKAccessToken?, Error?) -> Void)
    {
        API.refreshAccessToken(refreshToken, callbackQueue: queue._value) { result in
            completion(result.value.map { .init($0) }, result.error)
        }
    }
    
    // - MARK: revokeAccessToken
    public static func revokeAccessToken(
        completionHandler completion: @escaping (Error?) -> Void)
    {
        revokeAccessToken(nil, completionHandler: completion)
    }
    
    public static func revokeAccessToken(
        _ token: String?,
        completionHandler completion: @escaping (Error?) -> Void)
    {
        revokeAccessToken(token, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func revokeAccessToken(
        _ token: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (Error?) -> Void)
    {
        API.revokeAccessToken(token, callbackQueue: queue._value) { result in
            completion(result.error)
        }
    }
    
    // - MARK: verifyAccessToken
    public static func verifyAccessToken(
        completionHandler completion: @escaping (LineSDKAccessTokenVerifyResult?, Error?) -> Void)
    {
        verifyAccessToken(nil, completionHandler: completion)
    }
    
    public static func verifyAccessToken(
        _ token: String?,
        completionHandler completion: @escaping (LineSDKAccessTokenVerifyResult?, Error?) -> Void)
    {
        verifyAccessToken(token, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func verifyAccessToken(
        _ token: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKAccessTokenVerifyResult?, Error?) -> Void)
    {
        API.verifyAccessToken(token, callbackQueue: queue._value) { result in
            completion(result.value.map { .init($0) }, result.error)
        }
    }
    
    // - MARK: getProfile
    public static func getProfile(
        completionHandler completion: @escaping (LineSDKUserProfile?, Error?) -> Void)
    {
        getProfile(callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func getProfile(
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping (LineSDKUserProfile?, Error?) -> Void)
    {
        API.getProfile(callbackQueue: queue._value) { result in
            completion(result.value.map { .init($0) }, result.error)
        }
    }
    
    // - MARK: getFriends
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
        API.getFriends(sort: sort._value, pageToken: pageToken, callbackQueue: queue._value) { result in
            completion(result.value.map { .init($0) }, result.error)
        }
    }
    
    // - MARK: getApproversInFriends
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
        API.getApproversInFriends(pageToken: pageToken, callbackQueue: queue._value) { result in
            completion(result.value.map { .init($0) }, result.error)
        }
    }
    
    // - MARK: getGroups
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
        API.getGroups(pageToken: pageToken, callbackQueue: queue._value) { result in
            completion(result.value.map { .init($0) }, result.error)
        }
    }
    
    // - MARK: getApproversInGroups
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
        API.getApproversInGroup(groupID: groupID, pageToken: pageToken, callbackQueue: queue._value) { result in
            completion(result.value.map { .init($0) }, result.error)
        }
    }
    

}

