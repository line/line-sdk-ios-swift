//
//  API+Deprecated.swift
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

extension API {
    
    /// - Warning: Deprecated. Use `API.Auth.refreshAccessToken(callbackQueue:completionHandler:)`.
    ///
    /// Refreshes the access token with `refreshToken`.
    ///
    /// - Parameters:
    ///   - queue: The callback queue that is used for `completion`. The default value is
    ///            `.currentMainOrAsync`. For more information, see `CallbackQueue`.
    ///   - completion: The completion closure to be invoked when the access token is refreshed.
    /// - Note:
    ///   If the token refresh process finishes successfully, the refreshed access token will be
    ///   automatically stored in the keychain for later use and you will get a
    ///   `.LineSDKAccessTokenDidUpdate` notification. Normally, you do not need to refresh the access token
    ///   manually because any API call will attempt to refresh the access token if necessary.
    ///
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access token automatically.
        Make sure you don't need token refreshing as a side effect, then use methods from `API.Auth` instead.
        """,
    renamed: "Auth.refreshAccessToken"
    )
    public static func refreshAccessToken(
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<AccessToken, LineSDKError>) -> Void)
    {
        Auth.refreshAccessToken(callbackQueue: queue, completionHandler: completion)
    }
    
    /// - Warning: Deprecated. Use `API.Auth.revokeAccessToken(_:callbackQueue:completionHandler:)`.
    ///
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
    ///  The `LineSDKAccessTokenDidRemove` notification is sent when the access token is removed from the device.
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods from `API.Auth` instead.
        """,
    renamed: "Auth.revokeAccessToken"
    )
    public static func revokeAccessToken(
        _ token: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<(), LineSDKError>) -> Void)
    {
        Auth.revokeAccessToken(token, callbackQueue: queue, completionHandler: completion)
    }

    /// - Warning: Deprecated. Use `API.Auth.revokeRefreshToken(_:callbackQueue:completionHandler:)`.
    ///
    /// Revokes the refresh token and all its corresponding access tokens.
    ///
    /// - Parameters:
    ///   - refreshToken: The refresh token to be revoked. Optional. If not specified, the current refresh token will
    ///            be revoked.
    ///   - queue: The callback queue that is used for `completion`. The default value is
    ///            `.currentMainOrAsync`. For more information, see `CallbackQueue`.
    ///   - completion: The completion closure to be invoked when the access token is revoked.
    ///
    /// - Note:
    ///   Do not pass an access token to the `refreshToken` parameter. To revoke an access token, use
    ///   `revokeAccessToken(_:callbackQueue:completionHandler:)` instead.
    ///
    ///   The revoked token will be automatically removed from the keychain. If `refreshToken` has a `nil` value
    ///   and the current refresh token does not exist, `completion` will be called with `.success`. The
    ///   same applies when `refreshToken` has an invalid refresh token.
    ///
    ///   This API will revoke the given refresh token and all its corresponding access tokens. Once these tokens are
    ///   revoked, you can neither call an API protected by an access token or refresh the access token with the refresh
    ///   token. To access the resource owner's content, you need to ask your users to authorize your app again.
    ///
    ///  The `LineSDKAccessTokenDidRemove` notification will be sent when the access token is removed from the device.
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods from `API.Auth` instead.
        """,
    renamed: "Auth.revokeRefreshToken"
    )
    public static func revokeRefreshToken(
        _ refreshToken: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<(), LineSDKError>) -> Void)
    {
        Auth.revokeRefreshToken(refreshToken, callbackQueue: queue, completionHandler: completion)
    }
    
    /// - Warning: Deprecated. Use `API.Auth.verifyAccessToken(_:callbackQueue:completionHandler:)`.
    ///
    /// Verifies the access token.
    ///
    /// - Parameters:
    ///   - token: The access token to be verified. Optional. If not specified, the current access token
    ///            will be verified.
    ///   - queue: The callback queue that is used for `completion`. The default value is
    ///            `.currentMainOrAsync`. For more information, see `CallbackQueue`.
    ///   - completion: The completion closure to be invoked when the access token is verified.
    ///
    @available(*, deprecated,
    message: """
        Auth-related APIs don't refresh access tokens automatically.
        Make sure you don't need token refreshing as a side effect, then use methods from `API.Auth` instead.
        """,
    renamed: "Auth.verifyAccessToken"
    )
    public static func verifyAccessToken(
        _ token: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<AccessTokenVerifyResult, LineSDKError>) -> Void)
    {
        Auth.verifyAccessToken(token, callbackQueue: queue, completionHandler: completion)
    }
}
