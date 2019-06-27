//
//  TemplateImageCarouselPayload.swift
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
/// Represents a template payload with multiple `Column`s with image which can be cycled like a carousel.
/// The columns with image will be shown in order by scrolling horizontally.
public struct TemplateImageCarouselPayload: Codable, TemplateMessagePayloadTypeCompatible {
    
    /// A column of `TemplateCarouselPayload`. It contains a certain title, text, thumbnail image and some actions.
    public struct Column: Codable, MessageActionContainer {
        
        /// Image URL. It should start with "https".
        public let imageURL: URL
        
        /// An action to perform when image tapped.
        /// Use `setAction` method if you want to set a `MessageActionConvertible` as the action of current payload.
        public var action: MessageAction? = nil
        
        /// Creates a column with given information.
        ///
        /// - Parameters:
        ///   - imageURL: Image URL. It should start with "https".
        ///   - action: An action to perform when image tapped.
        /// - Throws: An error if something wrong during creating the message. It's usually due to you provided invalid
        ///           parameter.
        public init(imageURL: URL, action: MessageActionConvertible?) throws {
            try assertHTTPSScheme(url: imageURL, parameterName: "imageURL")
            self.imageURL = imageURL
            setAction(action)
        }

        enum CodingKeys: String, CodingKey {
            case imageURL = "imageUrl"
            case action
        }
    }
    
    let type = TemplateMessagePayloadType.imageCarousel
    
    /// Array of columns. You could set at most 10 columns in the payload. Line SDK does not check the elements count
    /// in a payload. However, it would cause an API response error if more columns contained in the payload.
    public var columns: [Column]
    
    /// Creates an image carousel payload with given information.
    ///
    /// - Parameter columns: Columns to display in the template message.
    public init (columns: [Column] = []) {
        self.columns = columns
    }
    
    /// Appends a column to the `columns`.
    ///
    /// - Parameter column: The column to append.
    public mutating func addColumn(_ column: Column) {
        columns.append(column)
    }
}

extension TemplateImageCarouselPayload: TemplateMessageConvertible {
    /// Returns a converted `TemplateMessagePayload` which wraps this `TemplateImageCarouselPayload`.
    public var payload: TemplateMessagePayload { return .imageCarousel(self) }
}
