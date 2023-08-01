//
//  GetOpenChatTermAgreementStatusRequest.swift
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

import Foundation

/// Represents a request for getting Open Chat user term agreement status of current user.
/// Unless the user has agreed the use term, creating an Open Chat room is not permitted.
public struct GetOpenChatTermAgreementStatusRequest: Request {
    
    /// The response of a `GetOpenChatTermAgreementStatusRequest`.
    public struct Response: Decodable {
        /// Whether the user has already agreed the use term.
        public let agreed: Bool
    }
    
    /// :nodoc:
    public let method: HTTPMethod = .get
    /// :nodoc:
    public let path = "/openchat/v1/terms/agreement"
    /// :nodoc:
    public let authentication: AuthenticateMethod = .token
    /// :nodoc:
    public init() { }
}
