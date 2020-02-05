//
//  API.swift
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

/// A utility type for calling APIs on the LINE Platform.
///
/// - Note:
/// For most API calls, using the methods in the `API` is equivalent to using and sending an
/// underlying `Request` object with a `Session` object. However, some methods in `API` provide
/// additional useful features such as working with the keychain and redirecting the final result 
/// in a more reasonable way.
///
/// Using methods in `API` to interact with the LINE Platform is highly recommended unless you are familiar
/// with and want to extend the LINE SDK to send unimplemented API requests to the LINE Platform.
///
public enum API {
    /// Gets the user's profile.
    ///
    /// - Parameters:
    ///   - queue: The callback queue that is used for `completion`. The default value is
    ///            `.currentMainOrAsync`. For more information, see `CallbackQueue`.
    ///   - completion: The completion closure to be invoked when the user's profile is returned.
    /// - Note: The `.profile` permission is required.
    ///
    public static func getProfile(
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<UserProfile, LineSDKError>) -> Void)
    {
        let request = GetUserProfileRequest()
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }
    
    /// Gets the friendship status of the user and the bot linked to your LINE Login channel.
    ///
    /// - Parameters:
    ///   - queue: The callback queue that is used for `completion`. The default value is
    ///            `.currentMainOrAsync`. For more information, see `CallbackQueue`.
    ///   - completion: The completion closure to be invoked when the friendship status is returned.
    /// - Note: The `.profile` permission is required.
    ///
    public static func getBotFriendshipStatus(
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<GetBotFriendshipStatusRequest.Response, LineSDKError>) -> Void)
    {
        let request = GetBotFriendshipStatusRequest()
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }
}
