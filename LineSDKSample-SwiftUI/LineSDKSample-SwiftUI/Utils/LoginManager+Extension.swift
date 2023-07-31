//
//  LoginManager+Extension.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

extension LoginManager {
    /// Logs into the LINE platform.
    ///
    /// This is the async version of `LoginManager.login(permission:in:parameters:completionHandler:)`, for more
    /// detail please refer to it.
    ///
    /// - Parameters:
    ///   - permissions: The set of permissions requested by your app. The default value is
    ///                  `[.profile]`.
    ///   - parameters: The parameters used during the login process. For more information,
    ///                 see `LoginManager.Parameters`.
    /// - Returns: The login `Result`.
    func login(
        permissions: Set<LoginPermission> = [.profile],
        parameters: LoginManager.Parameters = .init()
    ) async -> Result<LoginResult, LineSDKError> {
        await withCheckedContinuation { continuation in
            login(permissions: permissions, parameters: parameters) { result in
                continuation.resume(returning: result)
            }
        }
    }

    /// Logs out the current user by revoking the refresh token and all its corresponding access tokens.
    ///
    /// This is the async version of `LoginManager.logout(completionHandler:)`, for more detail please refer to it.
    ///
    /// - Returns: The logout `Result`.
    func logout() async -> Result<Void, LineSDKError> {
        await withCheckedContinuation { continuation in
            logout { result in
                continuation.resume(returning: result)
            }
        }
    }
}
