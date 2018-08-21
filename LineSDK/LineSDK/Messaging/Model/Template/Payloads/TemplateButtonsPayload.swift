//
//  TemplateButtonsPayload.swift
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

public struct TemplateButtonsPayload: Codable, TemplateMessagePayloadTypeCompatible {
    
    let type = TemplateMessagePayloadType.buttons
    
    public var text: String
    public var title: String?
    
    public var actions: [MessageAction]
    public var defaultAction: MessageAction?
    
    public var thumbnailImageURL: URL?
    public var imageAspectRatio: ImageAspectRatio?
    public var imageContentMode: ImageContentMode?
    public var imageBackgroundColor: HexColor?
    
    public var sender: MessageSender?
    
    public init(
        text: String,
        title: String? = nil,
        actions: [MessageAction] = [],
        defaultAction: MessageAction? = nil,
        thumbnailImageURL: URL? = nil,
        imageAspectRatio: ImageAspectRatio? = nil,
        imageContentMode: ImageContentMode? = nil,
        imageBackgroundColor: UIColor? = nil,
        sender: MessageSender? = nil)
    {
        self.text = text
        self.title = title
        
        self.actions = actions
        self.defaultAction = defaultAction
        
        self.thumbnailImageURL = thumbnailImageURL
        self.imageAspectRatio = imageAspectRatio
        self.imageContentMode = imageContentMode
        self.imageBackgroundColor = imageBackgroundColor.map(HexColor.init)
    }
    
    public mutating func add(action: MessageAction) {
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
}

extension TemplateButtonsPayload {
    public var payload: TemplateMessagePayload { return .buttons(self) }
}

extension Message {
    public static func templateButtonsMessage(
        altText: String,
        text: String,
        title: String? = nil,
        actions: [MessageAction] = [],
        defaultAction: MessageAction? = nil,
        thumbnailImageURL: URL? = nil,
        imageAspectRatio: ImageAspectRatio? = nil,
        imageContentMode: ImageContentMode? = nil,
        imageBackgroundColor: UIColor? = nil,
        sender: MessageSender? = nil) -> Message
    {
        let payload = TemplateButtonsPayload(
            text: text,
            title: title,
            actions: actions,
            defaultAction: defaultAction,
            thumbnailImageURL: thumbnailImageURL,
            imageAspectRatio: imageAspectRatio,
            imageContentMode: imageContentMode,
            imageBackgroundColor: imageBackgroundColor,
            sender: sender).payload
        return payload.messageWithAltText(altText)
    }
}
