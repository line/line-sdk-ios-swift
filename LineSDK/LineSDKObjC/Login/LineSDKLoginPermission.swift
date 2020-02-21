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

#if !LineSDKCocoaPods && !LineSDKBinary
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

    public static func permissions(from string: String) -> Set<LineSDKLoginPermission> {
        let permissions = string.split(separator: " ").map { LineSDKLoginPermission(rawValue: String($0)) }
        return Set(permissions)
    }

    public static let openID                         = LineSDKLoginPermission(.openID)
    public static let profile                        = LineSDKLoginPermission(.profile)
    public static let friends                        = LineSDKLoginPermission(.friends)
    public static let groups                         = LineSDKLoginPermission(.groups)
    public static let oneTimeShare                   = LineSDKLoginPermission(.oneTimeShare)
    public static let messageWrite                   = LineSDKLoginPermission(.messageWrite)
    
    public static let email                          = LineSDKLoginPermission(.email)
    public static let phone                          = LineSDKLoginPermission(.phone)
    public static let gender                         = LineSDKLoginPermission(.gender)
    public static let birthdate                      = LineSDKLoginPermission(.birthdate)
    public static let address                        = LineSDKLoginPermission(.address)
    public static let realName                       = LineSDKLoginPermission(.realName)
    
    var unwrapped: LoginPermission { return _value }
}
