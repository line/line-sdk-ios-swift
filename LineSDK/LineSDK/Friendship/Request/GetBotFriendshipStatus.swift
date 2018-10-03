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

/// Represents the request of getting friendship status between the bot
/// (which linked to current channel) and the current authorized user.
public struct GetBotFriendshipStatusRequest: Request {
    
    public let method: HTTPMethod = .get
    public let path: String = "/friendship/v1/status"
    public let authentication: AuthenticateMethod = .token
    
    public init() {}
    
    public struct Response: Decodable {
        /// A flag indicates friendship. `true` means the channel bot is a friend of the user,
        /// and the user is not blocking the bot. `false` means the channel bot is not a friend
        /// of the user, or the bot is a friend but the user is blocking the bot.
        let friendFlag: Bool
    }
}
