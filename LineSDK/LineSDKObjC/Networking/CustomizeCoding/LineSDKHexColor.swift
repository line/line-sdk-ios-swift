//
//  LineSDKHexColor.swift
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

import UIKit
#if !LineSDKCocoaPods && !LineSDKBinary
import LineSDK
#endif

@objcMembers
public class LineSDKHexColor: NSObject {
    let _value: HexColor

    public var rawValue: String { return _value.rawValue }
    public var color: UIColor { return _value.color }
    
    init(_ value: HexColor) {
        _value = value
    }
    
    public init(_ color: UIColor) {
        _value = .init(color)
    }
    
    public init(rawValue: String, defaultColor color: UIColor) {
        _value = .init(rawValue: rawValue, default: color)
    }
    
    public func isEqualsToColor(_ another: LineSDKHexColor) -> Bool {
        return _value == another._value
    }
    
    var unwrapped: HexColor { return _value }
}
