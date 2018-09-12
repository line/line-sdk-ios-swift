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
    
    static let phone                          = LoginPermission(rawValue: "phone")
    static let birthday                       = LoginPermission(rawValue: "birthday")
    static let profilePictureUpdate           = LoginPermission(rawValue: "profile.picture.update")
    
    static let timelinePost                   = LoginPermission(rawValue: "timeline.post")
    static let addAssociatedOfficialAccounts  = LoginPermission(rawValue: "add_associated_official_accounts")
    
    static let profileExtendedName            = LoginPermission(rawValue: "profile.extended.name")
    static let profileExtendedNameUpdate      = LoginPermission(rawValue: "profile.extended.name.update")
    static let profileExtendedGender          = LoginPermission(rawValue: "profile.extended.gender")
    static let profileExtendedGenderUpdate    = LoginPermission(rawValue: "profile.extended.gender.update")
    static let profileExtendedAddress         = LoginPermission(rawValue: "profile.extended.address")
    static let profileExtendedAddressUpdate   = LoginPermission(rawValue: "profile.extended.address.update")
    static let profileExtendedBirthday        = LoginPermission(rawValue: "profile.extended.birthday")
    static let profileExtendedBirthdayUpdate  = LoginPermission(rawValue: "profile.extended.birthday.update")
    
    static func chatMessageWrite(_ chatID: String) -> LoginPermission {
        return LoginPermission(rawValue: "chat_message.write:\(chatID)")
    }
    static func squareChatMessageWrite(squareID: String, chatID: String) -> LoginPermission {
        return LoginPermission(rawValue: "square_chat_message.write:\(squareID)/\(chatID)")
    }
    
    static let payHistory                     = LoginPermission(rawValue: "pay.history")
    static let payAccount                     = LoginPermission(rawValue: "pay.account")
    static let merchant                       = LoginPermission(rawValue: "merchant")
    
    static let gender                         = LoginPermission(rawValue: "gender")
    static let birthDate                      = LoginPermission(rawValue: "birthdate")
    static let address                        = LoginPermission(rawValue: "address")
    static let realName                       = LoginPermission(rawValue: "real_name")
    static let botAdd                         = LoginPermission(rawValue: "bot.add")
}

extension LoginPermission: CustomStringConvertible {
    public var description: String { return rawValue }
}
