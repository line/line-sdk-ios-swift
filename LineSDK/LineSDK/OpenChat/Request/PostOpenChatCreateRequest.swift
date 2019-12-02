//
//  PostOpenChatCreateRequest.swift
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

public struct OpenChatRoomCreatingItem {
    // length <= 50
    public let name: String
    // length <= 200
    public let description: String
    // length <= 50
    public let creatorDisplayName: String
    public let category: Int
    public let allowSearch: Bool
    
    public init(
        name: String,
        description: String,
        creatorDisplayName: String,
        category: OpenChatCategory,
        allowSearch: Bool
    )
    {
        self.name = name
        self.description = description
        self.creatorDisplayName = creatorDisplayName
        self.category = category.rawValue
        self.allowSearch = allowSearch
    }
    
    var toDictionary: [String: Any] {
        return [
            "name": name,
            "description": description,
            "creatorDisplayName": creatorDisplayName,
            "category": category,
            "allowSearch": allowSearch
        ]
    }
}

public struct OpenChatRoomInfo: Decodable {
    public let squareMid: String
    public let url: URL
}

public struct PostOpenChatCreateRequest: Request {
    
    public typealias Response = OpenChatRoomInfo
    
    public let method: HTTPMethod = .post
    public let path = "/square/v1/square"
    public let authentication: AuthenticateMethod = .token
    
    public let room: OpenChatRoomCreatingItem
    
    public init(room: OpenChatRoomCreatingItem) {
        self.room = room
    }
    
    public var parameters: Parameters? {
        return room.toDictionary
    }
}
