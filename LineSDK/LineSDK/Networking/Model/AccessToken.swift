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

public struct AccessToken: Codable, AccessTokenType, Equatable {
    let value: String
    let expiresIn: TimeInterval
    let createdAt: Date
    let IDToken: String?
    let refreshToken: String
    let permissions: [LoginPermission]
    let tokenType: String
    
    var expiresAt: Date {
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
        
        let scopes = try container.decode(String.self, forKey: .scope)
        permissions = scopes.split(separator: " ").compactMap { scope in
            // Ignore empty permissions
            if scope.trimmingCharacters(in: .whitespaces).isEmpty {
                return nil
            }
            return LoginPermission(rawValue: String(scope))
        }
        
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

