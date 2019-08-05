//
//  FlexButtonComponent.swift
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
/// Represents a button component in a flex message.
/// A button component contains a interactive button. When the user taps the button, a bound action is performed.
public struct FlexButtonComponent: Codable, FlexMessageComponentTypeCompatible {
    
    /// Represents possible styles of a button component.
    ///
    /// - link: HTML link style
    /// - primary: Style for dark color buttons.
    /// - secondary: Style for light color buttons
    public enum Style: String, DefaultEnumCodable {

        /// HTML link style
        case link

        /// Style for dark color buttons.
        case primary

        /// Style for light color buttons
        case secondary

        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.link` will be used.
        public static let defaultCase: FlexButtonComponent.Style = .link
    }
    
    let type = FlexMessageComponentType.button
    
    /// An action to perform when the button tapped.
    /// Use `setAction` method if you want to set a `MessageActionConvertible` as the action of current component.
    public var action: MessageAction
    
    /// The ratio of the width or height of this box within the parent box. The default value for the horizontal parent
    /// box is 1, and the default value for the vertical parent box is 0.
    public var flex: FlexMessageComponent.Ratio?
    
    /// Minimum space between this component and the previous component in the parent box.
    /// If not specified, the `spacing` of parent box will be used.
    /// If this component is the first component in the parent box, this margin property will be ignored.
    public var margin: FlexMessageComponent.Margin?
    
    /// Height of the button.
    public var height: FlexMessageComponent.Height?
    
    /// Styles of the button.
    public var style: Style?
    
    /// Character color when the `style` property is `.link`. Background color when the `style` property is `.primary`
    /// or `.secondary`.
    public var color: HexColor?
    
    /// Vertical alignment style. If not specified, `.top` will be used.
    /// If the `layout` property of the parent box is `.baseline`, the `gravity` property will be ignored.
    public var gravity: FlexMessageComponent.Gravity?

    /// Creates a button component with given information.
    /// - Parameter action: An action to perform when the button tapped.
    /// - Parameter flex: The ratio of the width or height of this box within the parent box. The default value for
    ///                   the horizontal parent box is 1, and the default value for the vertical parent box is 0.
    /// - Parameter margin: Minimum space between this component and the previous component in the parent box.
    /// - Parameter height: Height of the button.
    /// - Parameter style: Styles of the button.
    /// - Parameter color: Character color when the `style` property is `.link`. Background color when the `style`
    ///                    property is `.primary` or `.secondary`.
    /// - Parameter gravity: Vertical alignment style. If not specified, `.top` will be used. If the `layout` property
    ///                      of the parent box is `.baseline`, the `gravity` property will be ignored.
    public init(
        action: MessageActionConvertible,
        flex: FlexMessageComponent.Ratio? = nil,
        margin: FlexMessageComponent.Margin? = nil,
        height: FlexMessageComponent.Height? = nil,
        style: Style? = nil,
        color: HexColor? = nil,
        gravity: FlexMessageComponent.Gravity? = nil
    )
    {
        self.action = action.action
        self.flex = flex
        self.margin = margin
        self.height = height
        self.style = style
        self.color = color
        self.gravity = gravity
    }
}

extension FlexButtonComponent: FlexMessageComponentConvertible {
    /// Returns a converted `FlexMessageComponent` which wraps this `FlexButtonComponent`.
    public var component: FlexMessageComponent { return .button(self) }
}
