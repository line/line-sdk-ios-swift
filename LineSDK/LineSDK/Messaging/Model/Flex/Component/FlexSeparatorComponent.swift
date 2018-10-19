//
//  FlexSeparatorComponent.swift
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
/// Represent a separator component. This component draws a separator between components in the parent box.
/// Different from the `separator` property of `FlexBlockStyle`, the `FlexSeparatorComponent` allows you to add a
/// separator between components instead of container block, as well as full control on separator `margin`.
public struct FlexSeparatorComponent: Codable, FlexMessageComponentTypeCompatible {
    let type: FlexMessageComponentType = .separator
    
    /// Minimum space between this component and the previous component in the parent box.
    /// If not specified, the `spacing` of parent box will be used.
    /// If this component is the first component in the parent box, this margin property will be ignored.
    public var margin: FlexMessageComponent.Margin?
    
    /// Color of the separator.
    public var color: HexColor?
    
    /// Creates a separator component with given information.
    ///
    /// - Parameters:
    ///   - margin: The margin between this component and the previous component in the parent box.
    ///   - color: Color of the separator.
    public init(margin: FlexMessageComponent.Margin?, color: HexColor?) {
        self.margin = margin
        self.color = color
    }
}

extension FlexSeparatorComponent: FlexMessageComponentConvertible {
    /// Returns a converted `FlexMessageComponent` which wraps this `FlexSeparatorComponent`.
    public var component: FlexMessageComponent { return .separator(self) }
}
