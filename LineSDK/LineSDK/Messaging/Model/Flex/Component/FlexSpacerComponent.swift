//
//  FlexSpacerComponent.swift
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
/// Represents some spacing in a box component.
/// This is an invisible component that places a fixed-size space at the beginning or end of the box.
public struct FlexSpacerComponent: Codable, FlexMessageComponentTypeCompatible {
    let type: FlexMessageComponentType = .spacer
    
    /// Size of the space.
    /// You can specify one from: `[.xs, .sm, .md, .lg, .xl, .xxl]`.
    public var size: FlexMessageComponent.Size?
    
    /// Creates a spacer component with given information.
    ///
    /// - Parameter size: Size of the space.
    ///                   You can specify one from: `[.xs, .sm, .md, .lg, .xl, .xxl]`.
    public init(size: FlexMessageComponent.Size? = nil) {
        self.size = size
    }
}

extension FlexSpacerComponent: FlexMessageComponentConvertible {
/// Returns a converted `FlexMessageComponent` which wraps this `FlexSpacerComponent`.
    public var component: FlexMessageComponent { return .spacer(self) }
}
