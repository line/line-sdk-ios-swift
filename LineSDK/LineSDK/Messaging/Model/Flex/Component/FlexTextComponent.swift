//
//  FlexTextComponent.swift
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
/// Represents a text component in a flex message.
/// A text component contains some formatted text. LINE clients will render the text in a flex message.
public struct FlexTextComponent: Codable, FlexMessageComponentTypeCompatible, MessageActionContainer {
    let type = FlexMessageComponentType.text
    
    /// Content text of this component.
    public var text: String
    
    /// The ratio of the width or height of this box within the parent box. The default value for the horizontal parent
    /// box is 1, and the default value for the vertical parent box is 0.
    public var flex: FlexMessageComponent.Ratio?
    
    /// Minimum space between this component and the previous component in the parent box.
    /// If not specified, the `spacing` of parent box will be used.
    /// If this component is the first component in the parent box, this margin property will be ignored.
    public var margin: FlexMessageComponent.Margin?
    
    /// Font size used for the text. You cannot specify a `.full` size. If not specified, `.md` will be used.
    public var size: FlexMessageComponent.Size?
    
    /// Horizontal alignment style. If not specified, `.start` will be used.
    public var alignment: FlexMessageComponent.Alignment?
    
    /// Vertical alignment style. If not specified, `.top` will be used.
    /// If the `layout` property of the parent box is `.baseline`, the `gravity` property will be ignored.
    public var gravity: FlexMessageComponent.Gravity?
    
    /// Whether the text should be wrapped. If not specified, `false` will be used.
    /// If set to true, you can use a new line character ("\n") to begin on a new line.
    public var wrapping: Bool?
    
    /// Max number of lines. If the text does not fit in the specified number of lines, a trailing truncation with
    /// ellipsis (…) is displayed at the end of the last line. If set to `0` or not specified, all the text is
    /// displayed.
    ///
    /// - Note:
    /// This property is supported on the following versions of LINE.
    /// - LINE for iOS and Android: 8.11.0 and later
    /// - LINE for Windows and macOS: 5.9.0 and late
    public var maxLines: UInt?
    
    /// Weight of font used in this component.
    public var weight: FlexMessageComponent.Weight?
    
    /// Color of font used in this component.
    public var color: HexColor?
    
    /// An action to perform when the box tapped.
    /// Use `setAction` method if you want to set a `MessageActionConvertible` as the action of current component.
    public var action: MessageAction?
    
    enum CodingKeys: String, CodingKey {
        case type, text, flex, margin, size, gravity, maxLines, weight, color, action
        case wrapping = "wrap"
        case alignment = "align"
    }

    /// Creates a text component with given information.
    /// - Parameter text: Content text of this component.
    /// - Parameter flex: The ratio of the width or height of this box within the parent box. The default value for
    ///                   the horizontal parent box is 1, and the default value for the vertical parent box is 0.
    /// - Parameter margin: Minimum space between this component and the previous component in the parent box.
    ///                     If not specified, the `spacing` of parent box will be used. If this component is the first
    ///                     component in the parent box, this margin property will be ignored.
    /// - Parameter size: Font size used for the text. You cannot specify a `.full` size. If not specified, `.md`
    ///                   will be used.
    /// - Parameter alignment: Horizontal alignment style. If not specified, `.start` will be used.
    /// - Parameter gravity: Vertical alignment style. If not specified, `.top` will be used.
    ///                      If the `layout` property of the parent box is `.baseline`, the `gravity` property will be
    ///                      ignored.
    /// - Parameter wrapping: Whether the text should be wrapped. If not specified, `false` will be used. If set to
    ///                       true, you can use a new line character ("\n") to begin on a new line.
    /// - Parameter maxLines: Max number of lines.
    /// - Parameter weight: Weight of font used in this component.
    /// - Parameter color: Color of font used in this component.
    /// - Parameter action: An action to perform when the box tapped.
    public init(
        text: String,
        flex: FlexMessageComponent.Ratio? = nil,
        margin: FlexMessageComponent.Margin? = nil,
        size: FlexMessageComponent.Size? = nil,
        alignment: FlexMessageComponent.Alignment? = nil,
        gravity: FlexMessageComponent.Gravity? = nil,
        wrapping: Bool? = nil,
        maxLines: UInt? = nil,
        weight: FlexMessageComponent.Weight? = nil,
        color: HexColor? = nil,
        action: MessageAction? = nil
    )
    {
        self.text = text
        self.flex = flex
        self.margin = margin
        self.size = size
        self.alignment = alignment
        self.gravity = gravity
        self.wrapping = wrapping
        self.maxLines = maxLines
        self.weight = weight
        self.color = color
        self.action = action
    }
}

extension FlexTextComponent: FlexMessageComponentConvertible {
    /// Returns a converted `FlexMessageComponent` which wraps this `FlexTextComponent`.
    public var component: FlexMessageComponent { return .text(self) }
}
