//
//  FlexImageComponent.swift
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

import Foundation

/// LINE internal use only.
/// Represents an image component in a flex message.
public struct FlexImageComponent: Codable, FlexMessageComponentTypeCompatible, MessageActionContainer {
    let type: FlexMessageComponentType = .image
    
    /// Image URL. It should start with "https".
    public let url: URL
    
    /// The ratio of the width or height of this box within the parent box. The default value for the horizontal parent
    /// box is 1, and the default value for the vertical parent box is 0.
    public var flex: FlexMessageComponent.Ratio?
    
    /// Minimum space between this component and the previous component in the parent box.
    /// If not specified, the `spacing` of parent box will be used.
    /// If this component is the first component in the parent box, this margin property will be ignored.
    public var margin: FlexMessageComponent.Margin?
    
    /// Horizontal alignment style. If not specified, `.start` will be used.
    public var alignment: FlexMessageComponent.Alignment?
    
    /// Vertical alignment style. If not specified, `.top` will be used.
    /// If the `layout` property of the parent box is `.baseline`, the `gravity` property will be ignored.
    public var gravity: FlexMessageComponent.Gravity?
    
    /// Maximum size of the image width. If not specified, `.md` will be used.
    public var size: FlexMessageComponent.Size?
    
    /// Aspect ratio for the image. Width versus height. If not specified, `.ratio_1x1` will be used.
    public var aspectRatio: FlexMessageComponent.AspectRatio?
    
    /// Aspect scaling mode for the image. If not specified, `.fit` will be used.
    public var aspectMode: FlexMessageComponent.AspectMode?
    
    /// Background color of the image.
    public var backgroundColor: HexColor?
    
    /// An action to perform when the box tapped.
    public var action: MessageAction?
    
    enum CodingKeys: String, CodingKey {
        case type, url, flex, margin, gravity, size, aspectRatio, aspectMode, backgroundColor, action
        case alignment = "align"
    }

    /// Creates an image component with given information.
    /// - Parameter url: Image URL. It should start with "https".
    /// - Parameter flex: The ratio of the width or height of this box within the parent box. The default value for
    ///                   the horizontal parent box is 1, and the default value for the vertical parent box is 0.
    /// - Parameter margin: Minimum space between this component and the previous component in the parent box.
    /// - Parameter alignment: Horizontal alignment style. If not specified, `.start` will be used.
    /// - Parameter gravity: Vertical alignment style. If not specified, `.top` will be used. If the `layout` property
    ///                      of the parent box is `.baseline`, the `gravity` property will be ignored.
    /// - Parameter size: Maximum size of the image width. If not specified, `.md` will be used.
    /// - Parameter aspectRatio: Aspect ratio for the image. Width versus height. If not specified, `.ratio_1x1` will be used.
    /// - Parameter aspectMode: Aspect scaling mode for the image. If not specified, `.fit` will be used.
    /// - Parameter backgroundColor: Background color of the image.
    /// - Parameter action: An action to perform when the box tapped.
    ///
    /// - Throws: An error if something wrong during creating the message. It's usually due to you provided invalid
    ///           parameter.
    public init(
        url: URL,
        flex: FlexMessageComponent.Ratio? = nil,
        margin: FlexMessageComponent.Margin? = nil,
        alignment: FlexMessageComponent.Alignment? = nil,
        gravity: FlexMessageComponent.Gravity? = nil,
        size: FlexMessageComponent.Size? = nil,
        aspectRatio: FlexMessageComponent.AspectRatio? = nil,
        aspectMode: FlexMessageComponent.AspectMode? = nil,
        backgroundColor: HexColor? = nil,
        action: MessageActionConvertible? = nil
    ) throws
    {
        try assertHTTPSScheme(url: url, parameterName: "url")
        self.url = url
        self.flex = flex
        self.margin = margin
        self.alignment = alignment
        self.gravity = gravity
        self.size = size
        self.aspectRatio = aspectRatio
        self.aspectMode = aspectMode
        self.backgroundColor = backgroundColor
        self.action = action?.action
    }
}

extension FlexImageComponent: FlexMessageComponentConvertible {
    /// Returns a converted `FlexMessageComponent` which wraps this `FlexImageComponent`.
    public var component: FlexMessageComponent { return .image(self) }
}
