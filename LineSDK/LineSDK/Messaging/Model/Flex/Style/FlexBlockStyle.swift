//
//  FlexBlockStyle.swift
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
/// Represents a style for a block in a flex message.
public struct FlexBlockStyle: Codable {
    
    /// Background color of the block. White color will be used if not specified.
    public var backgroundColor: HexColor?
    
    /// Whether a separator should be placed above the block.
    /// The value `true` will be ignored for the first block in a container because you cannot place a separator
    /// above the first block. `false` if not specified.
    public var separator: Bool?
    
    /// Color of the separator. White color will be used if not specified.
    public var separatorColor: HexColor?
    
    /// Creates a block style with given information.
    ///
    /// - Parameters:
    ///   - backgroundColor: Background color of the block. White color will be used if not specified.
    ///   - separator: Whether a separator should be placed above the block.
    ///   - separatorColor: Color of the separator. White color will be used if not specified.
    public init(backgroundColor: HexColor? = nil, separator: Bool? = nil, separatorColor: HexColor? = nil) {
        self.backgroundColor = backgroundColor
        self.separator = separator
        self.separatorColor = separatorColor
    }
}
