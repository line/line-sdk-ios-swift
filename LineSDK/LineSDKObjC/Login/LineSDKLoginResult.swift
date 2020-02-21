//
//  LineSDKLoginResult.swift
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
public class LineSDKLoginResult: NSObject {
    let _value: LoginResult
    init(_ value: LoginResult) { _value = value }
    
    public var accessToken: LineSDKAccessToken { return .init(_value.accessToken) }
    public var permissions: Set<LineSDKLoginPermission> { return Set(_value.permissions.map { .init($0) }) }
    public var userProfile: LineSDKUserProfile? { return _value.userProfile.map { .init($0) } }
    public var friendshipStatusChanged: NSNumber? { return _value.friendshipStatusChanged.map { .init(value: $0) } }
    public var IDTokenNonce: String? { return _value.IDTokenNonce }

    public var json: String? { return toJSON(_value) }
}
