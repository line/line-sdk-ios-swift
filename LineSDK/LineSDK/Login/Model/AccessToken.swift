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

/// Represents an access token which is used to access the LINE Platform. Most API calls to the LINE Platform
/// require an access token as evidence of successful authorization. A valid access token is issued after the
/// user grants your app the permissions that your app requests. An access token is bound to permissions (scopes)
/// that define the API endpoints that you can access. Choose the permissions for your channel in the LINE
/// Developers site and set them in the login method used in your app.
///
/// An access token will expire after a certain period. Check the `expiresAt` property, which contains the
/// expiration time calculated with the local time setting. Any API call will attempt to refresh the access
/// token if necessary, when it requires authorization.
///
/// By default, the LINE SDK stores an access token in the keychain for your app and obtains authorization when
/// you access the LINE Platform through the framework request methods.
///
/// Do not try to create an access token yourself. You can get a valid access token in use by accessing the
/// `current` property of an `AccessTokenStore` object.
///
public struct AccessToken: Codable, AccessTokenType, Equatable {

    /// The value of the access token.
    public let value: String

    let expiresIn: TimeInterval

    /// The creation time of the access token. It is the system time of the device that receives the current
    /// access token.
    public let createdAt: Date

    /// The ID token bound to the access token. The value exists only if the access token is obtained with
    /// the `.openID` permission.
    public let IDToken: JWT?

    /// The raw string value of the ID token bound to the access token. The value exists only if the access token
    /// is obtained with the `.openID` permission.
    public let IDTokenRaw: String?

    /// The refresh token bound to the access token.
    @available(*, unavailable,
    message: "`refreshToken` is not publicly provided anymore. You should not access or store it yourself.")
    public var refreshToken: String { Log.fatalError("`refreshToken` is not publicly provided anymore.") }

    let _refreshToken: String

    /// Permissions of the access token.
    public let permissions: [LoginPermission]
    let tokenType: String

    /// The expiration time of the access token. It is calculated using `createdAt` and the validity period
    /// of the access token. This value might not be the actual expiration time because this value depends
    /// on the system time of the device when `createdAt` is determined.
    public var expiresAt: Date {
        return createdAt.addingTimeInterval(expiresIn)
    }

    enum CodingKeys: String, CodingKey {
        case value = "access_token"
        case expiresIn = "expires_in"
        case IDTokenRaw = "id_token"
        case refreshToken = "refresh_token"
        case scope
        case tokenType = "token_type"
        case createdAt
    }

    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        expiresIn = try container.decode(TimeInterval.self, forKey: .expiresIn)

        // Try to decode createdAt. If there is no such value, it means we are receiving it
        // from server and we should create a reference Date for it.
        // Otherwise, it is the case that loaded from keychain.
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()

        IDTokenRaw = try container.decodeIfPresent(String.self, forKey: .IDTokenRaw)
        if let tokenRaw = IDTokenRaw {
            IDToken = try JWT(text: tokenRaw)
        } else {
            IDToken = nil
        }

        _refreshToken = try container.decode(String.self, forKey: .refreshToken)
        permissions = try container.decodeLoginPermissions(forKey: .scope)
        tokenType = try container.decode(String.self, forKey: .tokenType)
    }

    // Internal helper for creating a new token object while retaining current ID Token when refreshing.
    init(token: AccessToken, currentIDTokenRaw: String?) throws {
        self.value = token.value
        self.expiresIn = token.expiresIn
        self.createdAt = token.createdAt
        self._refreshToken = token._refreshToken
        self.permissions = token.permissions
        self.tokenType = token.tokenType

        self.IDTokenRaw = currentIDTokenRaw
        if let tokenRaw = IDTokenRaw {
            IDToken = try JWT(text: tokenRaw)
        } else {
            IDToken = nil
        }
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: .value)
        try container.encode(expiresIn, forKey: .expiresIn)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(IDTokenRaw, forKey: .IDTokenRaw)
        try container.encode(_refreshToken, forKey: .refreshToken)
        try container.encodeLoginPermissions(permissions, forKey: .scope)
        try container.encode(tokenType, forKey: .tokenType)
    }
}
