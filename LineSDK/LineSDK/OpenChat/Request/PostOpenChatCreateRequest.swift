//
//  PostOpenChatCreateRequest.swift
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

/// The basic Open Chat room information.
public struct OpenChatRoomInfo: Decodable {
    
    /// The identifier of this Open Chat room.
    public let openChatId: String
    
    /// The URL of this Open Chat room. Open this URL will navigate to LINE app (if installed) or a web page
    /// for the Open Chat room.
    public let url: URL

    enum CodingKeys: String, CodingKey {
        case openChatId = "openchatId"
        case url
    }
}

/// Represents a request for creating an Open Chat room.
public struct PostOpenChatCreateRequest: Request {
    /// :nodoc:
    public typealias Response = OpenChatRoomInfo
    /// :nodoc:
    public let method: HTTPMethod = .post
    /// :nodoc:
    public let path = "/openchat/v1/openchats"
    /// :nodoc:
    public let authentication: AuthenticateMethod = .token
    
    /// The room information will be used to create the room.
    public let room: OpenChatRoomCreatingItem
    
    /// :nodoc:
    public init(room: OpenChatRoomCreatingItem) {
        self.room = room
    }
    /// :nodoc:
    public var parameters: Parameters? {
        return room.toDictionary
    }
}

extension OpenChatRoomCreatingItem {
    fileprivate var toDictionary: [String: Any] {
        return [
            "name": name,
            "description": roomDescription,
            "creatorDisplayName": creatorDisplayName,
            "category": category,
            "allowSearch": allowSearch
        ]
    }
}
