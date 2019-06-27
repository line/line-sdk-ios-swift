//
//  VideoMessage.swift
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
/// Represents a message containing an video URL and a preview image URL.
public struct VideoMessage: Codable, MessageTypeCompatible {
    
    let type = MessageType.video
    
    /// Video URL. It should start with "https". A very wide or tall video may be cropped when played in some
    /// environments.
    public let originalContentURL: URL
    
    /// Preview image URL. It should start with "https".
    public let previewImageURL: URL
    
    /// Creates a video message with given information.
    ///
    /// - Parameters:
    ///   - originalContentURL: Video URL. It should start with "https". A very wide or tall video may be cropped when
    ///                         played in some environments.
    ///   - previewImageURL: Preview image URL. It should start with "https".
    /// - Throws: An error if something wrong during creating the message. It's usually due to you provided invalid
    ///           parameter.
    ///
    public init(originalContentURL: URL, previewImageURL: URL) throws {
        try assertHTTPSScheme(url: originalContentURL, parameterName: "originalContentURL")
        try assertHTTPSScheme(url: previewImageURL, parameterName: "previewImageURL")
        
        self.originalContentURL = originalContentURL
        self.previewImageURL = previewImageURL
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case originalContentURL = "originalContentUrl"
        case previewImageURL = "previewImageUrl"
    }
}

extension VideoMessage: MessageConvertible {
    /// Returns a converted `Message` which wraps this `VideoMessage`.
    public var message: Message { return .video(self) }
}
