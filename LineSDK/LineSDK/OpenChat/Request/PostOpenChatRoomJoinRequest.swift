//
//  PostOpenChatRoomJoinRequest.swift
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

/// Represents a request for joining an Open Chat room.
public struct PostOpenChatRoomJoinRequest: Request {
    /// :nodoc:
    public typealias Response = Unit
    /// :nodoc:
    public let method: HTTPMethod = .post
    /// :nodoc:
    public var path: String { return "/openchat/v1/openchats/\(openChatId)/join" }
    /// :nodoc:
    public let authentication: AuthenticateMethod = .token

    /// The identifier of the joining Open Chat room.
    public let openChatId: EntityID

    /// The desired display name of current user in the Open Chat room.
    public let displayName: String

    /// :nodoc:
    public init(openChatId: EntityID, displayName: String) throws {
        guard openChatId.isValid else {
            throw LineSDKError.requestFailed(reason:
                .invalidParameter([.invalidEntityID("openChatId", value: openChatId)])
            )
        }
        self.openChatId = openChatId
        self.displayName = displayName
    }

    public var prefixPipelines: [ResponsePipeline]? {
        return [emptyDataTransformer]
    }

    public var parameters: Parameters? {
        return ["displayName": displayName]
    }
}
