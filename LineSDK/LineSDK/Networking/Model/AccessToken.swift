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

struct AccessToken: Decodable {
    let value: String
    let expiresAt: Date
    let IDToken: String?
    let refreshToken: String
    let permissions: [LoginPermission]
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case value = "access_token"
        case expiresIn = "expires_in"
        case IDToken = "id_token"
        case refreshToken = "refresh_token"
        case scope
        case tokenType = "token_type"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        value = try container.decode(String.self, forKey: .value)
        
        let expiresIn = try container.decode(TimeInterval.self, forKey: .expiresIn)
        expiresAt = Date(timeIntervalSinceNow: expiresIn)
        
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
}
