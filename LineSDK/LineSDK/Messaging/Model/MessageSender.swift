//
//  MessageSender.swift
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
/// Represents a message sender of a certain type of `Message`.
/// - Note: Some message types have footer area which shows the agent information who sends the message on behalf of
///         the sender user. The information includes an icon image, a text label and a link URL to move page when
///         tapped.
public struct MessageSender: Codable {
    
    /// A text label to present some text.
    public var label: String
    
    /// The icon of this sender. It should start with "https".
    public var iconURL: URL
    
    /// The link URL to move page when tapped. It should start with "https" or should be a LINE scheme URL.
    public var linkURL: URL?
    
    /// Creates a message sender from given information.
    ///
    /// - Parameters:
    ///   - label: A text label to present some text.
    ///   - iconURL: The icon of this sender. It should start with "https".
    ///   - linkURL: The link URL to move page when tapped. It should start with "https" or should be a LINE scheme URL.
    public init(label: String, iconURL: URL, linkURL: URL?) {
        self.label = label
        self.iconURL = iconURL
        self.linkURL = linkURL
    }
    
    enum CodingKeys: String, CodingKey {
        case label
        case iconURL = "iconUrl"
        case linkURL = "linkUrl"
    }
}
