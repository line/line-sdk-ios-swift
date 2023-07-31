//
//  GetOpenChatRoomStatusRequest.swift
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

/// Represents a request for getting the status of a given Open Chat room.
public struct GetOpenChatRoomStatusRequest: Request {
    
    /// The status of an Open Chat room.
    public enum Status: String, Codable {
        /// The room is alive. Other users can join it.
        case alive = "ALIVE"
        /// The room is already deleted.
        case deleted = "DELETED"
        /// The room is suspended for some reason.
        case suspended = "SUSPENDED"
        /// The received state is not defined yet in current version.
        /// Try to upgrade to the latest SDK version if you encountered this.
        case undefined

        /// :nodoc:
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = Status(rawValue: value) ?? .undefined
        }
    }
    
    /// The response of a `GetOpenChatRoomStatusRequest`.
    public struct Response: Codable {
        /// The status of the requested room.
        public let status: Status
    }
    /// :nodoc:
    public let method: HTTPMethod = .get
    /// :nodoc:
    public var path: String { return "/openchat/v1/openchats/\(openChatId)/status" }
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
