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

import Foundation

/// LINE internal use only.
/// Represents a template payload with an image, title, text, and multiple action buttons.
/// The message bubble size is the same with a regular message. It may include an image at most.
public struct TemplateButtonsPayload: Codable, TemplateMessagePayloadTypeCompatible {
    
    let type = TemplateMessagePayloadType.buttons
    
    /// Message text in the chat bubble.
    public var text: String
    
    /// Message title of chat bubble.
    public var title: String?
    
    /// Actions to perform when tapped.
    public var actions: [MessageAction]
    
    /// Action when image is tapped. Set for the entire image, title, and text area of the chat bubble.
    /// To set the `defaultAction` with any `MessageActionConvertible` type, use `setDefaultAction` method.
    public var defaultAction: MessageAction?
    
    /// An image to display in the chat bubble. It should start with "https".
    public var thumbnailImageURL: URL?
    
    /// Aspect ratio of the image. Specify to `.rectangle` or `.square`. If not specified, `.rectangle` will be used.
    public var imageAspectRatio: TemplateMessagePayload.ImageAspectRatio?
    
    /// Size of the image. Specify to `.aspectFill` or `.aspectFit`. If not specified, `.aspectFill` will be used.
    public var imageContentMode: TemplateMessagePayload.ImageContentMode?
    
    /// Background color of image. If not specified, white color will be used.
    public var imageBackgroundColor: HexColor?
    
    /// Message agent who sends this message on behalf of the sender.
    public var sender: MessageSender?

    /// Creates a buttons payload with given information.
    /// - Parameter title: Message title of chat bubble.
    /// - Parameter text: Message text in the chat bubble.
    /// - Parameter defaultAction: Action when image is tapped.
    /// - Parameter thumbnailImageURL: An image to display in the chat bubble. It should start with "https".
    /// - Parameter imageAspectRatio: Aspect ratio of the image. Specify to `.rectangle` or `.square`.
    ///                               If not specified, `.rectangle` will be used.
    /// - Parameter imageContentMode: Size of the image. Specify to `.aspectFill` or `.aspectFit`.
    ///                               If not specified, `.aspectFill` will be used.
    /// - Parameter imageBackgroundColor: Background color of image. If not specified, white color will be used.
    /// - Parameter sender: Message agent who sends this message on behalf of the sender.
    /// - Parameter actions: Actions to perform when tapped. Default is empty.
    public init(
        title: String? = nil,
        text: String,
        defaultAction: MessageAction? = nil,
        thumbnailImageURL: URL? = nil,
        imageAspectRatio: TemplateMessagePayload.ImageAspectRatio? = nil,
        imageContentMode: TemplateMessagePayload.ImageContentMode? = nil,
        imageBackgroundColor: HexColor? = nil,
        sender: MessageSender? = nil,
        actions: [MessageActionConvertible] = []
    )
    {
        self.text = text
        self.title = title
        self.defaultAction = defaultAction
        self.thumbnailImageURL = thumbnailImageURL
        self.imageAspectRatio = imageAspectRatio
        self.imageContentMode = imageContentMode
        self.imageBackgroundColor = imageBackgroundColor
        self.sender = sender
        self.actions = actions.map { $0.action }
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

extension TemplateButtonsPayload: TemplateMessageConvertible {
    /// Returns a converted `TemplateMessagePayload` which wraps this `TemplateButtonsPayload`.
    public var payload: TemplateMessagePayload { return .buttons(self) }
}
