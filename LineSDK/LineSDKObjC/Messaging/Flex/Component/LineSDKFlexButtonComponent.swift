//
//  LineSDKFlexButtonComponent.swift
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

@objc
public enum LineSDKFlexButtonComponentStyle: Int {
    case none
    case link
    case primary
    case secondary
    
    var unwrapped: FlexButtonComponent.Style? {
        switch self {
        case .link: return .link
        case .primary: return .primary
        case .secondary: return .secondary
        case .none: return nil
        }
    }
    
    init(_ value: FlexButtonComponent.Style?) {
        switch value {
        case .link?: self = .link
        case .primary?: self = .primary
        case .secondary?: self = .secondary
        case nil: self = .none
        }
    }
}

@objcMembers
public class LineSDKFlexButtonComponent: LineSDKFlexMessageComponent {
    
    public var action: LineSDKMessageAction
    public var flex: NSNumber?
    public var margin: LineSDKFlexMessageComponentMargin = .none
    public var height: LineSDKFlexMessageComponentHeight = .none
    public var style: LineSDKFlexButtonComponentStyle = .none
    public var color: LineSDKHexColor?
    public var gravity: LineSDKFlexMessageComponentGravity = .none
    
    public init(action: LineSDKMessageAction) {
        self.action = action
    }
    
    convenience init(_ value: FlexButtonComponent) {
        self.init(action: value.action.wrapped)
        flex = value.flex.map { .init(value: $0) }
        margin = .init(value.margin)
        height = .init(value.height)
        style = .init(value.style)
        color = value.color.map { .init($0) }
        gravity = .init(value.gravity)
    }
    
    override var unwrapped: FlexMessageComponent {
        var component = FlexButtonComponent(action: action.unwrapped)
        component.flex = flex?.uintValue
        component.margin = margin.unwrapped
        component.height = height.unwrapped
        component.style = style.unwrapped
        component.color = color?.unwrapped
        component.gravity = gravity.unwrapped
        return .button(component)
    }
}
