//
//  LineSDKTemplateButtonsPayload.swift
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

import LineSDK

@objcMembers
public class LineSDKTemplateButtonsPayload: LineSDKTemplateMessagePayload {
    
    public var text: String
    public var title: String?
    public var actions: [LineSDKMessageAction]
    public var defaultAction: LineSDKMessageAction?
    public var thumbnailImageURL: URL?
    public var imageAspectRatio: LineSDKTemplateMessagePayloadImageAspectRatio
    public var imageContentMode: LineSDKTemplateMessagePayloadImageContentMode
    public var imageBackgroundColor: LineSDKHexColor?
    public var sender: LineSDKMessageSender?
    
    init(_ value: TemplateButtonsPayload) {
        text = value.text
        title = value.title
        actions = value.actions.map { .converted(from: $0) }
        defaultAction = value.defaultAction.map { .converted(from: $0) }
        thumbnailImageURL = value.thumbnailImageURL
        imageAspectRatio = .init(value.imageAspectRatio)
        imageContentMode = .init(value.imageContentMode)
        imageBackgroundColor = value.imageBackgroundColor.map { .init($0) }
        sender = value.sender.map { .init($0) }
    }
    
    public convenience init(title: String?, text: String, actions: [LineSDKMessageAction]) {
        let payload = TemplateButtonsPayload(title: title, text: text, actions: actions.map { $0.toAction() })
        self.init(payload)
    }
    
    override func toTemplateMessagePayload() -> TemplateMessagePayload {
        var payload = TemplateButtonsPayload(title: title, text: text, actions: actions.map { $0.toAction() })
        payload.defaultAction = defaultAction?.toAction()
        payload.thumbnailImageURL = thumbnailImageURL
        payload.imageAspectRatio = imageAspectRatio._value
        payload.imageContentMode = imageContentMode._value
        payload.imageBackgroundColor = imageBackgroundColor?._value
        payload.sender = sender?._value
        
        return .buttons(payload)
    }
}

