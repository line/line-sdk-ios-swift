//
//  UserProfile.swift
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

/// Represents a response to the `GetUserProfileRequest` method.
public struct UserProfile: Codable {
    
    /// The user ID of the current authorized user.
    public let userID: String
    
    /// The display name of the current authorized user.
    public let displayName: String
    
    /// The profile image URL of the current authorized user. `nil` if the user has not set a profile
    /// image.
    public let pictureURL: URL?
    
    /// The large profile image URL of the current authorized user. `nil` if the user has not set a profile
    /// image.
    public var pictureURLLarge: URL? {
        return pictureURL?.appendingPathComponent("/large")
    }
    
    /// The small profile image URL of the current authorized user. `nil` if the user has not set a profile
    /// image.
    public var pictureURLSmall: URL? {
        return pictureURL?.appendingPathComponent("/small")
    }
    
    /// The status message of the current authorized user. `nil` if the user has not set a status message.
    public let statusMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case displayName
        case pictureURL = "pictureUrl"
        case statusMessage
    }
}
