//
//  FlexMessageComponent.swift
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

enum FlexMessageComponentType: String, Codable {
    case box
    case text
    case image
    case button
    case filler
    case icon
    case separator
    case spacer
}

/// Represents a flex message component which acts as a part of a `FlexMessageContainer`.
///
/// - box: Represents the type of box component. A `FlexBoxComponent` value is associated.
/// - text: Represents the type of text component. A `FlexTextComponent` value is associated.
/// - button: Represents the type of button component. A `FlexButtonComponent` value is associated.
/// - image: Represents the type of image component. A `FlexImageComponent` value is associated.
/// - filler: Represents the type of filler component. A `FlexFillerComponent` value is associated.
/// - icon: Represents the type of icon component. A `FlexIconComponent` value is associated.
/// - separator: Represents the type of separator component. A `FlexSeparatorComponent` value is associated.
/// - spacer: Represents the type of spacer component. A `FlexSpacerComponent` value is associated.
/// - unknown: A component type is not defined in the LINE SDK yet.
///
/// For more information, see https://developers.line.biz/en/reference/messaging-api/#component
public enum FlexMessageComponent: Codable {

    /// Represents the type of box component. A `FlexBoxComponent` value is associated.
    case box(FlexBoxComponent)

    /// Represents the type of text component. A `FlexTextComponent` value is associated.
    case text(FlexTextComponent)

    /// Represents the type of button component. A `FlexButtonComponent` value is associated.
    case button(FlexButtonComponent)

    /// Represents the type of image component. A `FlexImageComponent` value is associated.
    case image(FlexImageComponent)

    /// Represents the type of filler component. A `FlexFillerComponent` value is associated.
    case filler(FlexFillerComponent)

    /// Represents the type of icon component. A `FlexIconComponent` value is associated.
    case icon(FlexIconComponent)

    /// Represents the type of separator component. A `FlexSeparatorComponent` value is associated.
    case separator(FlexSeparatorComponent)

    /// Represents the type of spacer component. A `FlexSpacerComponent` value is associated.
    case spacer(FlexSpacerComponent)

    /// A component type is not defined in the LINE SDK yet.
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    /// Creates a container from decoder.
    ///
    /// - Parameter decoder: The decoder.
    /// - Throws: An error if decoder fails to decode data to destination component type.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(FlexMessageComponentType.self, forKey: .type)
        switch type {
        case .box?:
            let component = try FlexBoxComponent(from: decoder)
            self = .box(component)
        case .text?:
            let component = try FlexTextComponent(from: decoder)
            self = .text(component)
        case .button?:
            let component = try FlexButtonComponent(from: decoder)
            self = .button(component)
        case .image?:
            let component = try FlexImageComponent(from: decoder)
            self = .image(component)
        case .filler?:
            let component = try FlexFillerComponent(from: decoder)
            self = .filler(component)
        case .icon?:
            let component = try FlexIconComponent(from: decoder)
            self = .icon(component)
        case .separator?:
            let component = try FlexSeparatorComponent(from: decoder)
            self = .separator(component)
        case .spacer?:
            let component = try FlexSpacerComponent(from: decoder)
            self = .spacer(component)
        case nil:
            self = .unknown
        }
    }
    
    /// Encodes this `FlexMessageComponent` to an encoder.
    ///
    /// - Parameter encoder: The encoder.
    /// - Throws: An error if it fails to encode data to destination encoder.
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .box(let component):
            try component.encode(to: encoder)
        case .text(let component):
            try component.encode(to: encoder)
        case .button(let component):
            try component.encode(to: encoder)
        case .image(let component):
            try component.encode(to: encoder)
        case .filler(let component):
            try component.encode(to: encoder)
        case .icon(let component):
            try component.encode(to: encoder)
        case .separator(let component):
            try component.encode(to: encoder)
        case .spacer(let component):
            try component.encode(to: encoder)
        case .unknown:
            Log.assertionFailure("Cannot encode unknown component type.")
        }
    }
    
    /// Tries to convert current `FlexMessageComponent` to a concrete `FlexBoxComponent`.
    /// `nil` will be returned if the underlying component is not a `FlexBoxComponent`.
    public var asBoxComponent: FlexBoxComponent? {
        if case .box(let component) = self { return component }
        return nil
    }
    
    /// Tries to convert current `FlexMessageComponent` to a concrete `FlexTextComponent`.
    /// `nil` will be returned if the underlying component is not a `FlexTextComponent`.
    public var asTextComponent: FlexTextComponent? {
        if case .text(let component) = self { return component }
        return nil
    }
    
    /// Tries to convert current `FlexMessageComponent` to a concrete `FlexButtonComponent`.
    /// `nil` will be returned if the underlying component is not a `FlexButtonComponent`.
    public var asButtonComponent: FlexButtonComponent? {
        if case .button(let component) = self { return component }
        return nil
    }
    
    /// Tries to convert current `FlexMessageComponent` to a concrete `FlexImageComponent`.
    /// `nil` will be returned if the underlying component is not a `FlexImageComponent`.
    public var asImageComponent: FlexImageComponent? {
        if case .image(let component) = self { return component }
        return nil
    }
    
    /// Tries to convert current `FlexMessageComponent` to a concrete `FlexFillerComponent`.
    /// `nil` will be returned if the underlying component is not a `FlexFillerComponent`.
    public var asFillerComponent: FlexFillerComponent? {
        if case .filler(let component) = self { return component }
        return nil
    }
    
    /// Tries to convert current `FlexMessageComponent` to a concrete `FlexIconComponent`.
    /// `nil` will be returned if the underlying component is not a `FlexIconComponent`.
    public var asIconComponent: FlexIconComponent? {
        if case .icon(let component) = self { return component }
        return nil
    }
    
    /// Tries to convert current `FlexMessageComponent` to a concrete `FlexSeparatorComponent`.
    /// `nil` will be returned if the underlying component is not a `FlexSeparatorComponent`.
    public var asSeparatorComponent: FlexSeparatorComponent? {
        if case .separator(let component) = self { return component }
        return nil
    }
    
    /// Tries to convert current `FlexMessageComponent` to a concrete `FlexSpacerComponent`.
    /// `nil` will be returned if the underlying component is not a `FlexSpacerComponent`.
    public var asSpacerComponent: FlexSpacerComponent? {
        if case .spacer(let component) = self { return component }
        return nil
    }
}

extension FlexMessageComponent: FlexMessageComponentConvertible {
    /// Returns `self` for `FlexMessageComponentConvertible` conformation.
    public var component: FlexMessageComponent { return self }
}
