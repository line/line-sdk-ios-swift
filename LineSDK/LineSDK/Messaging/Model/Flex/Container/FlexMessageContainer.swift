//
//  FlexMessageContainer.swift
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

enum FlexMessageContainerType: String, Codable {
    case bubble
    case carousel
}

/// Represents a flex message container which acts as the content of a `FlexMessage`.
///
/// - bubble: Represents the type of bubble container. A `FlexBubbleContainer` value is associated.
/// - carousel: Represents the type of carousel container. A `FlexCarouselContainer` value is associated.
/// - unknown: A container type is not defined in the LINE SDK yet.
public enum FlexMessageContainer: Codable {

    /// Represents the type of bubble container. A `FlexBubbleContainer` value is associated.
    case bubble(FlexBubbleContainer)

    /// Represents the type of carousel container. A `FlexCarouselContainer` value is associated.
    case carousel(FlexCarouselContainer)

    /// A container type is not defined in the LINE SDK yet.
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    /// Creates a container from decoder.
    ///
    /// - Parameter decoder: The decoder.
    /// - Throws: An error if decoder fails to decode data to destination container type.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(FlexMessageContainerType.self, forKey: .type)
        switch type {
        case .bubble?:
            let value = try FlexBubbleContainer(from: decoder)
            self = .bubble(value)
        case .carousel?:
            let value = try FlexCarouselContainer(from: decoder)
            self = .carousel(value)
        case nil:
            self = .unknown
        }
    }
    
    /// Encodes this `FlexMessageContainer` to an encoder.
    ///
    /// - Parameter encoder: The encoder.
    /// - Throws: An error if it fails to encode data to destination encoder.
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .bubble(let container):
            try container.encode(to: encoder)
        case .carousel(let container):
            try container.encode(to: encoder)
        case .unknown:
            Log.assertionFailure("Cannot encode unknown container type.")
        }
    }
    
    /// Tries to convert current `FlexMessageContainer` to a concrete `FlexBubbleContainer`.
    /// `nil` will be returned if the underlying container is not a `FlexBubbleContainer`.
    public var asBubbleContainer: FlexBubbleContainer? {
        if case .bubble(let container) = self { return container }
        return nil
    }
    
    /// Tries to convert current `FlexMessageContainer` to a concrete `FlexCarouselContainer`.
    /// `nil` will be returned if the underlying container is not a `FlexCarouselContainer`.
    public var asCarouselContainer: FlexCarouselContainer? {
        if case .carousel(let container) = self { return container }
        return nil
    }
    
    public func jsonString() throws -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }
}

extension FlexMessageContainer: FlexMessageConvertible {
    /// Returns `self` for `FlexMessageConvertible` conformation.
    public var container: FlexMessageContainer { return self }
}
