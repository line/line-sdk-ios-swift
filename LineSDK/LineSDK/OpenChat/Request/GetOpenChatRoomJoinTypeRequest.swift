//
//  GetOpenChatRoomJoinTypeRequest.swift
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

public struct GetOpenChatRoomJoinTypeRequest: Request {

    /// The joining type of an Open Chat room. The value indicates what is required if a user want to join the room.
    public enum RoomType: String, Decodable {
        /// The room is public and open for anyone to join.
        case `default` = "NONE"
        /// A user needs to request to join the room, only approved user can join. The admins or authority users of the
        /// room can approve the request.
        case approval = "APPROVAL"
        ///  A user needs to input the join code to join the room.
        case code = "CODE"
        /// The received state is not defined yet in current version.
        /// Try to upgrade to the latest SDK version if you encountered this.
        case undefined

        /// :nodoc:
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let value = try container.decode(String.self)
            self = RoomType(rawValue: value) ?? .undefined
        }
    }

    /// The response of a `GetOpenChatRoomJoinTypeRequest`.
    public struct Response: Decodable {
        /// The room joining type of the requested Open Chat room.
        public let type: RoomType
    }

    /// :nodoc:
    public let method: HTTPMethod = .get
    /// :nodoc:
    public var path: String { return "/openchat/v1/openchats/\(openChatId)/type" }
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
