//
//  TemplateMessageProperties.swift
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

extension TemplateMessagePayload {
    
    /// Represents image aspect ratio setting for `TemplateMessagePayload`.
    ///
    /// - rectangle: A ratio of 1.51:1 (width:height), under which the image will be rendered in a wide rectangle
    ///              container.
    /// - square: A ratio of 1:1, under which the image will be rendered in a square container.
    public enum ImageAspectRatio: String, DefaultEnumCodable {
        /// A ratio of 1.51:1 (width:height), under which the image will be rendered in a wide rectangle container.
        case rectangle

        /// A ratio of 1:1, under which the image will be rendered in a square container.
        case square
        
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.rectangle` will be used.
        public static let defaultCase: ImageAspectRatio = .rectangle
    }
    
    /// Represents image content filling mode setting for `TemplateMessagePayload`.
    ///
    /// - aspectFill: With "cover" as its raw value. Aspect scales the image to completely fill the image container.
    /// - aspectFit: With "contain" as its raw value. Aspect scales the image to fit inside the image container.
    public enum ImageContentMode: String, DefaultEnumCodable {
        case aspectFill = "cover"
        case aspectFit = "contain"
        
        /// Default case for this enum. If the raw value cannot be converted to any case when decoding,
        /// `.aspectFill` will be used.
        public static let defaultCase: ImageContentMode = .aspectFill
    }

}
