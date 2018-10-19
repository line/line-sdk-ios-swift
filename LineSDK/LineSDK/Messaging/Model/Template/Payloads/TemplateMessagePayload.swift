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

/// LINE internal use only.

enum TemplateMessagePayloadType: String, Codable {
    case buttons
    case confirm
    case carousel
    case imageCarousel = "image_carousel"
}

/// Represents a template payload which acts as the content of a `TemplateMessage`.
///
/// - buttons: Represents the type of buttons payload. A `TemplateButtonsPayload` value is associated.
/// - confirm: Represents the type of confirm payload. A `TemplateConfirmPayload` value is associated.
/// - carousel: Represents the type of carousel payload. A `TemplateCarouselPayload` value is associated.
/// - imageCarousel: Represents the type of imageCarousel payload. A `TemplateImageCarouselPayload` value is associated.
/// - unknown: A payload type is not defined in the LINE SDK yet.
public enum TemplateMessagePayload: Codable {

    /// Represents the type of buttons payload. A `TemplateButtonsPayload` value is associated.
    case buttons(TemplateButtonsPayload)

    /// Represents the type of confirm payload. A `TemplateConfirmPayload` value is associated.
    case confirm(TemplateConfirmPayload)

    /// Represents the type of carousel payload. A `TemplateCarouselPayload` value is associated.
    case carousel(TemplateCarouselPayload)

    /// Represents the type of imageCarousel payload. A `TemplateImageCarouselPayload` value is associated.
    case imageCarousel(TemplateImageCarouselPayload)

    /// A payload type is not defined in the LINE SDK yet.
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    /// Creates a payload from decoder.
    ///
    /// - Parameter decoder: The decoder.
    /// - Throws: An error if decoder fails to decode data to destination payload type.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(TemplateMessagePayloadType.self, forKey: .type)
        switch type {
        case .buttons?:
            let message = try TemplateButtonsPayload(from: decoder)
            self = .buttons(message)
        case .confirm?:
            let message = try TemplateConfirmPayload(from: decoder)
            self = .confirm(message)
        case .carousel?:
            let message = try TemplateCarouselPayload(from: decoder)
            self = .carousel(message)
        case .imageCarousel?:
            let message = try TemplateImageCarouselPayload(from: decoder)
            self = .imageCarousel(message)
        case nil:
            self = .unknown
        }
    }
    
    /// Encodes this `TemplateMessagePayload` to an encoder.
    ///
    /// - Parameter encoder: The encoder.
    /// - Throws: An error if it fails to encode data to destination encoder.
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .buttons(let message):
            try message.encode(to: encoder)
        case .confirm(let message):
            try message.encode(to: encoder)
        case .carousel(let message):
            try message.encode(to: encoder)
        case .imageCarousel(let message):
            try message.encode(to: encoder)
        case .unknown:
            Log.assertionFailure("Cannot encode unknown message type.")
        }
    }
    
    /// Tries to convert current `TemplateMessagePayload` to a concrete `TemplateButtonsPayload`.
    /// `nil` will be returned if the underlying payload is not a `TemplateButtonsPayload`.
    public var asButtonsPayload: TemplateButtonsPayload? {
        if case .buttons(let message) = self { return message }
        return nil
    }
    
    /// Tries to convert current `TemplateMessagePayload` to a concrete `TemplateConfirmPayload`.
    /// `nil` will be returned if the underlying payload is not a `TemplateConfirmPayload`.
    public var asConfirmPayload: TemplateConfirmPayload? {
        if case .confirm(let message) = self { return message }
        return nil
    }
    
    /// Tries to convert current `TemplateMessagePayload` to a concrete `TemplateCarouselPayload`.
    /// `nil` will be returned if the underlying payload is not a `TemplateCarouselPayload`.
    public var asCarouselPayload: TemplateCarouselPayload? {
        if case .carousel(let message) = self { return message }
        return nil
    }
    
    /// Tries to convert current `TemplateMessagePayload` to a concrete `TemplateImageCarouselPayload`.
    /// `nil` will be returned if the underlying payload is not a `TemplateImageCarouselPayload`.
    public var asImageCarouselPayload: TemplateImageCarouselPayload? {
        if case .imageCarousel(let message) = self { return message }
        return nil
    }
}

extension TemplateMessagePayload: TemplateMessageConvertible {
    /// Returns `self` for `TemplateMessageConvertible` conformation.
    public var payload: TemplateMessagePayload { return self }
}
