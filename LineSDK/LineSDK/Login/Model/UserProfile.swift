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

/// Response of `GetUserProfileRequest`.
public struct UserProfile: Decodable {
    
    /// User ID of current authorized user.
    public let userID: String
    
    /// Display name of current authorized user.
    public let displayName: String
    
    /// Picture URL of current authorized user. `nil` if the user does not set a picture as avatar.
    public let pictureURL: URL?
    
    /// Status message of current authorized user. `nil` if the user does not set a status message.
    public let statusMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case displayName
        case pictureURL = "pictureUrl"
        case statusMessage
    }
}
