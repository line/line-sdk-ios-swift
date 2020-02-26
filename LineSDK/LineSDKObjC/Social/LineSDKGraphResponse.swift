//
//  LineSDKGetFriendsResponse.swift
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
public class LineSDKGetFriendsResponse: NSObject {
    let _value: GetFriendsRequest.Response
    init(_ value: GetFriendsRequest.Response) { _value = value }
    
    public var friends: [LineSDKUser] { return _value.friends.map { .init($0) } }
    public var pageToken: String? { return _value.pageToken }
}

@objcMembers
public class LineSDKGetGroupsResponse: NSObject {
    let _value: GetGroupsRequest.Response
    init(_ value: GetGroupsRequest.Response) { _value = value }
    
    public var groups: [LineSDKGroup] { return _value.groups.map { .init($0) } }
    public var pageToken: String? { return _value.pageToken }
}

@objcMembers
public class LineSDKGetApproversInFriendsResponse: NSObject {
    let _value: GetApproversInFriendsRequest.Response
    init(_ value: GetApproversInFriendsRequest.Response) { _value = value }
    
    public var friends: [LineSDKUser] { return _value.friends.map { .init($0) } }
    public var pageToken: String? { return _value.pageToken }
}

@objcMembers
public class LineSDKGetApproversInGroupResponse: NSObject {
    let _value: GetApproversInGroupRequest.Response
    init(_ value: GetApproversInGroupRequest.Response) { _value = value }
    
    public var users: [LineSDKUser] { return _value.users.map { .init($0) } }
    public var pageToken: String? { return _value.pageToken }
}

@objc
public enum LineSDKGetFriendsRequestSort: Int {
    case none
    case name
    case relation
    
    var unwrapped: GetFriendsRequest.Sort? {
        switch self {
        case .none: return nil
        case .name: return .name
        case .relation: return .relation
        }
    }
    
    init(_ value: GetFriendsRequest.Sort?) {
        switch value {
        case .name?: self = .name
        case .relation?: self = .relation
        case nil: self = .none
        }
    }
}
