//
//  ImageMessage.swift
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
/// Represents a message containing an image URL and a preview image URL.
public struct ImageMessage: Codable, MessageTypeCompatible {
    
    let type = MessageType.image
    
    /// Image URL. It should start with "https".
    public let originalContentURL: URL

    /// Preview image URL. It should start with "https".
    public let previewImageURL: URL
    
    /// A flag to indicate whether the image in provided `originalContentURL` is animated or not.
    /// You should set it to `true` if the image is an animated one.
    public var animated: Bool?
    
    /// The image file extension. Required if `animated` is set to `true`.
    /// Currently, only "gif" extension is supported and will be rendered as animated image in LINE client.
    public var fileExtension: String?
    
    /// Message agent who sends this message on behalf of the sender.
    public var sender: MessageSender?
    
    /// Creates an image message with given information.
    ///
    /// - Parameters:
    ///   - originalContentURL: Image URL. It should start with "https".
    ///   - previewImageURL: Preview image URL. It should start with "https".
    ///   - animated: A flag to indicate whether the image in provided `originalContentURL` is animated or not.
    ///               You should set it to `true` if the image is an animated one.
    ///   - fileExtension: The image file extension. Required if `animated` is set to `true`.
    ///   - sender: Message agent who sends this message on behalf of the sender.
    /// - Throws: An error if something wrong during creating the message. It's usually due to you provided invalid
    ///           parameter.
    ///
    public init(
        originalContentURL: URL,
        previewImageURL: URL,
        animated: Bool? = nil,
        fileExtension: String? = nil,
        sender: MessageSender? = nil) throws
    {
        try assertHTTPSScheme(url: originalContentURL, parameterName: "originalContentURL")
        try assertHTTPSScheme(url: previewImageURL, parameterName: "previewImageURL")
        
        self.originalContentURL = originalContentURL
        self.previewImageURL = previewImageURL
        self.animated = animated
        self.fileExtension = fileExtension
        self.sender = sender
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case originalContentURL = "originalContentUrl"
        case previewImageURL = "previewImageUrl"
        case animated
        case fileExtension = "extension"
        case sender = "sentBy"
    }
}

extension ImageMessage: MessageConvertible {
    /// Returns a converted `Message` which wraps this `ImageMessage`.
    public var message: Message { return .image(self) }
}
