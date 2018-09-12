//
//  LineSDKLoginPermission.swift
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

#if !LineSDKCocoaPods
import LineSDK
#endif

@objcMembers
public class LineSDKLoginPermission: NSObject {
    let _value: LoginPermission
    convenience init(_ value: LoginPermission) {
        self.init(rawValue: value.rawValue)
    }
    public init(rawValue: String) {
        _value = .init(rawValue: rawValue)
    }

    public static let openID                         = LineSDKLoginPermission(.openID)
    public static let profile                        = LineSDKLoginPermission(.profile)
    public static let email                          = LineSDKLoginPermission(.email)
    public static let friends                        = LineSDKLoginPermission(.friends)
    public static let groups                         = LineSDKLoginPermission(.groups)
    public static let messageWrite                   = LineSDKLoginPermission(.messageWrite)
//    public static let phone                          = LineSDKLoginPermission(.phone)
//    public static let birthday                       = LineSDKLoginPermission(.birthday)
//    public static let profilePictureUpdate           = LineSDKLoginPermission(.profilePictureUpdate)
//    public static let timelinePost                   = LineSDKLoginPermission(.timelinePost)
//    public static let addAssociatedOfficialAccounts  = LineSDKLoginPermission(.addAssociatedOfficialAccounts)
//    public static let profileExtendedName            = LineSDKLoginPermission(.profileExtendedName)
//    public static let profileExtendedNameUpdate      = LineSDKLoginPermission(.profileExtendedNameUpdate)
//    public static let profileExtendedGender          = LineSDKLoginPermission(.profileExtendedGender)
//    public static let profileExtendedGenderUpdate    = LineSDKLoginPermission(.profileExtendedGenderUpdate)
//    public static let profileExtendedAddress         = LineSDKLoginPermission(.profileExtendedAddress)
//    public static let profileExtendedAddressUpdate   = LineSDKLoginPermission(.profileExtendedAddressUpdate)
//    public static let profileExtendedBirthday        = LineSDKLoginPermission(.profileExtendedBirthday)
//    public static let profileExtendedBirthdayUpdate  = LineSDKLoginPermission(.profileExtendedBirthdayUpdate)
//    public static let payHistory                     = LineSDKLoginPermission(.payHistory)
//    public static let payAccount                     = LineSDKLoginPermission(.payAccount)
//    public static let merchant                       = LineSDKLoginPermission(.merchant)
//    public static let gender                         = LineSDKLoginPermission(.gender)
//    public static let birthDate                      = LineSDKLoginPermission(.birthDate)
//    public static let address                        = LineSDKLoginPermission(.address)
//    public static let realName                       = LineSDKLoginPermission(.realName)
//    public static let botAdd                         = LineSDKLoginPermission(.botAdd)
    
    public static func chatMessageWrite(_ chatID: String) -> LineSDKLoginPermission {
        return LineSDKLoginPermission(.init(rawValue: "chat_message.write:\(chatID)"))
    }
    
    public static func squareChatMessageWrite(squareID: String, chatID: String) -> LineSDKLoginPermission {
        return LineSDKLoginPermission(.init(rawValue: "square_chat_message.write:\(squareID)/\(chatID)"))
    }
    
    var unwrapped: LoginPermission { return _value }
}
