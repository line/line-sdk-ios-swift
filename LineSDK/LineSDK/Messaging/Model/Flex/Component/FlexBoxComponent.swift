//
//  FlexBoxComponent.swift
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

/// LINE internal use only.
/// Represents a box component in a flex message.
/// A box component behave as a container of other components. It defines the layout of its child components.
/// You can also include a nested box in a box.
public struct FlexBoxComponent: Codable, FlexMessageComponentTypeCompatible, MessageActionContainer {
    let type: FlexMessageComponentType = .box
    
    /// The placement style of components in this box.
    public let layout: FlexMessageComponent.Layout
    
    /// Components in this box.
    ///
    /// When the `layout` is `.horizontal` or `.vertical`, the following components are supported as nested:
    ///   - `FlexBoxComponent`
    ///   - `FlexTextComponent`
    ///   - `FlexImageComponent`
    ///   - `FlexButtonComponent`
    ///   - `FlexFillerComponent`
    ///   - `FlexSeparatorComponent`
    ///   - `FlexSpacerComponent`
    ///
    /// When the `layout` is `.baseline`, the following components are supported as nested::
    ///   - `FlexTextComponent`
    ///   - `FlexFillerComponent`
    ///   - `FlexIconComponent`
    ///   - `FlexSpacerComponent`
    ///
    /// LineSDK does not check the validation of contents for a certain layout. However, it might cause a response error
    /// if you try to send a message with invalid component `contents`
    public var contents: [FlexMessageComponent]
    
    /// The ratio of the width or height of this box within the parent box. The default value for the horizontal parent
    /// box is 1, and the default value for the vertical parent box is 0.
    public var flex: FlexMessageComponent.Ratio?
    
    /// Minimum space between components in this box. If not specified, `.none` will be used.
    public var spacing: FlexMessageComponent.Spacing?
    
    /// Minimum space between this box and the previous component in the parent box.
    /// If not specified, the `spacing` of parent box will be used.
    /// If this box is the first component in the parent box, this margin property will be ignored.
    public var margin: FlexMessageComponent.Margin?
    
    /// An action to perform when the box tapped.
    /// Use `setAction` method if you want to set a `MessageActionConvertible` as the action of current component.
    ///
    /// - Note:
    /// This property is supported on the following versions of LINE:
    ///    - LINE for iOS and Android: 8.11.0 and later
    ///    - LINE for Windows and macOS: 5.9.0 and later
    public var action: MessageAction?
    
    /// Creates a box component with given information.
    ///
    /// - Parameters:
    ///   - layout: The placement style of components in this box.
    ///   - contents: Components in this box.
    ///
    /// - Note:
    /// When the `layout` is `.horizontal` or `.vertical`, the following components are supported as nested:
    ///   - `FlexBoxComponent`
    ///   - `FlexTextComponent`
    ///   - `FlexImageComponent`
    ///   - `FlexButtonComponent`
    ///   - `FlexFillerComponent`
    ///   - `FlexSeparatorComponent`
    ///   - `FlexSpacerComponent`
    ///
    /// When the `layout` is `.baseline`, the following components are supported as nested::
    ///   - `FlexTextComponent`
    ///   - `FlexFillerComponent`
    ///   - `FlexIconComponent`
    ///   - `FlexSpacerComponent`
    ///
    /// LineSDK does not check the validation of contents for a certain layout. However, it might cause a response error
    /// if you try to send a message with invalid component `contents`
    ///
    public init(layout: FlexMessageComponent.Layout, contents: [FlexMessageComponentConvertible] = []) {
        self.layout = layout
        self.contents = contents.map { $0.component }
    }

    public init(
        layout: FlexMessageComponent.Layout,
        flex: FlexMessageComponent.Ratio? = nil,
        spacing: FlexMessageComponent.Spacing? = nil,
        margin: FlexMessageComponent.Margin? = nil,
        action: MessageAction? = nil,
        contents: (() -> [FlexMessageComponentConvertible])
    )
    {
        self.layout = layout
        self.flex = flex
        self.spacing = spacing
        self.margin = margin
        self.action = action
        self.contents = contents().map { $0.component }
    }
    
    /// Appends a component to current `contents`.
    ///
    /// - Parameter value: The component to append.
    public mutating func addComponent(_ value: FlexMessageComponentConvertible) {
        contents.append(value.component)
    }
    
    /// Removes the first component from `contents` which meets the given `condition`.
    ///
    /// - Parameter condition: A closure that takes an element as its argument and returns a `Bool` value that
    ///                        indicates whether the passed element represents a match.
    /// - Returns: The element which was removed, or `nil` if matched element not found.
    /// - Throws: Rethrows the `condition` block error.
    public mutating func removeFisrtComponent(
        where condition: (FlexMessageComponent) throws -> Bool) rethrows -> FlexMessageComponent?
    {
        #if swift(>=5.0)
        guard let index = try contents.firstIndex(where: condition) else {
            return nil
        }
        #else
        guard let index = try contents.index(where: condition) else {
            return nil
        }
        #endif
        
        return contents.remove(at: index)
    }
}

extension FlexBoxComponent: FlexMessageComponentConvertible {
    /// Returns a converted `FlexMessageComponent` which wraps this `FlexBoxComponent`.
    public var component: FlexMessageComponent { return .box(self) }
}
