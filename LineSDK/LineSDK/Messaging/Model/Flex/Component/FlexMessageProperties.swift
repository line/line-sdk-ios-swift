//
//  FlexMessageProperties.swift
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

extension FlexMessageComponent {

    /// The ratio (or flex value) of a flex component should take.
    /// For more information, see
    /// https://developers.line.biz/en/docs/messaging-api/flex-message-layout/#component-width-and-height .
    public typealias Ratio = UInt
    
    /// Represents the placement style of components in a box.
    ///
    /// - horizontal: Components are placed horizontally.
    ///               The direction will be determined by `Direction` in the parent level.
    /// - vertical: Components are placed vertically from top to bottom.
    /// - baseline: Components are placed in the same way as horizontal is specified except the baselines of the
    ///             components are aligned.
    ///
    /// For more information, see
    /// https://developers.line.biz/en/docs/messaging-api/flex-message-layout/#box-layout-types .
    public enum Layout: String, DefaultEnumCodable {

        /// Components are placed horizontally.
        /// The direction will be determined by `Direction` in the parent level.
        case horizontal

        /// Components are placed vertically from top to bottom.
        case vertical

        /// Components are placed in the same way as horizontal is specified except the baselines of the
        /// components are aligned.
        case baseline
        
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.vertical` will be used.
        public static let defaultCase: Layout = .vertical
    }
    
    /// Represents a spacing between components in a box.
    public typealias Spacing = Margin
    
    /// Represents a spacing between a component and the previous component in the parent box.
    ///
    /// - none: No spacing between.
    /// - xs: Extra small spacing.
    /// - sm: Small spacing.
    /// - md: Middle spacing.
    /// - lg: Large spacing.
    /// - xl: Extra large spacing.
    /// - xxl: Double extra large spacing.
    public enum Margin: String, DefaultEnumCodable {
        case none, xs, sm, md, lg, xl, xxl
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.none` will be used.
        public static let defaultCase: Margin = .none
    }

    /// Represents a size for some components.
    ///
    /// - xxs: Double extra small size.
    /// - xs: Extra small size.
    /// - sm: Small size.
    /// - md: Middle size.
    /// - lg: Large size.
    /// - xl: Extra large size.
    /// - xxl: Double extra large size.
    /// - xl3: 3xl size.
    /// - xl4: 4xl size.
    /// - xl5: 5xl size.
    /// - full: The full size. 
    public enum Size: String, DefaultEnumCodable {
        case xxs, xs, sm, md, lg, xl, xxl, xl3 = "3xl", xl4 = "4xl", xl5 = "5xl", full
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.md` will be used.
        public static let defaultCase: Size = .md
    }
    
    /// Represents the horizontal alignment of texts or images in component.
    ///
    /// - start: Leading aligned.
    /// - end: Trailing aligned.
    /// - center: Center aligned
    public enum Alignment: String, DefaultEnumCodable {
        case start, end, center
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.start` will be used.
        public static let defaultCase: Alignment = .start
    }
    
    /// Represents the vertical alignment of texts or images in component.
    ///
    /// - top: Top aligned.
    /// - bottom: Bottom aligned.
    /// - center: Center aligned.
    public enum Gravity: String, DefaultEnumCodable {
        case top, bottom, center
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.top` will be used.
        public static let defaultCase: Gravity = .top
    }
    
    /// Represents the font weight used in component.
    ///
    /// - regular: Normal font weight.
    /// - bold: Bold font weight.
    public enum Weight: String, DefaultEnumCodable {
        case regular, bold
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.regular` will be used.
        public static let defaultCase: Weight = .regular
    }
    
    /// Represents the height for a component.
    ///
    /// - sm: Small height.
    /// - md: Middle height.
    public enum Height: String, DefaultEnumCodable {
        case sm, md
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.md` will be used.
        public static let defaultCase: Height = .md
    }
    
    /// Represents aspect ratio for an image in a component. Width versus height.
    ///
    /// - ratio_1x1: Ratio 1:1.
    /// - ratio_1_51x1: Ratio 1.51:1.
    /// - ratio_1_91x1: Ratio 1.91:1.
    /// - ratio_4x3: Ratio 4:3.
    /// - ratio_16x9: Ratio 16:9.
    /// - ratio_20x13: Ratio 20:13.
    /// - ratio_2x1: Ratio 2:1.
    /// - ratio_3x1: Ratio 3:1.
    /// - ratio_3x4: Ratio 3:4.
    /// - ratio_9x16: Ratio 9:16.
    /// - ratio_1x2: Ratio 1:2.
    /// - ratio_1x3: Ratio 1:3.
    public enum AspectRatio: String, DefaultEnumCodable {
        case ratio_1x1 = "1:1"
        case ratio_1_51x1 = "1.51:1"
        case ratio_1_91x1 = "1.91:1"
        case ratio_4x3 = "4:3"
        case ratio_16x9 = "16:9"
        case ratio_20x13 = "20:13"
        case ratio_2x1 = "2:1"
        case ratio_3x1 = "3:1"
        case ratio_3x4 = "3:4"
        case ratio_9x16 = "9:16"
        case ratio_1x2 = "1:2"
        case ratio_1x3 = "1:3"
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.ratio_1x1` will be used.
        public static var defaultCase: AspectRatio = .ratio_1x1
    }
    
    /// Represents aspect scale mode for an image in a component.
    ///
    /// - fill: With "cover" as its raw value. Aspect scales the image to completely fill the image container.
    /// - fit: With "fit" as its raw value. Aspect scales the image to fit inside the image container.
    public enum AspectMode: String, DefaultEnumCodable {
        case fill = "cover"
        case fit = "fit"
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.fit` will be used.
        public static var defaultCase: AspectMode = .fit
    }
}

