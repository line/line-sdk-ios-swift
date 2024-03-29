//
//  LineSDKTemplateImageCarouselPayload.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

@objcMembers
public class LineSDKTemplateImageCarouselPayloadColumn: NSObject {
    public var imageURL: URL
    public var action: LineSDKMessageAction?
    
    public init?(imageURL: URL, action: LineSDKMessageAction?) {
        do {
            _ = try TemplateImageCarouselPayload.Column(imageURL: imageURL, action: action?.unwrapped)
            self.imageURL = imageURL
            self.action = action
        } catch {
            Log.assertionFailure("An error happened: \(error)")
            return nil
        }
    }
    
    convenience init(_ value: TemplateImageCarouselPayload.Column) {
        self.init(imageURL: value.imageURL, action: value.action?.wrapped)!
    }

    var unwrapped: TemplateImageCarouselPayload.Column {
        return try! TemplateImageCarouselPayload.Column(imageURL: imageURL, action: action?.unwrapped)
    }
}

@objcMembers
public class LineSDKTemplateImageCarouselPayload: LineSDKTemplateMessagePayload {
    public var columns: [LineSDKTemplateImageCarouselPayloadColumn]
    
    convenience init(_ value: TemplateImageCarouselPayload) {
        self.init(columns: value.columns.map { .init($0) })
    }
    
    public init(columns: [LineSDKTemplateImageCarouselPayloadColumn]) {
        self.columns = columns
    }
    
    override var unwrapped: TemplateMessagePayload {
        let payload = TemplateImageCarouselPayload(columns: columns.map { $0.unwrapped })
        return .imageCarousel(payload)
    }
    
    public func addColumn(_ column: LineSDKTemplateImageCarouselPayloadColumn) {
        columns.append(column)
    }
}
