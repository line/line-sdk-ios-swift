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

public struct ImageMessage: Codable, MessageTypeCompatible {
    
    let type = MessageType.image
    
    public let originalContentURL: URL
    public let previewImageURL: URL
    public let animated: Bool?
    public let `extension`: String?
    public let sender: MessageSender?
    
    public init(
        originalContentURL: URL,
        previewImageURL: URL,
        animated: Bool? = nil,
        extension: String? = nil,
        sender: MessageSender? = nil) throws
    {
        try assertHTTPSScheme(url: originalContentURL, parameterName: "originalContentURL")
        try assertHTTPSScheme(url: previewImageURL, parameterName: "previewImageURL")
        
        self.originalContentURL = originalContentURL
        self.previewImageURL = previewImageURL
        self.animated = animated
        self.extension = `extension`
        self.sender = sender
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case originalContentURL = "originalContentUrl"
        case previewImageURL = "previewImageUrl"
        case animated
        case `extension`
        case sender = "sentBy"
    }
}
