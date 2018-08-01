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

/// Utility class for calling the API.
public struct LineSDKAPI {
    /// Refreshes the access token that the SDK is using for the user.
    ///
    /// - Parameters:
    ///   - refreshToken: Refresh token. Optional. The SDK will use the current refresh token if not provided.
    ///   - completion: Completion block called when the user's access token is refreshed.
    public static func refreshAccessToken(
        with refreshToken: String? = nil,
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
    
    static func revokeAccessToken(
        _ token: String? = nil,
        callbackQueue queue: CallbackQueue = .currentMainOrAsync,
        completionHandler completion: @escaping (Result<()>) -> Void)
    {
        guard let token = token ?? AccessTokenStore.shared.current?.value else {
            // No token input or found in store, just recognize it as success.
            queue.execute { completion(.success(())) }
            return
        }
        let request = PostRevokeTokenRequest(channelID: LoginConfiguration.shared.channelID, accessToken: token)
        Session.shared.send(request) { result in
            switch result {
            case .success(_):
                do {
                    try AccessTokenStore.shared.removeCurrentAccessToken()
                    completion(.success(()))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
