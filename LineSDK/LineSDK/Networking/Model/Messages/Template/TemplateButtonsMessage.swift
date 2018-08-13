//
//  TemplateButtonsMessage.swift
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

public struct TemplateButtonsMessage: Codable, TemplateMessagePayloadTypeCompatible {
    
    public enum ImageAspectRatio: String, Codable {
        case rectangle
        case square
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = ImageAspectRatio(rawValue: rawValue) ?? .rectangle
        }
    }
    
    public enum ImageContentMode: String, Codable {
        case aspectFill = "cover"
        case aspectFit = "contain"
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = ImageContentMode(rawValue: rawValue) ?? .aspectFill
        }
    }
    
    let type = TemplateMessagePayloadType.buttons
    
    public var text: String
    public var title: String?
    
    public var actions: [TemplateMessageAction]
    public var defaultAction: TemplateMessageAction?
    
    public var thumbnailImageURL: URL?
    public var imageAspectRatio: ImageAspectRatio
    public var imageContentMode: ImageContentMode
    public var imageBackgroundColor: UIColor
    
    public var sender: MessageSender?
    
    public init(
        text: String,
        title: String? = nil,
        actions: [TemplateMessageAction] = [],
        defaultAction: TemplateMessageAction? = nil,
        thumbnailImageURL: URL? = nil,
        imageAspectRatio: ImageAspectRatio = .rectangle,
        imageContentMode: ImageContentMode = .aspectFill,
        imageBackgroundColor: UIColor = .white,
        sender: MessageSender? = nil)
    {
        self.text = text
        self.title = title
        
        self.actions = actions
        self.defaultAction = defaultAction
        
        self.thumbnailImageURL = thumbnailImageURL
        self.imageAspectRatio = imageAspectRatio
        self.imageContentMode = imageContentMode
        self.imageBackgroundColor = imageBackgroundColor
    }
    
    mutating func add(action: TemplateMessageAction) {
        actions.append(action)
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case title
        case actions
        case defaultAction
        case thumbnailImageURL = "thumbnailImageUrl"
        case imageAspectRatio
        case imageContentMode = "imageSize"
        case imageBackgroundColor
        case sender = "sentBy"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        text = try container.decode(String.self, forKey: .text)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        
        actions = try container.decode([TemplateMessageAction].self, forKey: .actions)
        defaultAction = try container.decodeIfPresent(TemplateMessageAction.self, forKey: .defaultAction)
        
        thumbnailImageURL = try container.decodeIfPresent(URL.self, forKey: .thumbnailImageURL)
        imageAspectRatio = try container.decodeIfPresent(ImageAspectRatio.self, forKey: .imageAspectRatio)
                                ?? .rectangle
        imageContentMode = try container.decodeIfPresent(ImageContentMode.self, forKey: .imageContentMode)
                                ?? .aspectFill
        
        if let backgroundColorString = try container.decodeIfPresent(String.self, forKey: .imageBackgroundColor) {
            imageBackgroundColor = UIColor(rgb: backgroundColorString)
        } else {
            imageBackgroundColor = .white
        }
        
        sender = try container.decodeIfPresent(MessageSender.self, forKey: .sender)
    }
}
