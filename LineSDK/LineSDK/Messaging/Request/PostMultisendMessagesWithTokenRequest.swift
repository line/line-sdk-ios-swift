//
//  PostMultisendMessagesWithTokenRequest.swift
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
/// Represents the request of sending some messages to multiple users on behalf of the current authorized user,
/// with an issued one time token. This is used to share messages.
///
/// `LoginPermission.oneTimeShare` is required.
///
public struct PostMultisendMessagesWithTokenRequest: Request {

    public typealias Response = Unit

    /// An array of user IDs to where messages will be sent. Up to 10 elements.
    public let messageToken: MessageSendingToken

    /// `Messages`s will be sent. Up to 5 elements.
    public let messages: [Message]

    public init(token: MessageSendingToken, messages: [MessageConvertible]) {
        self.messageToken = token
        self.messages = messages.map { $0.message }
    }

    public let method: HTTPMethod = .post
    public let path = "/message/v3/ott/share"
    public let authentication: AuthenticateMethod = .token

    public var parameters: [String: Any]? {
        return [
            "token": messageToken.token,
            "messages": try! messages.toJSON()
        ]
    }
}
