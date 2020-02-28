//
//  LineSDKFlexMessageComponent.swift
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

extension FlexMessageComponent {
    var wrapped: LineSDKFlexMessageComponent {
        switch self {
        case .box(let component): return LineSDKFlexBoxComponent(component)
        case .text(let component): return LineSDKFlexTextComponent(component)
        case .button(let component): return LineSDKFlexButtonComponent(component)
        case .image(let component): return LineSDKFlexImageComponent(component)
        case .filler(let component): return LineSDKFlexFillerComponent(component)
        case .icon(let component): return LineSDKFlexIconComponent(component)
        case .separator(let component): return LineSDKFlexSeparatorComponent(component)
        case .spacer(let component): return LineSDKFlexSpacerComponent(component)
        case .unknown: Log.fatalError("Cannot create ObjC compatible type for \(self).")
        }
    }
}

@objcMembers
public class LineSDKFlexMessageComponent: NSObject {
    
    public var boxComponent: LineSDKFlexBoxComponent? {
        return unwrapped.asBoxComponent.map { .init($0) }
    }
    
    public var textComponent: LineSDKFlexTextComponent? {
        return unwrapped.asTextComponent.map { .init($0) }
    }
    
    public var buttonComponent: LineSDKFlexButtonComponent? {
        return unwrapped.asButtonComponent.map { .init($0) }
    }
    
    public var imageComponent: LineSDKFlexImageComponent? {
        return unwrapped.asImageComponent.map { .init($0) }
    }
    
    public var fillerComponent: LineSDKFlexFillerComponent? {
        return unwrapped.asFillerComponent.map { .init($0) }
    }
    
    public var iconComponent: LineSDKFlexIconComponent? {
        return unwrapped.asIconComponent.map { .init($0) }
    }
    
    public var separatorComponent: LineSDKFlexSeparatorComponent? {
        return unwrapped.asSeparatorComponent.map { .init($0) }
    }
    
    public var spacerComponent: LineSDKFlexSpacerComponent? {
        return unwrapped.asSpacerComponent.map { .init($0) }
    }
    
    var unwrapped: FlexMessageComponent {
        Log.fatalError("Not implemented in subclass: \(type(of: self))")
    }
}

@objc
public enum LineSDKFlexMessageComponentLayout: Int {
    case horizontal, vertical, baseline
    var unwrapped: FlexMessageComponent.Layout {
        switch self {
        case .horizontal: return .horizontal
        case .vertical: return .vertical
        case .baseline: return .baseline
        }
    }
    
    init(_ value: FlexMessageComponent.Layout) {
        switch value {
        case .horizontal: self = .horizontal
        case .vertical: self = .vertical
        case .baseline: self = .baseline
        }
    }
}

@objc
public enum LineSDKFlexMessageComponentSpacing: Int {
    case none, xs, sm, md, lg, xl, xxl
    var unwrapped: FlexMessageComponent.Margin? {
        switch self {
        case .xs: return .xs
        case .sm: return .sm
        case .md: return .md
        case .lg: return .lg
        case .xl: return .xl
        case .xxl: return .xxl
        case .none: return nil
        }
    }
    
    init(_ value: FlexMessageComponent.Margin?) {
        switch value {
        case .none?: self = .none
        case .xs?: self = .xs
        case .sm?: self = .sm
        case .md?: self = .md
        case .lg?: self = .lg
        case .xl?: self = .xl
        case .xxl?: self = .xxl
        case nil: self = .none
        }
    }
}

@objc
public enum LineSDKFlexMessageComponentMargin: Int {
    case none, xs, sm, md, lg, xl, xxl
    var unwrapped: FlexMessageComponent.Margin? {
        switch self {
        case .xs: return .xs
        case .sm: return .sm
        case .md: return .md
        case .lg: return .lg
        case .xl: return .xl
        case .xxl: return .xxl
        case .none: return nil
        }
    }
    
    init(_ value: FlexMessageComponent.Margin?) {
        switch value {
        case .none?: self = .none
        case .xs?: self = .xs
        case .sm?: self = .sm
        case .md?: self = .md
        case .lg?: self = .lg
        case .xl?: self = .xl
        case .xxl?: self = .xxl
        case nil: self = .none
        }
    }
}

@objc
public enum LineSDKFlexMessageComponentSize: Int {
    case none, xxs, xs, sm, md, lg, xl, xxl, xl3, xl4, xl5, full
    var unwrapped: FlexMessageComponent.Size? {
        switch self {
        case .xxs: return .xxs
        case .xs: return .xs
        case .sm: return .sm
        case .md: return .md
        case .lg: return .lg
        case .xl: return .xl
        case .xxl: return .xxl
        case .xl3: return .xl3
        case .xl4: return .xl4
        case .xl5: return .xl5
        case .full: return .full
        case .none: return nil
        }
    }
    
    init(_ value: FlexMessageComponent.Size?) {
        switch value {
        case .xxs?: self = .xxs
        case .xs?: self = .xs
        case .sm?: self = .sm
        case .md?: self = .md
        case .lg?: self = .lg
        case .xl?: self = .xl
        case .xxl?: self = .xxl
        case .xl3?: self = .xl3
        case .xl4?: self = .xl4
        case .xl5?: self = .xl5
        case .full?: self = .full
        case nil: self = .none
        }
    }
}

@objc
public enum LineSDKFlexMessageComponentAlignment: Int {
    case none, start, end, center
    var unwrapped: FlexMessageComponent.Alignment? {
        switch self {
        case .start: return .start
        case .end: return .end
        case .center: return .center
        case .none: return nil
        }
    }
    
    init(_ value: FlexMessageComponent.Alignment?) {
        switch value {
        case .start?: self = .start
        case .end?: self = .end
        case .center?: self = .center
        case nil: self = .none
        }
    }
}

@objc
public enum LineSDKFlexMessageComponentGravity: Int {
    case none, top, bottom, center
    var unwrapped: FlexMessageComponent.Gravity? {
        switch self {
        case .top: return .top
        case .bottom: return .bottom
        case .center: return .center
        case .none: return nil
        }
    }
    
    init(_ value: FlexMessageComponent.Gravity?) {
        switch value {
        case .top?: self = .top
        case .bottom?: self = .bottom
        case .center?: self = .center
        case nil: self = .none
        }
    }
}

@objc
public enum LineSDKFlexMessageComponentWeight: Int {
    case none, regular, bold
    var unwrapped: FlexMessageComponent.Weight? {
        switch self {
        case .regular: return .regular
        case .bold: return .bold
        case .none: return nil
        }
    }
    
    init(_ value: FlexMessageComponent.Weight?) {
        switch value {
        case .regular?: self = .regular
        case .bold?: self = .bold
        case nil: self = .none
        }
    }
}

@objc
public enum LineSDKFlexMessageComponentHeight: Int {
    case none, sm, md
    var unwrapped: FlexMessageComponent.Height? {
        switch self {
        case .sm: return .sm
        case .md: return .md
        case .none: return nil
        }
    }
    
    init(_ value: FlexMessageComponent.Height?) {
        switch value {
        case .sm?: self = .sm
        case .md?: self = .md
        case nil: self = .none
        }
    }
}

@objc
public enum LineSDKFlexMessageComponentAspectRatio: Int {
    case none, ratio_1x1, ratio_1_51x1, ratio_1_91x1, ratio_4x3, ratio_16x9, ratio_20x13, ratio_2x1,
    ratio_3x1, ratio_3x4, ratio_9x16, ratio_1x2, ratio_1x3

    var unwrapped: FlexMessageComponent.AspectRatio? {
        switch self {        
        case .ratio_1x1: return .ratio_1x1
        case .ratio_1_51x1: return .ratio_1_51x1
        case .ratio_1_91x1: return .ratio_1_91x1
        case .ratio_4x3: return .ratio_4x3
        case .ratio_16x9: return .ratio_16x9
        case .ratio_20x13: return .ratio_20x13
        case .ratio_2x1: return .ratio_2x1
        case .ratio_3x1: return .ratio_3x1
        case .ratio_3x4: return .ratio_3x4
        case .ratio_9x16: return .ratio_9x16
        case .ratio_1x2: return .ratio_1x2
        case .ratio_1x3: return .ratio_1x3
        case .none: return nil
        }
    }
    
    init(_ value: FlexMessageComponent.AspectRatio?) {
        switch value {
        case .ratio_1x1?: self = .ratio_1x1
        case .ratio_1_51x1?: self = .ratio_1_51x1
        case .ratio_1_91x1?: self = .ratio_1_91x1
        case .ratio_4x3?: self = .ratio_4x3
        case .ratio_16x9?: self = .ratio_16x9
        case .ratio_20x13?: self = .ratio_20x13
        case .ratio_2x1?: self = .ratio_2x1
        case .ratio_3x1?: self = .ratio_3x1
        case .ratio_3x4?: self = .ratio_3x4
        case .ratio_9x16?: self = .ratio_9x16
        case .ratio_1x2?: self = .ratio_1x2
        case .ratio_1x3?: self = .ratio_1x3
        case nil: self = .none
        }
    }
}

@objc
public enum LineSDKFlexMessageComponentAspectMode: Int {
    case none, fill, fit
    var unwrapped: FlexMessageComponent.AspectMode? {
        switch self {
        case .fill: return .fill
        case .fit: return .fit
        case .none: return nil
        }
    }
    
    init(_ value: FlexMessageComponent.AspectMode?) {
        switch value {
        case .fill?: self = .fill
        case .fit?: self = .fit
        case nil: self = .none
        }
    }
}
