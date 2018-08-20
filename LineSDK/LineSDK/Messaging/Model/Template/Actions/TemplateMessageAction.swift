//
//  TemplateMessageAction.swift
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

enum TemplateMessageActionType: String, Codable {
    case URI = "uri"
}

public enum TemplateMessageAction: Codable {
    case URI(TemplateMessageURIAction)
    case unknown
    
    enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try? container.decode(TemplateMessageActionType.self, forKey: .type)
        switch type {
        case .URI?:
            let message = try TemplateMessageURIAction(from: decoder)
            self = .URI(message)
        case nil:
            self = .unknown
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .URI(let action):
            try action.encode(to: encoder)
        default:
            Log.assertionFailure("Cannot encode unknown message type.")
        }
    }
    
    public var asURIAction: TemplateMessageURIAction? {
        if case .URI(let action) = self  { return action }
        return nil
    }
}

public struct TemplateMessageURIAction: Codable, TemplateMessageActionTypeCompatible {
    let type = TemplateMessageActionType.URI
    public let label: String
    public let uri: URL
    
    public init(label: String, uri: URL) {
        self.label = label
        self.uri = uri
    }
}

extension TemplateMessageAction {
    public static func URIAction(label: String, uri: URL) -> TemplateMessageAction {
        let action = TemplateMessageURIAction(label: label, uri: uri)
        return .URI(action)
    }
}
