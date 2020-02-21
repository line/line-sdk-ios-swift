//
//  LineSDKJWT.swift
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
public class LineSDKJWT: NSObject {
    public let payload: LineSDKJWTPayload
    init(_ value: JWT) {
        payload = LineSDKJWTPayload(value.payload)
    }
    
}

@objcMembers
public class LineSDKJWTPayload: NSObject {
    let value: JWT.Payload
    init(_ value: JWT.Payload) {
        self.value = value
    }
    
    public func getString(forKey key: String) -> String? {
        return value[key, String.self]
    }
    
    public func getNumber(forKey key: String) -> NSNumber? {
        if let value = value[key, Int.self] {
            return .init(value: value)
        } else if let value = value[key, Int.self] {
            return .init(value: value)
        } else if let value = value[key, Int.self] {
            return .init(value: value)
        } else {
            return nil
        }
    }

    public var issuer: String? { return value.issuer }
    public var subject: String? { return value.subject }
    public var audience: String? { return value.audience }
    public var expiration: Date? { return value.expiration }
    public var issueAt: Date? { return value.issueAt }
    public var name: String? { return value.name }
    public var picture: URL? { return value.pictureURL }
    public var email: String? { return value.email }
    public var amr: [String]? { return value.amr }
}
