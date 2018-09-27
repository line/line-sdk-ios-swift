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
    
    /// Whether could get friends information of current user.
    public static let friends                        = LoginPermission(rawValue: "friends")
    
    /// Whether could get groups information of current user.
    public static let groups                         = LoginPermission(rawValue: "groups")
    
    /// Whether could write a message as current user.
    public static let messageWrite                   = LoginPermission(rawValue: "message.write")
}

/// Subpermissions of .openID. Permissions in this extension will not be included in the `permissions` property of
/// issued access token.
public extension LoginPermission {
    /// Whether could access user's email inside ID Token. Requires `.openID` set.
    public static let email                          = LoginPermission(rawValue: "email")
    
    /// Whether could access user's phone inside ID Token. Requires `.openID` set.
    public static let phone                          = LoginPermission(rawValue: "phone")
    
    /// Whether could access user's gender inside ID Token. Requires `.openID` set.
    public static let gender                         = LoginPermission(rawValue: "gender")
    
    /// Whether could access user's birthdate inside ID Token. Requires `.openID` set.
    public static let birthdate                      = LoginPermission(rawValue: "birthdate")
    
    /// Whether could access user's address inside ID Token. Requires `.openID` set.
    public static let address                        = LoginPermission(rawValue: "address")
    
    /// Whether could access user's real name inside ID Token. Requires `.openID` set.
    public static let realName                      = LoginPermission(rawValue: "real_name")
    
}

extension LoginPermission: CustomStringConvertible {
    public var description: String { return rawValue }
}
