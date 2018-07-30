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

enum LineAppURLResultCode: String {
    case success = "SUCCESS"
    case disallowed = "DISALLOWED"
    case cancelled = "CANCELLED"
    case invalidParameter = "INVALIDPARAM"
    case networkError = "NETWORKERROR"
    case generalError = "GENERALERROR"
    case loginFailure = "LOGINFAIL"
}

enum LineWebURLResultError: String {
    case accessDenied = "access_denied"
    case serverError = "server_error"
}

struct LoginProcessURLResponse {
    
    let requestToken: String

    init(from url: URL, validatingWith state: String) throws {
        guard let urlComponent = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw LineSDKError.authorizeFailed(reason: .malformedRedirectURL(url: url, message: nil))
        }
        
        guard let items = urlComponent.queryItems else {
            throw LineSDKError.authorizeFailed(reason: .malformedRedirectURL(url: url, message: nil))
        }
        
        // If the items contains a "resultCode" key, we recognize it as response from LINE url scheme auth
        // Maybe we could remove this, if server/LINE app side could unify the callback flow.
        let isClientURLResponse = items.contains { $0.name == "resultCode" }

        if isClientURLResponse {
            try self.init(clientURL:url, queryItems: items)
        } else {
            try self.init(webURL: url, queryItems: items, validatingState: state)
        }
    }
    
    init(clientURL url: URL, queryItems items: [URLQueryItem]) throws {
        var codeString = ""
        var messgae: String?
        var token: String?
        for item in items {
            switch item.name {
            case "resultCode": codeString = item.value ?? ""
            case "resultMessage": messgae = item.value
            case "requestToken": token = item.value
            default: break
            }
        }
        
        guard let code = LineAppURLResultCode(rawValue: codeString) else {
            throw LineSDKError.authorizeFailed(reason: .invalidLineURLResultCode(codeString))
        }
        
        switch code {
        case .success:
            guard let token = token else {
                throw LineSDKError.authorizeFailed(reason: .malformedRedirectURL(url: url, message: messgae))
            }
            requestToken = token
        case .cancelled: throw LineSDKError.authorizeFailed(reason: .userCancelled)
        case .disallowed: throw LineSDKError.authorizeFailed(reason: .userCancelled)
        default: throw LineSDKError.authorizeFailed(reason: .lineClientError(code: code.rawValue, message: messgae))
        }
    }
    
    init(webURL url: URL, queryItems items: [URLQueryItem], validatingState: String) throws {
        var state: String?
        var token: String?
        var error: String?
        var errorDescription: String?
        
        for item in items {
            switch item.name {
            case "code": token = item.value
            case "state": state = item.value
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
        }
    }
}
