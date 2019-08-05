//
//  FlexIconComponent.swift
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

/// LINE internal use only.
/// Represents an icon component. It is used to embed into a baseline layout and its flex is fixed to 0.
public struct FlexIconComponent: Codable, FlexMessageComponentTypeCompatible {
    let type: FlexMessageComponentType = .icon
    
    /// Icon URL. It should start with "https".
    public let url: URL
    
    /// Minimum space between this component and the previous component in the parent box.
    /// If not specified, the `spacing` of parent box will be used.
    /// If this component is the first component in the parent box, this margin property will be ignored.
    public var margin: FlexMessageComponent.Margin?
    
    /// Font size used for the text. You cannot specify a `.full` size. If not specified, `.md` will be used.
    public var size: FlexMessageComponent.Size?
    
    /// Aspect ratio for the image. Width versus height.
    /// You can choose from `.ratio_1x1`, `.ratio_2x1` and `ratio_3x1`. If not specified, `.ratio_1x1` will be used.
    public var aspectRatio: FlexMessageComponent.AspectRatio?
    
    /// Creates an icon component with given information.
    ///
    /// - Parameter url: Icon URL. It should start with "https".
    /// - Throws: An error if something wrong during creating the message. It's usually due to you provided invalid
    ///           parameter.
    public init(url: URL) throws {
        try assertHTTPSScheme(url: url, parameterName: "url")
        self.url = url
    }

    public init(
        url: URL,
        margin: FlexMessageComponent.Margin? = nil,
        size: FlexMessageComponent.Size? = nil,
        aspectRatio: FlexMessageComponent.AspectRatio? = nil) throws
    {
        try assertHTTPSScheme(url: url, parameterName: "url")
        self.url = url
        self.margin = margin
        self.size = size
        self.aspectRatio = aspectRatio
    }
}

extension FlexIconComponent: FlexMessageComponentConvertible {
    /// Returns a converted `FlexMessageComponent` which wraps this `FlexIconComponent`.
    public var component: FlexMessageComponent { return .icon(self) }
}
