//
//  LineSDKFlexBubbleContainer.swift
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
public class LineSDKFlexBubbleContainer: LineSDKFlexMessageContainer {
    
    public var header: LineSDKFlexBoxComponent?
    public var hero: LineSDKFlexImageComponent?
    public var body: LineSDKFlexBoxComponent?
    public var footer: LineSDKFlexBoxComponent?
    
    public var style: LineSDKFlexBubbleContainerStyle?
    public var direction: LineSDKFlexBubbleContainerDirection = .none
    
    public override init() { }
    
    convenience init(_ value: FlexBubbleContainer) {
        self.init()
        header = value.header.map { .init($0) }
        hero = value.hero.map { .init($0) }
        body = value.body.map { .init($0) }
        footer = value.footer.map { .init($0) }
        
        style = value.styles.map { .init($0) }
        direction = .init(value.direction)
    }
    
    override var unwrapped: FlexMessageContainer {
        var container = FlexBubbleContainer(
            header: header?.component,
            hero: hero?.component,
            body: body?.component,
            footer: footer?.component,
            styles: style?.unwrapped)
        container.direction = direction.unwrapped
        return .bubble(container)
    }
    
    var bubble: FlexBubbleContainer {
        return FlexBubbleContainer(header: nil, hero: nil, body: nil, footer: nil, styles: nil)
    }
}

@objcMembers
public class LineSDKFlexBubbleContainerStyle: NSObject {
    public var header: LineSDKFlexBlockStyle?
    public var hero: LineSDKFlexBlockStyle?
    public var body: LineSDKFlexBlockStyle?
    public var footer: LineSDKFlexBlockStyle?
    
    public override init() {}
    public convenience init(_ value: FlexBubbleContainer.Style) {
        self.init()
        self.header = value.header.map { .init($0) }
        self.hero = value.hero.map { .init($0) }
        self.body = value.body.map { .init($0) }
        self.footer = value.footer.map { .init($0) }
    }
    
    var unwrapped: FlexBubbleContainer.Style {
        var style = FlexBubbleContainer.Style()
        style.header = header?.unwrapped
        style.hero = hero?.unwrapped
        style.body = body?.unwrapped
        style.footer = footer?.unwrapped
        return style
    }
}

@objc
public enum LineSDKFlexBubbleContainerDirection: Int {
    case none
    case leftToRight
    case rightToLeft
    
    var unwrapped: FlexBubbleContainer.Direction? {
        switch self {
        case .none: return nil
        case .leftToRight: return .leftToRight
        case .rightToLeft: return .rightToLeft
        }
    }
    
    init(_ value: FlexBubbleContainer.Direction?) {
        switch value {
        case .leftToRight?: self = .leftToRight
        case .rightToLeft?: self = .rightToLeft
        case nil: self = .none
        }
    }
}

@objcMembers
public class LineSDKFlexBlockStyle: NSObject {
    
    public var backgroundColor: LineSDKHexColor?
    public var separator: Bool
    public var separatorColor: LineSDKHexColor?
    
    public init(backgroundColor: LineSDKHexColor?, separator: Bool, separatorColor: LineSDKHexColor?) {
        self.backgroundColor = backgroundColor
        self.separator = separator
        self.separatorColor = separatorColor
    }
    
    public convenience init(_ value: FlexBlockStyle) {
        self.init(
            backgroundColor: value.backgroundColor.map { .init($0) },
            separator: value.separator ?? false,
            separatorColor: value.separatorColor.map { .init($0) })
    }
    
    var unwrapped: FlexBlockStyle {
        return FlexBlockStyle(
            backgroundColor: backgroundColor?.unwrapped,
            separator: separator,
            separatorColor: separatorColor?.unwrapped)
    }
}
