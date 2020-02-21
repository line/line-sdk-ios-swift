//
//  LineSDKMessageShareAuthorizationStatus.swift
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
public final class LineSDKMessageShareAuthorizationStatus: NSObject {

    public let rawValue: Int

    public static let authorized    = LineSDKMessageShareAuthorizationStatus(rawValue: 1 << 0)
    public static let lackOfToken   = LineSDKMessageShareAuthorizationStatus(rawValue: 1 << 1)
    public static let lackOfFriendsPermission = LineSDKMessageShareAuthorizationStatus(rawValue: 1 << 2)
    public static let lackOfGroupsPermission = LineSDKMessageShareAuthorizationStatus(rawValue: 1 << 3)
    public static let lackOfMesasgeWritePermission = LineSDKMessageShareAuthorizationStatus(rawValue: 1 << 4)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static func status(from s: MessageShareAuthorizationStatus) -> [LineSDKMessageShareAuthorizationStatus] {
        switch s {
        case .authorized: return [.authorized]
        case .lackOfToken: return [.lackOfToken]
        case .lackOfPermissions(let permissions):
            var results: [LineSDKMessageShareAuthorizationStatus] = []
            if permissions.contains(.friends) { results.append(.lackOfFriendsPermission) }
            if permissions.contains(.groups) { results.append(.lackOfGroupsPermission) }
            if permissions.contains(.messageWrite) { results.append(.lackOfMesasgeWritePermission) }
            return results
        }
    }
}
