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

public struct TemplateCarouselPayload: Codable, TemplateMessagePayloadTypeCompatible {
    
    public struct Column: Codable {
        public var text: String
        public var title: String?
        
        public var actions: [MessageAction]
        public var defaultAction: MessageAction?
        
        public let thumbnailImageURL: URL?
        public var imageBackgroundColor: HexColor?
        
        public init(
            text: String,
            title: String? = nil,
            actions: [MessageAction] = [],
            defaultAction: MessageAction? = nil,
            thumbnailImageURL: URL? = nil,
            imageBackgroundColor: UIColor? = nil)
        {
            self.text = text
            self.title = title
            
            self.actions = actions
            self.defaultAction = defaultAction
            
            self.thumbnailImageURL = thumbnailImageURL
            self.imageBackgroundColor = imageBackgroundColor.map(HexColor.init)
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
    public var columns: [Column]
    public var imageAspectRatio: ImageAspectRatio
    public var imageContentMode: ImageContentMode
    
    public init(
        columns: [Column],
        imageAspectRatio: ImageAspectRatio = .rectangle,
        imageContentMode: ImageContentMode = .aspectFill)
    {
        self.columns = columns
        self.imageAspectRatio = imageAspectRatio
        self.imageContentMode = imageContentMode
    }
    
    public mutating func add(column: Column) {
        columns.append(column)
    }
    
    public mutating func replaceColumn(at index: Int, with column: Column) {
        columns[index] = column
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case columns
        case imageAspectRatio
        case imageContentMode = "imageSize"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        columns = try container.decode([Column].self, forKey: .columns)
        imageAspectRatio = try container.decodeIfPresent(ImageAspectRatio.self, forKey: .imageAspectRatio)
            ?? .rectangle
        imageContentMode = try container.decodeIfPresent(ImageContentMode.self, forKey: .imageContentMode)
            ?? .aspectFill
    }
}

extension Message {
    public static func templateCarouselMessage(
        altText: String,
        columns: [TemplateCarouselPayload.Column],
        imageAspectRatio: ImageAspectRatio = .rectangle,
        imageContentMode: ImageContentMode = .aspectFill) -> Message
    {
        let payload = TemplateCarouselPayload(
            columns: columns,
            imageAspectRatio: imageAspectRatio,
            imageContentMode: imageContentMode)
        let message = TemplateMessage(altText: altText, payload: .carousel(payload))
        return .template(message)
    }
}
