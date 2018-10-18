//
//  LoginProcessURLResponse.swift
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

/// Result code from LINE web auth flow
enum LineWebURLResultError: String {
    case accessDenied = "access_denied"
    case serverError = "server_error"
}

/// Converts an input open app `URL` to a login process response if possible. Later we could use the `requestToken` in
/// this url to exchange real access token for the LINE Platform.
struct LoginProcessURLResponse {
    
    let requestToken: String
    let friendshipStatusChanged: Bool?

    init(from url: URL, validatingWith state: String) throws {
        guard let urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw LineSDKError.authorizeFailed(reason: .malformedRedirectURL(url: url, message: nil))
        }
        
        guard let items = urlComponent.queryItems else {
            throw LineSDKError.authorizeFailed(reason: .malformedRedirectURL(url: url, message: nil))
        }

        try self.init(webURL: url, queryItems: items, validatingState: state)
    }
    
    init(webURL url: URL, queryItems items: [URLQueryItem], validatingState: String) throws {
        var state: String?
        var token: String?
        var friendChanged: String?
        var error: String?
        var errorDescription: String?
        
        for item in items {
            switch item.name {
            case "code": token = item.value
            case "state": state = item.value
            case "friendship_status_changed": friendChanged = item.value
            case "error": error = item.value
            case "error_description": errorDescription = item.value
            default: break
            }
        }
        
        // Check whether we have correct state code, to ensure we are handling the corresponding response.
        guard validatingState == state else {
            throw LineSDKError.authorizeFailed(
                reason: .responseStateValueNotMatching(expected: validatingState, got: state)
            )
        }
        
        if let error = error {
            guard let typedError = LineWebURLResultError(rawValue: error) else {
                throw LineSDKError.authorizeFailed(
                    reason: .webLoginError(error: error, description: errorDescription)
                )
            }
            switch typedError {
            case .accessDenied:
                throw LineSDKError.authorizeFailed(reason: .userCancelled)
            case .serverError:
                throw LineSDKError.authorizeFailed(
                    reason: .webLoginError(error: error, description: errorDescription)
                )
            }
        } else {
            guard let token = token else {
                throw LineSDKError.authorizeFailed(reason: .malformedRedirectURL(url: url, message: nil))
            }
            requestToken = token
            if let friendChanged = friendChanged {
                friendshipStatusChanged = Bool(friendChanged.lowercased())
            } else {
                friendshipStatusChanged = nil
            }
        }
    }
}
