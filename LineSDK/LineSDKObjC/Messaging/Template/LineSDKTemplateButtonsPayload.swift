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

#if !LineSDKCocoaPods && !LineSDKBinary
import LineSDK
#endif

@objcMembers
public class LineSDKTemplateButtonsPayload: LineSDKTemplateMessagePayload {
    
    public var text: String
    public var title: String?
    public var actions: [LineSDKMessageAction]
    public var defaultAction: LineSDKMessageAction?
    public var thumbnailImageURL: URL?
    public var imageAspectRatio: LineSDKTemplateMessagePayloadImageAspectRatio = .none
    public var imageContentMode: LineSDKTemplateMessagePayloadImageContentMode = .none
    public var imageBackgroundColor: LineSDKHexColor?
    public var sender: LineSDKMessageSender?
    
    public init(title: String?, text: String, actions: [LineSDKMessageAction]) {
        self.title = title
        self.text = text
        self.actions = actions
    }
    
    convenience init(_ value: TemplateButtonsPayload) {
        self.init(title: value.title, text: value.text, actions: value.actions.map { $0.wrapped })
        defaultAction = value.defaultAction.map { $0.wrapped }
        thumbnailImageURL = value.thumbnailImageURL
        imageAspectRatio = .init(value.imageAspectRatio)
        imageContentMode = .init(value.imageContentMode)
        imageBackgroundColor = value.imageBackgroundColor.map { .init($0) }
        sender = value.sender.map { .init($0) }
    }

    override var unwrapped: TemplateMessagePayload {
        var payload = TemplateButtonsPayload(title: title, text: text, actions: actions.map { $0.unwrapped })
        payload.defaultAction = defaultAction?.unwrapped
        payload.thumbnailImageURL = thumbnailImageURL
        payload.imageAspectRatio = imageAspectRatio.unwrapped
        payload.imageContentMode = imageContentMode.unwrapped
        payload.imageBackgroundColor = imageBackgroundColor?.unwrapped
        payload.sender = sender?.unwrapped
        
        return .buttons(payload)
    }
}

