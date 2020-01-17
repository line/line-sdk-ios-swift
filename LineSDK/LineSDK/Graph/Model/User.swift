//
//  User.swift
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
/// Represents a `User` object which LineSDK used in `friend list` or `approvers in friend list`.
public struct User: Decodable {

    /// Identifier of the user.
    public let userID: String

    /// User's display name. This is the preferred username to be displayed in UI. When 
    /// `displayNameOverridden` is not `nil`, this value is identical to it. Otherwise, it is `displayNameOriginal`.
    public var displayName: String { return displayNameOverridden ?? displayNameOriginal }
    
    /// User's original display name. It is the friend's user display name set by himself/herself.
    public let displayNameOriginal: String
    
    /// User's overridden display name. It is the friend’s nickname which changed by the current user.
    /// It is `nil` if the current user didn't set a nickname for this user.
    public let displayNameOverridden: String?

    /// Profile image URL. Not included in the response if the user doesn't have a profile image.
    public let pictureURL: URL?

    /// URL of user's large profile image. `nil` if no profile image is set.
    public var pictureURLLarge: URL? {
        return pictureURL?.appendingPathComponent("/large")
    }

    /// URL of user's small profile image. `nil` if no profile image is set.
    public var pictureURLSmall: URL? {
        return pictureURL?.appendingPathComponent("/small")
    }

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case displayNameOriginal = "displayName"
        case displayNameOverridden
        case pictureURL = "pictureUrl"
    }
}
