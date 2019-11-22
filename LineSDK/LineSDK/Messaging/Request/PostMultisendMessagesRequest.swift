//
//  PostMultisendMessagesRequest.swift
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
/// Represents the request of sending some messages to multiple users on behalf of the current authorized user.
/// This request requires you have the `.messageWrite` permission, otherwise, you would get a 403 permission
/// grant error.
public struct PostMultisendMessagesRequest: Request {

    /// An array of user IDs to where messages will be sent. Up to 10 elements.
    public let userIDs: [String]

    /// `Messages`s will be sent. Up to 5 elements.
    public let messages: [Message]

    /// Creates a request consisted of given `chatID` and `messages`.
    ///
    /// - Parameters:
    ///   - userIDs: An array of users' ID to where messages will be sent.
    ///   - messages: `Messages`s will be sent. Up to 5 elements.
    public init(userIDs: [String], messages: [MessageConvertible]) {
        self.userIDs = userIDs
        self.messages = messages.map { $0.message }
    }
    
    public let method: HTTPMethod = .post
    public let path = "/message/v3/multisend"
    public let authentication: AuthenticateMethod = .token
    
    public var parameters: [String: Any]? {
        return [
            "to": userIDs,
            "messages": try! messages.toJSON()
        ]
    }

    /// Server response of `PostMultisendMessagesRequest`.
    public struct Response: Decodable {
        
        /// Represents a result pair of message sending behavior.
        public struct SendingResult: Decodable {
            /// The destination user or group ID of this result.
            public let to: String
            /// Represents the sending status.
            public let status: MessageSendingStatus
        }
        
        /// Represents sending results of this request. Each `SendingResult` in this array represents a result for a
        /// specified user in `userIDs` of request.
        public let results: [SendingResult]
    }
}
