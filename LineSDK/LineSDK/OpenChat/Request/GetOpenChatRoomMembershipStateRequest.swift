//
//  GetOpenChatRoomMembershipStateRequest.swift
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

/// Represents a request for getting membership of current user to a given Open Chat room.
public struct GetOpenChatRoomMembershipStateRequest: Request {
    
    /// The membership state of current user to the room.
    public enum State: String, Decodable {
        /// The user has already joined the room.
        case joined = "JOINED"
        /// The user is not a member of the room yet.
        case notJoined = "NOT_JOINED"
        /// The received state is not defined yet in current version.
        /// Try to upgrade to the latest SDK version if you encountered this.
        case undefined

        /// :nodoc:
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = State(rawValue: value) ?? .undefined
        }
    }
    
    /// The response of a `GetOpenChatRoomMembershipStateRequest`.
    public struct Response: Decodable {
        /// The membership state of current user.
        public let state: State
    }
    
    /// :nodoc:
    public let method: HTTPMethod = .get
    /// :nodoc:
    public var path: String { return "/openchat/v1/openchats/\(openChatId)/members/me/membership" }
    /// :nodoc:
    public let authentication: AuthenticateMethod = .token
    
    /// The Open Chat room ID.
    public let openChatId: EntityID
    
    /// Creates a request.
    /// - Parameter openChatId: The Open Chat room ID.
    public init(openChatId: EntityID) throws {
        guard openChatId.isValid else {
            throw LineSDKError.requestFailed(reason:
                .invalidParameter([.invalidEntityID("openChatId", value: openChatId)])
            )
        }
        self.openChatId = openChatId
    }
    
}
