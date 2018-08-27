//
//  LineSDKTemplateCarouselPayload.swift
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
public class LineSDKTemplateCarouselPayloadColumn: NSObject {
    public var text: String
    public var title: String?
    public var actions: [LineSDKMessageAction]
    public var defaultAction: LineSDKMessageAction?
    public var thumbnailImageURL: URL?
    public var imageBackgroundColor: LineSDKHexColor?
    
    public init(title: String?, text: String, actions: [LineSDKMessageAction]) {
        self.title = title
        self.text = text
        self.actions = actions
    }
    
    convenience init(_ value: TemplateCarouselPayload.Column) {
        self.init(title: value.title, text: value.text, actions: value.actions.map { $0.converted })
        defaultAction = value.defaultAction.map { $0.converted }
        thumbnailImageURL = value.thumbnailImageURL
        imageBackgroundColor = value.imageBackgroundColor.map { .init($0) }
    }
    
    public func addAction(_ value: LineSDKMessageAction) {
        actions.append(value)
    }
    
    func toColumn() -> TemplateCarouselPayload.Column {
        var colum = TemplateCarouselPayload.Column(title: title, text: text, actions: actions.map {$0.toAction() })
        colum.defaultAction = defaultAction?.toAction()
        colum.thumbnailImageURL = thumbnailImageURL
        colum.imageBackgroundColor = imageBackgroundColor?._value
        return colum
    }
}

@objcMembers
public class LineSDKTemplateCarouselPayload: LineSDKTemplateMessagePayload {
    
    public var columns: [LineSDKTemplateCarouselPayloadColumn]
    public var imageAspectRatio: LineSDKTemplateMessagePayloadImageAspectRatio = .none
    public var imageContentMode: LineSDKTemplateMessagePayloadImageContentMode = .none
    
    convenience init(_ value: TemplateCarouselPayload) {
        self.init(columns: value.columns.map { .init($0) })
        imageAspectRatio = .init(value.imageAspectRatio)
        imageContentMode = .init(value.imageContentMode)
    }
    
    public init(columns: [LineSDKTemplateCarouselPayloadColumn]) {
        self.columns = columns
    }
    
    override func toTemplateMessagePayload() -> TemplateMessagePayload {
        let payload = TemplateCarouselPayload(columns: columns.map { $0.toColumn() })
        return .carousel(payload)
    }
    
    public func addColumn(_ column: LineSDKTemplateCarouselPayloadColumn) {
        columns.append(column)
    }
}
