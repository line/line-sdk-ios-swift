//
//  LineSDKAccessToken.swift
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

@objcMembers
public class LineSDKAccessToken: NSObject {
    let _value: AccessToken
    init(_ value: AccessToken) { _value = value }
    
    public var value: String { return _value.value }
    public var createdAt: Date { return _value.createdAt }
    public var IDToken: LineSDKJWT? { return _value.IDToken.map { .init($0) } }
    public var IDTokenRaw: String? { return _value.IDTokenRaw }

    public var permissions: [LineSDKLoginPermission] { return _value.permissions.map { .init($0) } }
    public var expiresAt: Date { return _value.expiresAt }

    public var json: String? { return toJSON(_value) }
}
