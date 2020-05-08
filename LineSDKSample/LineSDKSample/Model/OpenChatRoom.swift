//
//  OpenChatRoom.swift
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

class OpenChatRoom: Codable {
    let chatRoomId: String
    let url: URL

    init(chatRoomId: String, url: URL) {
        self.chatRoomId = chatRoomId
        self.url = url
    }
}

extension OpenChatRoom {

    static var onUpdated: (() -> Void)?

    static var all: [OpenChatRoom] {
        return builtInRooms + createdRooms
    }

    static let builtInRooms: [OpenChatRoom] = [
    ]

    static let url: URL = {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("created_rooms.json")
        return url
    }()

    static var createdRooms: [OpenChatRoom] = {
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([OpenChatRoom].self, from: data)
        } catch {
            return []
        }
    }()
    {
        didSet {
            guard let data = try? JSONEncoder().encode(createdRooms) else {
                return
            }
            try? data.write(to: url)
            onUpdated?()
        }
    }
}
