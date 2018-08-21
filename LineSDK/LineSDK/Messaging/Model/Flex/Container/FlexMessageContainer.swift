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

enum FlexMessageContainerType: String, Codable {
    case bubble
    case carousel
}

public enum FlexMessageContainer: Codable {
    case bubble(FlexBubbleContainer)
    case carousel(FlexCarouselContainer)
    
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
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
}
