//
//  HexColor.swift
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

/// Represents a color in hexadecimal notation. This type provides compatibility with the `Codable` protocol
/// for color objects.
public struct HexColor: Codable {
    
    /// The raw string value of the hex color code.
    public let rawValue: String

    /// The `UIColor` representation of the hex color code.
    public let color: UIColor
    
    /// Creates a hex color code from a given `UIColor` value.
    ///
    /// - Parameter color: The color represented by `UIColor`.
    public init(_ color: UIColor) {
        self.color = color
        self.rawValue = color.hexString()
    }
    
    /// Creates a hex color code from a given string. If the string does not represent a valid color, `default` is used.
    ///
    /// - Parameters:
    ///   - rawValue: The raw string representation of the hex color code.
    ///   - default: The fallback color used to create the hex color code when a color cannot be created
    ///              with `rawValue`.
    public init(rawValue: String, default: UIColor) {
        self.color = UIColor(rgb: rawValue, default: `default`)
        self.rawValue = self.color.hexString()
    }
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self.init(rawValue: rawValue, default: .white)
    }

    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// :nodoc:
extension HexColor: Equatable {
    public static func == (lhs: HexColor, rhs: HexColor) -> Bool {
        return lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }
}

/// :nodoc:
extension HexColor: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(rawValue: value, default: .white)
    }
}
