//
//  GetBotFriendshipStatus.swift
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

/// Represents a request for getting the friendship status of the user and the bot linked to your LINE Login
/// channel.
public struct GetBotFriendshipStatusRequest: Request {
    
    /// :nodoc:
    public let method: HTTPMethod = .get
    /// :nodoc:
    public let path: String = "/friendship/v1/status"
    /// :nodoc:
    public let authentication: AuthenticateMethod = .token
    /// :nodoc:
    public init() {}
    
    /// Represents a response to a request for getting the friendship status of the user and the bot linked to
    /// your LINE Login channel.
    public struct Response: Codable {
        /// Indicates the friendship status. `true` if the bot is a friend of the user and the user has not
        /// blocked the bot. `false` if the bot is not a friend of the user or the user has blocked the bot. 
        public let friendFlag: Bool
    }
}
