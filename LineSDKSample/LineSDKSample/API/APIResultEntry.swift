//
//  APIResultEntry.swift
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
import LineSDK

enum APIResultEntry: Comparable {
    
    static func < (lhs: APIResultEntry, rhs: APIResultEntry) -> Bool {
        return lhs.title < rhs.title
    }
    
    case pair(String, String)
    case array(String, [APIResultEntry])
    case nested(String, [APIResultEntry])
    
    init(key: String, value: Any) {
        switch value {
            
        // These will unwrap if an optional value contained in `value`.
        // Feel free to add additional types you need to unwrap before displaying.
        case let v as String:               self = .pair(key, v)
        case let v as URL:                  self = .pair(key, "\(v)")
        case let v as Int:                  self = .pair(key, "\(v)")
        case let v as Double:               self = .pair(key, "\(v)")
        case let v as Date:                 self = .pair(key, "\(v)")
        case let v as Bool:                 self = .pair(key, "\(v)")
        case let v as LoginPermission:      self = .pair(key, "\(v)")
        case let v as MessageSendingStatus: self = .pair(key, "\(v)")
            
        case let v as [Any]:
            let entries = v.enumerated().map { offset, element in
                APIResultEntry(key: "\(key)[\(offset)]", value: element)
            }
            self = .array(key, entries)
            
        case Optional<Any>.none:
            self = .pair(key, "nil")
            
        default:
            self = .nested(key, Mirror.toEntries(value))
        }
    }
    
    var title: String {
        switch self {
        case .pair(let title, _): return title
        case .array(let title, _): return title
        case .nested(let title, _): return title
        }
    }
}

extension Mirror {
    static func toEntries(_ value: Any) -> [APIResultEntry] {
        let mirror = Mirror(reflecting: value)
        return mirror.children
            .map { APIResultEntry(key: $0.label!, value: $0.value) }
            .sorted()
    }
}
