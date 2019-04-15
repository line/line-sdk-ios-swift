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

/// Represents a utility structure for calling the LINE Platform.
///
/// - Note:
/// For most API calls, using the interfaces in the `API` structure is equivalent to using and sending an
/// underlying `Request` object with a `Session` object. However, some methods in the `API` provides
/// additional useful features such as working with the keychain and redirecting the final result in a more
/// reasonable way.
///
/// Using the `API` structure to interact with the LINE Platform is highly recommended unless you are familiar
/// with and want to extend the LINE SDK to send unimplemented API requests to the LINE Platform.
///
public struct API {
    /// Refreshes the access token with `refreshToken`.
    ///
    /// - Parameters:
    ///   - refreshToken: A refresh token. Optional. If not specified, the current refresh token is used.
    ///   - queue: The callback queue that is used for `completion`. The default value is
    ///            `.currentMainOrAsync`. For more information, see `CallbackQueue`.
    ///   - completion: The completion closure to be invoked when the access token is refreshed.
    /// - Note:
    ///   If the token refresh process finishes successfully, the refreshed access token will be
    ///   automatically stored in the keychain for later use and you will get a
    ///   `.LineSDKAccessTokenDidUpdate` notification. Normally, you do not need to refresh the access token
    ///   manually because any API call will attempt to refresh the access token if necessary.
    ///
    public static func refreshAccessToken(
        _ refreshToken: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<AccessToken, LineSDKError>) -> Void)
    {
        guard let token = refreshToken ?? AccessTokenStore.shared.current?.refreshToken else {
            queue.execute { completion(.failure(LineSDKError.requestFailed(reason: .lackOfAccessToken))) }
            return
        }
        let request = PostRefreshTokenRequest(channelID: LoginConfiguration.shared.channelID, refreshToken: token)
        Session.shared.send(request, callbackQueue: queue) { result in
            switch result {
            case .success(let token):
                let reuslt = Result {
                    try AccessTokenStore.shared.setCurrentToken(token)
                }.map { token }
                completion(reuslt)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Revokes the access token.
    ///
    /// - Parameters:
    ///   - token: The access token to be revoked. Optional. If not specified, the current access token will
    ///            be revoked.
    ///   - queue: The callback queue that is used for `completion`. The default value is
    ///            `.currentMainOrAsync`. For more information, see `CallbackQueue`.
    ///   - completion: The completion closure to be invoked when the access token is revoked.
    /// - Note:
    ///
    ///   The revoked token will be automatically removed from the keychain. If `token` has a `nil` value
    ///   and the current access token does not exist, `completion` will be called with `.success`. The
    ///   same applies when `token` has an invalid access token.
    ///
    ///   After the access token is revoked, you cannot use it again to access the LINE Platform. You
    ///   need to have the user authorize your app again to issue a new access token before accessing the
    ///   LINE Platform.
    ///
    ///  The `LineSDKAccessTokenDidRemove` notification will be sent when the access token removed from the device.
    public static func revokeAccessToken(
        _ token: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<(), LineSDKError>) -> Void)
    {
        func handleSuccessResult() {
            let result = Result { try AccessTokenStore.shared.removeCurrentAccessToken() }
            completion(result)
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
                guard case .responseFailed(reason: .invalidHTTPStatusAPIError(let detail)) = error else {
                    completion(.failure(error))
                    return
                }
                // We recognize response 400 as a success for revoking (since the token itself is invalid).
                if detail.code == 400 {
                    Log.print(error.localizedDescription)
                    handleSuccessResult()
                }
            }
        }
    }

    /// Revokes the refresh token and all its corresponding access tokens.
    ///
    /// - Parameters:
    ///   - refreshToken: The refresh token to be revoked. Optional. If not specified, the current refresh token will
    ///            be revoked.
    ///   - queue: The callback queue that is used for `completion`. The default value is
    ///            `.currentMainOrAsync`. For more information, see `CallbackQueue`.
    ///   - completion: The completion closure to be invoked when the access token is revoked.
    /// - Note:
    ///
    ///   Do not pass an access token to the `refreshToken` parameter. To revoke an access token, use
    ///   `revokeAccessToken(_:callbackQueue:completionHandler:)` instead.
    ///
    ///   The revoked token will be automatically removed from the keychain. If `refreshToken` has a `nil` value
    ///   and the current refresh token does not exist, `completion` will be called with `.success`. The
    ///   same applies when `refreshToken` has an invalid refresh token.
    ///
    ///   This API will revoke the given refresh token and all its corresponding access token. Once these tokens are
    ///   revoked, you can neither call an API protected by an access token or refresh the access token with the refresh
    ///   token. To access the resource owner's content, you need to ask your users to authorize you app again.
    ///
    ///  The `LineSDKAccessTokenDidRemove` notification will be sent when the access token removed from the device.
    public static func revokeRefreshToken(
        _ refreshToken: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<(), LineSDKError>) -> Void)
    {
        func handleSuccessResult() {
            let result = Result { try AccessTokenStore.shared.removeCurrentAccessToken() }
            completion(result)
        }

        guard let refreshToken = refreshToken ?? AccessTokenStore.shared.current?.refreshToken else {
            // No token input or found in store, just recognize it as success.
            queue.execute { completion(.success(())) }
            return
        }
        let request = PostRevokeRefreshTokenRequest(
            channelID: LoginConfiguration.shared.channelID,
            refreshToken: refreshToken)
        Session.shared.send(request, callbackQueue: queue) { result in
            switch result {
            case .success(_):
                handleSuccessResult()
            case .failure(let error):
                guard case .responseFailed(reason: .invalidHTTPStatusAPIError(let detail)) = error else {
                    completion(.failure(error))
                    return
                }
                // We recognize response 400 as a success for revoking (since the token itself is invalid).
                if detail.code == 400 {
                    Log.print(error.localizedDescription)
                    handleSuccessResult()
                }
            }
        }
    }
    
    /// Verifies the access token.
    ///
    /// - Parameters:
    ///   - token: The access token to be verified. Optional. If not specified, the current access token
    ///            will be verified.
    ///   - queue: The callback queue that is used for `completion`. The default value is
    ///            `.currentMainOrAsync`. For more information, see `CallbackQueue`.
    ///   - completion: The completion closure to be invoked when the access token is verified.
    ///
    public static func verifyAccessToken(
        _ token: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<AccessTokenVerifyResult, LineSDKError>) -> Void)
    {
        guard let token = token ?? AccessTokenStore.shared.current?.value else {
            queue.execute { completion(.failure(LineSDKError.requestFailed(reason: .lackOfAccessToken))) }
            return
        }
        let request = GetVerifyTokenRequest(accessToken: token)
        Session.shared.send(request, callbackQueue: queue, completionHandler: completion)
    }
    
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
