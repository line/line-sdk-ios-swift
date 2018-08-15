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

public struct PostSendMessagesRequest: Request {
    
    public let chatID: String
    public let messages: [Message]
    
    public let method: HTTPMethod = .post
    public let path = "/message/v3/send"
    public let authenticate: AuthenticateMethod = .token
    
    public var parameters: [String: Any]? {
        return [
            "to": chatID,
            "messages": try! messages.toJSON()
        ]
    }
    
    public struct Response: Decodable {
        
        public enum Status: Decodable {
            case ok
            case discarded
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
        }
        
        public let status: Status
    }
}
