//
//  PostRevokeTokenRequest.swift
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

protocol RevokeTokenRequest: Request {
    var channelID: String { get }
}

extension RevokeTokenRequest {
    var method: HTTPMethod { return .post }
    var path: String { return "/oauth2/v2.1/revoke" }
    var contentType: ContentType { return .formUrlEncoded }
    var authentication: AuthenticateMethod { return .none }
    var prefixPipelines: [ResponsePipeline]? {

        // Convert empty data to an empty JSON `{}`
        let isDataEmpty: ((Data) -> Bool) = { $0.isEmpty }
        let dataTransformer = DataTransformRedirector(condition: isDataEmpty) { _ in
            return "{}".data(using: .utf8)!
        }
        return [
            .redirector(dataTransformer)
        ]
    }
}

struct PostRevokeTokenRequest: RevokeTokenRequest {
    let channelID: String
    let accessToken: String
    
    var parameters: [String : Any]? {
        return [
            "client_id": channelID,
            "access_token": accessToken
        ]
    }
    
    typealias Response = Unit
}

struct PostRevokeRefreshTokenRequest: RevokeTokenRequest {
    let channelID: String
    let refreshToken: String

    var parameters: [String : Any]? {
        return [
            "client_id": channelID,
            "refresh_token": refreshToken
        ]
    }

    typealias Response = Unit
}
