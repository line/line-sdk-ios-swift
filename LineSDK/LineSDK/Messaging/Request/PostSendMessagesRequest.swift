//
//  PostSendMessagesRequest.swift
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

/// LINE internal use only.
/// Represents the request of sending some messages to a certain chat destination on behalf of the current
/// authorized user. This request requires you have the `.messageWrite` permission, otherwise, you would get a 403
/// permission grant error.
public struct PostSendMessagesRequest: Request {
    
    /// A chat ID to send messages to. It could be an ID of user, room, group or square chat ID.
    public let chatID: String
    
    /// `Messages`s will be sent. Up to 5 elements.
    public let messages: [Message]
    
    /// Creates a request consisted of given `chatID` and `messages`.
    ///
    /// - Parameters:
    ///   - chatID: The chat ID to where messages will be sent.
    ///   - messages: `Messages`s will be sent. Up to 5 elements.
    public init(chatID: String, messages: [MessageConvertible]) {
        self.chatID = chatID
        self.messages = messages.map { $0.message }
    }
    
    public let method: HTTPMethod = .post
    public let path = "/message/v3/send"
    public let authentication: AuthenticateMethod = .token
    
    public var parameters: [String: Any]? {
        return [
            "to": chatID,
            "messages": try! messages.toJSON()
        ]
    }
    
    /// Server response of `PostSendMessagesRequest`.
    public struct Response: Decodable {
        /// Represents the sending status.
        public let status: MessageSendingStatus
    }
}

/// Represents whether the message sending succeeded or discarded.
///
/// - ok: Messages are delivered successfully.
/// - discarded: Messages are delivered but the receiver discarded them. This is due to receiver has turned off the
///              1-to-1 messages in settings for the channel message or unapproved channel message. This `discarded`
///              status does not apply for messages sent to room, group or square chat.
/// - unknown: Server returns an unknown status code, which is bound to the associated value in this case.
///
public enum MessageSendingStatus: Decodable, Equatable {
    
    /// Messages are delivered successfully.
    case ok
    
    /// Messages are delivered but the receiver discarded them. This is due to receiver has turned off the
    /// 1-to-1 messages in settings for the channel message or unapproved channel message. This `discarded`
    /// status does not apply for messages sent to room, group or square chat.
    case discarded
    
    /// Server returns an unknown status code, which is bound to the associated value in this case.
    case unknown(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "ok": self = .ok
        case "discarded": self = .discarded
        default: self = .unknown(rawValue)
        }
    }
    
    /// Returns whether this status representing an `.ok` result.
    public var isOK: Bool {
        if case .ok = self {
            return true
        }
        return false
    }
}
