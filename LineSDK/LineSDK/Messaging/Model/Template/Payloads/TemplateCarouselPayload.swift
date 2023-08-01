//
//  TemplateCarouselPayload.swift
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
/// Represents a template payload with multiple `Column`s which can be cycled like a carousel.
/// The columns will be shown in order by scrolling horizontally.
public struct TemplateCarouselPayload: Codable, TemplateMessagePayloadTypeCompatible {
    
    /// A column of `TemplateCarouselPayload`. It contains a certain title, text, thumbnail image and some actions.
    public struct Column: Codable {
        
        /// Message text of the column.
        public var text: String
        
        /// Message title of the column.
        public var title: String?
        
        /// Actions to perform when tapped.
        public var actions: [MessageAction]
        
        /// Action when image is tapped. Set for the entire image, title, and text area of the column.
        /// To set the `defaultAction` with any `MessageActionConvertible` type, use `setDefaultAction` method.
        public var defaultAction: MessageAction?
        
        /// An image to display in the chat bubble. It should start with "https".
        public var thumbnailImageURL: URL?
        
        /// Background color of image. If not specified, white color will be used.
        public var imageBackgroundColor: HexColor?

        /// Creates a column with given information.
        /// - Parameter title: Message title of the column.
        /// - Parameter text: Message text of the column.
        /// - Parameter actions: Actions to perform when tapped.
        /// - Parameter defaultAction: Action when image is tapped. Set for the entire image, title, and text area of
        ///                            the column. To set the `defaultAction` with any `MessageActionConvertible` type,
        ///                            use `setDefaultAction` method.
        /// - Parameter thumbnailImageURL: An image to display in the chat bubble. It should start with "https".
        /// - Parameter imageBackgroundColor: Background color of image. If not specified, white color will be used.
        public init(
            title: String? = nil,
            text: String,
            actions: [MessageActionConvertible] = [],
            defaultAction: MessageActionConvertible? = nil,
            thumbnailImageURL: URL? = nil,
            imageBackgroundColor: HexColor? = nil
        ) {
            self.text = text
            self.title = title
            self.actions = actions.map { $0.action }
            self.defaultAction = defaultAction?.action
            self.thumbnailImageURL = thumbnailImageURL
            self.imageBackgroundColor = imageBackgroundColor
        }
        
        /// Appends an action to current `actions` list.
        ///
        /// - Parameter action: The action to append.
        public mutating func addAction(_ value: MessageActionConvertible) {
            actions.append(value.action)
        }
        
        /// Set the default action of this payload.
        ///
        /// - Parameter value: The action to set.
        public mutating func setDefaultAction(_ value: MessageActionConvertible?) {
            defaultAction = value?.action
        }
        
        enum CodingKeys: String, CodingKey {
            case text
            case title
            case actions
            case defaultAction
            case thumbnailImageURL = "thumbnailImageUrl"
            case imageBackgroundColor
        }
    }
    
    let type = TemplateMessagePayloadType.carousel
    
    /// Array of columns. You could set at most 10 columns in the payload. Line SDK does not check the elements count
    /// in a payload. However, it would cause an API response error if more columns contained in the payload.
    public var columns: [Column]
    
    /// Aspect ratio of the image. Specify to `.rectangle` or `.square`. If not specified, `.rectangle` will be used.
    public var imageAspectRatio: TemplateMessagePayload.ImageAspectRatio? = nil
    
    /// Size of the image. Specify to `.aspectFill` or `.aspectFit`. If not specified, `.aspectFill` will be used.
    public var imageContentMode: TemplateMessagePayload.ImageContentMode? = nil
    
    /// Creates a carousel payload with given information.
    ///
    /// - Parameter columns: Columns to display in the template message.
    public init(columns: [Column]) {
        self.columns = columns
    }
    
    /// Appends a column to the `columns`.
    ///
    /// - Parameter column: The column to append.
    public mutating func addColumn(_ column: Column) {
        columns.append(column)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case columns
        case imageAspectRatio
        case imageContentMode = "imageSize"
    }
}

extension TemplateCarouselPayload: TemplateMessageConvertible {
    /// Returns a converted `TemplateMessagePayload` which wraps this `TemplateCarouselPayload`.
    public var payload: TemplateMessagePayload { return .carousel(self) }
}
