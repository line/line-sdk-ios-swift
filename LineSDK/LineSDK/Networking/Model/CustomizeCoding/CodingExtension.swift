//
//  CodingExtension.swift
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

import UIKit

extension KeyedDecodingContainer {
    func decodeLoginPermissions(forKey key: Key) throws -> [LoginPermission] {
        let scopes = try decode(String.self, forKey: key)
        return scopes.split(separator: " ").compactMap { scope in
            // Ignore empty permissions
            if scope.trimmingCharacters(in: .whitespaces).isEmpty {
                return nil
            }
            return LoginPermission(rawValue: String(scope))
        }
    }
}

extension KeyedEncodingContainer {
    mutating func encodeLoginPermissions(_ permissions: [LoginPermission], forKey key: Key) throws {
        let scopes = permissions.map { $0.rawValue }.joined(separator: " ")
        try encode(scopes, forKey: key)
    }
}

extension Encodable {
    func toJSON() throws -> Any {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
}

/// A data structure that can be parsed to a `RawRepresentable` type, with a default case to be used if the received
/// data cannot be represented by any value in the type.
public protocol DefaultEnumCodable: RawRepresentable, Codable {
    /// The default value to use when the parsing fails due to the received data not being representable by any value
    /// in the type.
    static var defaultCase: Self { get }
}

/// The default implementation of `DefaultEnumCodable` when the `Self.RawValue` is decodable. It tries to parse a single
/// value in the decoder container and initialize `Self` with the value. If the decoded value is not convertible to
/// `Self`, it will be initialized as the `defaultCase`.
public extension DefaultEnumCodable where Self.RawValue: Decodable {
    /// :nodoc:
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(RawValue.self)
        self = Self.init(rawValue: rawValue) ?? Self.defaultCase
    }
}
