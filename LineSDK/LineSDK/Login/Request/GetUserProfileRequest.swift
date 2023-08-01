//
//  GetUserProfileRequest.swift
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

/// Represents a request for getting the user's profile.
public struct GetUserProfileRequest: Request {
    /// :nodoc:
    public init() {}
    /// :nodoc:
    public let method: HTTPMethod = .get
    /// :nodoc:
    public let path = "/v2/profile"
    /// :nodoc:
    public let authentication: AuthenticateMethod = .token
    /// :nodoc:
    public typealias Response = UserProfile
}

struct GetUserProfileRequestInjectedToken: Request {
    let wrapped: GetUserProfileRequest
    let token: String
    
    init(token: String) {
        self.wrapped = GetUserProfileRequest()
        self.token = token
    }
    
    var method: HTTPMethod { return wrapped.method }
    var path: String { return wrapped.path }
    var authentication: AuthenticateMethod { return wrapped.authentication }
    
    typealias Response = GetUserProfileRequest.Response
    
    // Replace the default token adapter to a newly created one with injected token.
    var adapters: [RequestAdapter] {
        let adapters = wrapped.adapters
        return adapters.map { adapter in
            guard let _ = adapter as? TokenAdapter else {
                return adapter
            }
            return TokenAdapter(token: token)
        }
    }
}
