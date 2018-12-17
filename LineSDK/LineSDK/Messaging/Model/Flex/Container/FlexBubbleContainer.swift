//
//  FlexBubbleContainer.swift
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
/// Represents a container that contains one message bubble. It can contain four blocks: header, hero, body, and
/// footer. These blocks, which could contain nested components, will follow some given `styles` to construct the
/// flexible layout.
///
public struct FlexBubbleContainer: Codable, FlexMessageContainerTypeCompatible {
    
    /// The style used for a bubble container.
    public struct Style: Codable {
        
        /// Style of the header block.
        public var header: FlexBlockStyle?
        
        /// Style of the hero block.
        public var hero: FlexBlockStyle?
        
        /// Style of the body block.
        public var body: FlexBlockStyle?
        
        /// Style of the footer block.
        public var footer: FlexBlockStyle?
        
        /// Creates an empty style value for editing.
        public init() {}
    }
    
    /// Represents the text direction inside a bubble.
    ///
    /// - leftToRight: The text should be from left to right.
    /// - rightToLeft: The text should be from right to left.
    public enum Direction: String, DefaultEnumCodable {
        /// The text should be from left to right.
        case leftToRight = "ltr"

        /// The text should be from right to left.
        case rightToLeft = "rtl"
        
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.leftToRight` will be used.
        public static let defaultCase: Direction = .leftToRight
    }
    
    let type = FlexMessageContainerType.bubble
    
    /// The header block. Header section of the bubble. This block is a `FlexBoxComponent` and could contains
    /// arbitrary nested components.
    public var header: FlexBoxComponent?
    
    /// The hero block. Hero block is a `FlexImageComponent` which show an image inside the bubble.
    public var hero: FlexImageComponent?
    
    /// The body block. Main content of the bubble. This block is a `FlexBoxComponent` and could contains
    /// arbitrary nested components.
    public var body: FlexBoxComponent?
    
    /// The footer block. Footer section of the bubble. This block is a `FlexBoxComponent` and could contains
    /// arbitrary nested components.
    public var footer: FlexBoxComponent?
    
    /// The styles used for this bubble container.
    public var styles: Style?
    
    /// Text directionality and the order of components in horizontal boxes in the container.
    /// If not specified, `.leftToRight` will be used.
    public var direction: Direction?
    
    /// Creates a bubble container with given information.
    ///
    /// - Parameters:
    ///   - header: The header block. Header section of the bubble. This block is a `FlexBoxComponent` and could
    ///             contains arbitrary nested components.
    ///   - hero: The hero block. Hero block is a `FlexImageComponent` which show an image inside the bubble.
    ///   - body: The body block. Main content of the bubble. This block is a `FlexBoxComponent` and could contains
    ///           arbitrary nested components.
    ///   - footer: The footer block. Footer section of the bubble. This block is a `FlexBoxComponent` and could contains
    ///             arbitrary nested components.
    ///   - styles: The styles used for this bubble container.
    public init(
        header: FlexBoxComponent? = nil,
        hero: FlexImageComponent? = nil,
        body: FlexBoxComponent? = nil,
        footer: FlexBoxComponent? = nil,
        styles: Style? = nil)
    {
        self.header = header
        self.hero = hero
        self.body = body
        self.footer = footer
        self.styles = styles
    }
}

extension FlexBubbleContainer: FlexMessageConvertible {
    /// Returns a converted `FlexMessageContainer` which wraps this `FlexBubbleContainer`.
    public var container: FlexMessageContainer { return .bubble(self) }
}
