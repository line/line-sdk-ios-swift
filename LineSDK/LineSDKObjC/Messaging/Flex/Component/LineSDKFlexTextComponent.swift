//
//  LineSDKFlexTextComponent.swift
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
public class LineSDKFlexTextComponent: LineSDKFlexMessageComponent {
    
    public var text: String
    public var flex: NSNumber?
    public var margin: LineSDKFlexMessageComponentMargin = .none
    public var size: LineSDKFlexMessageComponentSize = .none
    public var alignment: LineSDKFlexMessageComponentAlignment = .none
    public var gravity: LineSDKFlexMessageComponentGravity = .none
    public var wrapping: Bool = false
    public var maxLines: NSNumber?
    public var weight: LineSDKFlexMessageComponentWeight = .none
    public var color: LineSDKHexColor?
    public var action: LineSDKMessageAction?
    
    
    public init(text: String) {
        self.text = text
    }
    
    convenience init(_ value: FlexTextComponent) {
        self.init(text: value.text)
        flex = value.flex.map { .init(value: $0) }
        margin = .init(value.margin)
        size = .init(value.size)
        alignment = .init(value.alignment)
        gravity = .init(value.gravity)
        wrapping = value.wrapping ?? false
        maxLines = value.maxLines.map { .init(value: $0) }
        weight = .init(value.weight)
        color = value.color.map { .init($0) }
        action = value.action.map { $0.wrapped }
    }
    
    override var unwrapped: FlexMessageComponent {
        var component = FlexTextComponent(text: text)
        component.flex = flex?.uintValue
        component.margin = margin.unwrapped
        component.size = size.unwrapped
        component.alignment = alignment.unwrapped
        component.gravity = gravity.unwrapped
        component.wrapping = wrapping
        component.maxLines = maxLines?.uintValue
        component.weight = weight.unwrapped
        component.color = color?.unwrapped
        component.action = action?.unwrapped
        return .text(component)
    }
}
