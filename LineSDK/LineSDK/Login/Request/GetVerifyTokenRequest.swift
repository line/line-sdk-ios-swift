//
//  GetVerifyTokenRequest.swift
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

/// Represents a request for verifying an access token.
public struct GetVerifyTokenRequest: Request {
    
    /// The access token to be verified.
    public let accessToken: String
    
    /// Creates a token verification request.
    public init(accessToken: String) {
        self.accessToken = accessToken
    }
    
    /// :nodoc:
    public let method: HTTPMethod = .get
    /// :nodoc:
    public let path = "/oauth2/v2.1/verify"
    /// :nodoc:
    public let authentication: AuthenticateMethod = .none
    
    /// :nodoc:
    public var parameters: Parameters? {
        return [ "access_token": accessToken ]
    }
    
    /// :nodoc:
    public typealias Response = AccessTokenVerifyResult
}
