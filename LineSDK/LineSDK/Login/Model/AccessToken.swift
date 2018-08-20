//
//  AccessToken.swift
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

protocol AccessTokenType {}

/// Represents the token which is used to access LINE APIs. Most of LINE API request requires a token as authorization.
/// You will have a valid token after user authorized your application to his/her content.
/// An `AccessToken` is bound to certain `permissions` or so-called scopes. It defines which ones of APIs you could
/// access, and which ones you could not. You need to choose the permissions in LINE Developer center site and in the
/// login method correctly.
///
/// A token will expire after a certain period. You could check it in `expiresAt`, which calculated the expire time by
/// your local timing setting. LineSDK will try to refresh the token automatically if necessary, when you access any
/// APIs which require an authorization.
///
/// By default, LineSDK will also store the token to keychain of your app, as well as setup all authorization when you
/// access LINE's APIs through framework request methods.
///
/// You should never try to create a token yourself. By accessing the `current` property of a `AccessTokenStore`, you
/// could get a valid token in use if there is one.
///
public struct AccessToken: Codable, AccessTokenType, Equatable {
    
    /// The access token value.
    public let value: String
    
    let expiresIn: TimeInterval
    
    /// When this token was created. It is the local time of current token received.
    public let createdAt: Date
    
    /// ID token bound to this token. Only exists if you have the `.openID` permission for the token.
    public let IDToken: String?
    
    /// Refresh token bound to the access token.
    public let refreshToken: String
    
    /// Permissions of the token.
    public let permissions: [LoginPermission]
    let tokenType: String
    
    /// When this token will expire. It is calculated by `createdAt` and a expires duration.
    /// This value depends on the system time when `createdAt` was determined, so it might not be the actual date when
    /// this token gets expired.
    public var expiresAt: Date {
        return createdAt.addingTimeInterval(expiresIn)
    }
    
    enum CodingKeys: String, CodingKey {
        case value = "access_token"
        case expiresIn = "expires_in"
        case IDToken = "id_token"
        case refreshToken = "refresh_token"
        case scope
        case tokenType = "token_type"
        case createdAt
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        expiresIn = try container.decode(TimeInterval.self, forKey: .expiresIn)
        
        // Try to decode createdAt. If there is no such value, it means we are receiving it
        // from server and we should create a reference Date for it.
        // Otherwise, it is the case that loaded from keychain.
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        
        IDToken = try container.decodeIfPresent(String.self, forKey: .IDToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        permissions = try container.decodeLoginPermissions(forKey: .scope)
        tokenType = try container.decode(String.self, forKey: .tokenType)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(IDToken, forKey: .IDToken)
        try container.encode(refreshToken, forKey: .refreshToken)
        
        let scope = permissions.map { $0.rawValue }.joined(separator: " ")
        try container.encode(scope, forKey: .scope)
        
        try container.encode(tokenType, forKey: .tokenType)
    }
}

