//
//  LoginPermission.swift
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

/// Represents the possible login permissions being sent when login to LINE.
public struct LoginPermission: Hashable {
    /// Raw value of the permission. A `LoginPermission` is composed by a plain raw string.
    public let rawValue: String
    
    /// Inits a `LoginPermission` value with a plain string. You could use this
    /// if a pre-defined permission not defined in the framework.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    /// Whether open_id should be returned as login result.
    public static let openID                         = LoginPermission(rawValue: "openid")
    
    /// Whether could access the user's profile, including user ID, display name, etc.
    public static let profile                        = LoginPermission(rawValue: "profile")
    
    /// Whether could access user's email.
    public static let email                          = LoginPermission(rawValue: "email")
    
    /// Whether could get friends information of current user.
    public static let friends                        = LoginPermission(rawValue: "friends")
    
    /// Whether could get groups information of current user.
    public static let groups                         = LoginPermission(rawValue: "groups")
    
    /// Whether could write a message as current user.
    public static let messageWrite                   = LoginPermission(rawValue: "message.write")
    
    public static let phone                          = LoginPermission(rawValue: "phone")
    public static let birthday                       = LoginPermission(rawValue: "birthday")
    public static let profilePictureUpdate           = LoginPermission(rawValue: "profile.picture.update")
    
    public static let timelinePost                   = LoginPermission(rawValue: "timeline.post")
    public static let addAssociatedOfficialAccounts  = LoginPermission(rawValue: "add_associated_official_accounts")
    
    public static let profileExtendedName            = LoginPermission(rawValue: "profile.extended.name")
    public static let profileExtendedNameUpdate      = LoginPermission(rawValue: "profile.extended.name.update")
    public static let profileExtendedGender          = LoginPermission(rawValue: "profile.extended.gender")
    public static let profileExtendedGenderUpdate    = LoginPermission(rawValue: "profile.extended.gender.update")
    public static let profileExtendedAddress         = LoginPermission(rawValue: "profile.extended.address")
    public static let profileExtendedAddressUpdate   = LoginPermission(rawValue: "profile.extended.address.update")
    public static let profileExtendedBirthday        = LoginPermission(rawValue: "profile.extended.birthday")
    public static let profileExtendedBirthdayUpdate  = LoginPermission(rawValue: "profile.extended.birthday.update")
    
    public static func chatMessageWrite(_ chatID: String) -> LoginPermission {
        return LoginPermission(rawValue: "chat_message.write:\(chatID)")
    }
    public static func squareChatMessageWrite(squareID: String, chatID: String) -> LoginPermission {
        return LoginPermission(rawValue: "square_chat_message.write:\(squareID)/\(chatID)")
    }
    
    public static let payHistory                     = LoginPermission(rawValue: "pay.history")
    public static let payAccount                     = LoginPermission(rawValue: "pay.account")
    public static let merchant                       = LoginPermission(rawValue: "merchant")
    
    public static let gender                         = LoginPermission(rawValue: "gender")
    public static let birthDate                      = LoginPermission(rawValue: "birthdate")
    public static let address                        = LoginPermission(rawValue: "address")
    public static let realName                       = LoginPermission(rawValue: "real_name")
    public static let botAdd                         = LoginPermission(rawValue: "bot.add")
}
