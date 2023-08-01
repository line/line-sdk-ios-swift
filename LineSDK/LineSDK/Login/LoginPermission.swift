//
//  LoginPermission.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

/// Represents the possible login permissions to be set in the authorization request.
public struct LoginPermission: Hashable {
    /// The raw value of the permission. A `LoginPermission` object is composed of a plain raw string.
    public let rawValue: String

    /// Initializes a `LoginPermission` value with a plain string. Use this method to set permissions that
    /// are not defined in the framework.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The permission to get an ID token in the login response.
    public static let openID                         = LoginPermission(rawValue: "openid")

    /// The permission to get the user's profile including the user ID, display name, and the profile image
    /// URL in the login response.
    public static let profile                        = LoginPermission(rawValue: "profile")
    
    /// The permission to select friends or groups and share content with them.
    public static let oneTimeShare                   = LoginPermission(rawValue: "onetime.share")

    /// :nodoc:
    /// LINE internal use only. The permission to get friends information of current user.
    public static let friends                        = LoginPermission(rawValue: "friends")

    /// :nodoc:
    /// LINE internal use only. The permission to get groups information of current user.
    public static let groups                         = LoginPermission(rawValue: "groups")

    /// :nodoc:
    /// LINE internal use only. The permission to write a message as current user.
    public static let messageWrite                   = LoginPermission(rawValue: "message.write")
    
    /// The permission to check Open Chat use term agreement status. This is necessary if you want to create or join an
    /// open chat room.
    public static let openChatTermStatus             = LoginPermission(rawValue: "openchat.term.agreement.status")
    
    /// The permission to create or join to an Open Chat room.
    public static let openChatRoomCreateAndJoin      = LoginPermission(rawValue: "openchat.create.join")
    
    /// The permission to check subscription information of an Open Chat room.
    public static let openChatInfo                   = LoginPermission(rawValue: "openchat.info")
}

/// Sub-permissions of .openID. Permissions in this extension will not be included in the `permissions` property of
/// issued access token.
extension LoginPermission {
    /// The permission to get the user's email from an ID Token in the login response. This permission
    /// requires the `.openID` permission to be granted at the same time. The channel of your app must have
    /// the email permission that can be configured in the LINE Developers console.
    public static let email                          = LoginPermission(rawValue: "email")
}

/// :nodoc:
/// LINE internal use only. Sub-permissions of .openID. Permissions in this extension will not be included in
/// the `permissions` property of issued access token.
extension LoginPermission {
    /// Whether you can access user's phone inside ID Token. Requires `.openID` set.
    /// Only available to LINE internal partners.
    public static let phone                          = LoginPermission(rawValue: "phone")

    /// Whether you can access user's gender inside ID Token. Requires `.openID` set.
    /// Only available to LINE internal partners.
    public static let gender                         = LoginPermission(rawValue: "gender")

    /// Whether you can access user's date of birth inside ID Token. Requires `.openID` set.
    /// Only available to LINE internal partners.
    public static let birthdate                      = LoginPermission(rawValue: "birthdate")

    /// Whether you can access user's address inside ID Token. Requires `.openID` set.
    /// Only available to LINE internal partners.
    public static let address                        = LoginPermission(rawValue: "address")

    /// Whether you can access user's real name inside ID Token. Requires `.openID` set.
    /// Only available to LINE internal partners.
    public static let realName                       = LoginPermission(rawValue: "real_name")
}

/// :nodoc:
/// LINE internal use only. Sub-permissions of Open Chat Plug.
extension LoginPermission {
    public static let openChatPlugManagement          = LoginPermission(rawValue: "openchatplug.managament")
    public static let openChatPlugInfo                = LoginPermission(rawValue: "openchatplug.info")
    public static let openChatPlugProfile             = LoginPermission(rawValue: "openchatplug.profile")
    public static let openChatPlugSendMessage         = LoginPermission(rawValue: "openchatplug.send.message")
    public static let openChatPlugReceiveMessageEvent = LoginPermission(rawValue: "openchatplug.receive.message.and.event")
}

/// :nodoc:
extension LoginPermission: CustomStringConvertible {
    public var description: String { return rawValue }
}
