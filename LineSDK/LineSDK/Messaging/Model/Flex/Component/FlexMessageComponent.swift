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

public enum FlexMessageComponent: Codable {
    case text(FlexTextComponent)
    case button(FlexButtonComponent)
    case image(FlexImageComponent)
    case filler(FlexFillerComponent)
    case icon(FlexIconComponent)
    case separator(FlexSeparatorComponent)
    
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(FlexMessageComponentType.self, forKey: .type)
        switch type {
        case .box?:
            fatalError()
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
        case .spacer?: fatalError()
        case nil: fatalError()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
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
        case .unknown:
            Log.assertionFailure("Cannot encode unknown component type.")
        }
    }
    
    
    public var asTextComponent: FlexTextComponent? {
        if case .text(let component) = self { return component }
        return nil
    }
    
    public var asButtonComponent: FlexButtonComponent? {
        if case .button(let component) = self { return component }
        return nil
    }
    
    public var asImageComponent: FlexImageComponent? {
        if case .image(let component) = self { return component }
        return nil
    }
    
    public var asFillerComponent: FlexFillerComponent? {
        if case .filler(let component) = self { return component }
        return nil
    }
    
    public var asIconComponent: FlexIconComponent? {
        if case .icon(let component) = self { return component }
        return nil
    }
    
    public var asSeparatorComponent: FlexSeparatorComponent? {
        if case .separator(let component) = self { return component }
        return nil
    }
}
