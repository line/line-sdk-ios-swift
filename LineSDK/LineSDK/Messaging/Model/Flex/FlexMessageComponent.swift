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
    
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(FlexMessageComponentType.self, forKey: .type)
        switch type {
        case .text?:
            let compoenent = try FlexTextComponent(from: decoder)
            self = .text(compoenent)
        default: fatalError()
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .text(let compoenent):
            try compoenent.encode(to: encoder)
        case .unknown:
            Log.assertionFailure("Cannot encode unknown component type.")
        }
    }
}
