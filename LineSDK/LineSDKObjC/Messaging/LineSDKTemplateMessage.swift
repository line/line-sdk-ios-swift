//
//  LineSDKTemplateMessage.swift
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
public class LineSDKTemplateMessage: LineSDKMessage {

    public var altText: String
    public var payload: LineSDKTemplateMessagePayload
    
    init(_ value: TemplateMessage) {
        altText = value.altText
        payload = .converted(from: value.payload)
    }
    
    public init(altText: String, payload: LineSDKTemplateMessagePayload) {
        self.altText = altText
        self.payload = payload
    }
    
    override func toMessage() -> Message {
        let value = TemplateMessage(altText: altText, payload: payload.toTemplateMessagePayload())
        return .template(value)
    }
}

@objcMembers
public class LineSDKTemplateMessagePayload: NSObject {

    static func converted(from value: TemplateMessagePayload) -> LineSDKTemplateMessagePayload {
        switch value {
        case .buttons(let payload): return LineSDKTemplateButtonsPayload(payload)
        case .confirm(_):
            fatalError()
        case .carousel(_):
            fatalError()
        case .imageCarousel(_):
            fatalError()
        case .unknown:
            Log.fatalError("Cannot create ObjC compatible type for \(value).")
        }
    }
    
    public var buttonsPayload: LineSDKTemplateButtonsPayload? {
        return toTemplateMessagePayload().asButtonsPayload.map { .init($0) }
    }
    
    func toTemplateMessagePayload() -> TemplateMessagePayload {
        Log.fatalError("Not implemented in subclass: \(type(of: self))")
    }
}

@objc
public enum LineSDKTemplateMessagePayloadImageAspectRatio: Int {
    case none
    case rectangle
    case square
    
    var _value: TemplateMessagePayload.ImageAspectRatio? {
        switch self {
        case .none: return nil
        case .rectangle: return .rectangle
        case .square: return .square
        }
    }
    
    init(_ value: TemplateMessagePayload.ImageAspectRatio?) {
        switch value {
        case .rectangle?: self = .rectangle
        case .square?: self = .square
        case nil: self = .none
        }
    }
}

@objc
public enum LineSDKTemplateMessagePayloadImageContentMode: Int {
    case none
    case aspectFill
    case aspectFit
    
    var _value: TemplateMessagePayload.ImageContentMode? {
        switch self {
        case .none: return nil
        case .aspectFill: return .aspectFill
        case .aspectFit: return .aspectFit
        }
    }
    
    init(_ value: TemplateMessagePayload.ImageContentMode?) {
        switch value {
        case .aspectFill?: self = .aspectFill
        case .aspectFit?: self = .aspectFit
        case nil: self = .none
        }
    }
}
