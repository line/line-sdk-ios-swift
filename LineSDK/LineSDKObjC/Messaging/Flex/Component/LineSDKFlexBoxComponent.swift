//
//  LineSDKFlexBoxComponent.swift
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
public class LineSDKFlexBoxComponent: LineSDKFlexMessageComponent {
    public let layout: LineSDKFlexMessageComponentLayout
    public var contents: [LineSDKFlexMessageComponent]
    public var flex: NSNumber?
    public var spacing: LineSDKFlexMessageComponentSpacing = .none
    public var margin: LineSDKFlexMessageComponentMargin = .none
    public var action: LineSDKMessageAction?
    
    public init(layout: LineSDKFlexMessageComponentLayout, contents: [LineSDKFlexMessageComponent]) {
        self.layout = layout
        self.contents = contents
    }
    
    convenience init(_ value: FlexBoxComponent) {
        self.init(layout: .init(value.layout), contents: value.contents.map { $0.wrapped })
        flex = value.flex.map { .init(value: $0) }
        spacing = .init(value.spacing)
        margin = .init(value.margin)
        action = value.action?.wrapped
    }
    
    public func addComponent(_ value: LineSDKFlexMessageComponent) {
        contents.append(value)
    }
    
    override var unwrapped: FlexMessageComponent {
        return .box(component)
    }
    
    var component: FlexBoxComponent {
        var component = FlexBoxComponent(layout: layout.unwrapped, contents: contents.map { $0.unwrapped })
        component.flex = flex?.uintValue
        component.spacing = spacing.unwrapped
        component.margin = margin.unwrapped
        component.action = action?.unwrapped
        return component
    }
}
