//
//  AccessTokenVerifyResult.swift
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

/// Represents a response to the `GetVerifyTokenRequest` method.
public struct AccessTokenVerifyResult: Codable {
    
    /// The channel ID bound to the access token.
    public let channelID: String
    
    /// Valid permissions of the access token.
    public let permissions: [LoginPermission]
    
    /// The amount of time until the access token expires.
    public let expiresIn: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case expiresIn = "expires_in"
        case scope
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        channelID = try container.decode(String.self, forKey: .clientID)
        permissions = try container.decodeLoginPermissions(forKey: .scope)
        expiresIn = try container.decode(TimeInterval.self, forKey: .expiresIn)
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(channelID, forKey: .clientID)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encodeLoginPermissions(permissions, forKey: .scope)
    }
}
