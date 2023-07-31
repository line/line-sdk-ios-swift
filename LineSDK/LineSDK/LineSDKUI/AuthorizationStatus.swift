//
//  AuthorizationStatus.swift
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

/// Represents the authorization status for a certain action.
/// Before creating and presenting a UI in LINE SDK, we strongly recommend checking whether your app
/// has a valid token and the necessary permissions.
///
/// A local authorization status checking API returns an `AuthorizationStatus` value to indicate the
/// current authorization status for giving action.
///
/// - lackOfToken:        There is no valid token in the local token store. The user hasn't logged in and authorized
///                       your app yet.
/// - lackOfPermissions:  There is a valid token, but it doesn't contain the necessary permissions.
///                       The associated value is an array of `LoginPermission`, containing all lacking permissions.
/// - authorized:         The token exists locally and contains the necessary permissions.
///
public enum AuthorizationStatus {
    
    /// There is no valid token in the local token store. The user hasn't logged in and authorized your app yet.
    case lackOfToken
    
    /// There is a valid token, but it doesn't contain the necessary permissions for sharing a message.
    /// The associated value is an array of `LoginPermission`, containing all lacking permissions.
    case lackOfPermissions(Set<LoginPermission>)
    
    /// The token exists locally and contains the necessary permissions to share messages.
    case authorized
}
