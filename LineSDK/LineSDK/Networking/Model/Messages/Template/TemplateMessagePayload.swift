//
//  TemplateMessagePayload.swift
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

enum TemplateMessagePayloadType: String, Codable {
    case buttons
    case confirm
    case carousel
    case imageCarousel = "image_carousel"
}

public enum TemplateMessagePayload: Codable {
    
    case buttons(TemplateButtonsMessage)
    case confirm(TemplateConfirmMessage)
    
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(TemplateMessagePayloadType.self, forKey: .type)
        switch type {
        case .buttons?:
            let message = try TemplateButtonsMessage(from: decoder)
            self = .buttons(message)
        case .confirm?:
            let message = try TemplateConfirmMessage(from: decoder)
            self = .confirm(message)
        case .carousel?:
            fatalError()
        case .imageCarousel?:
            fatalError()
        case nil:
            self = .unknown
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .buttons(let message):
            try message.encode(to: encoder)
        case .confirm(let message):
            try message.encode(to: encoder)
        default:
            Log.assertionFailure("Cannot encode unknown message type.")
        }
    }
    
    public var asButtonsMessage: TemplateButtonsMessage? {
        if case .buttons(let message) = self { return message }
        return nil
    }
    
    public var asConfirmMessage: TemplateConfirmMessage? {
        if case .confirm(let message) = self { return message }
        return nil
    }
}
