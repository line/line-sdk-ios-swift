//
//  TemplateMessage.swift
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
/// Represents a template message which consists of an alternative text and a template payload.
/// Template messages are messages with predefined layouts which you can customize.
///
/// To create a `TemplateMessage`, firstly you need to create a certain payload, and then pass it with an `altText`
/// to initializer.
///
/// For more information, see https://developers.line.biz/en/docs/messaging-api/message-types/#template-messages .
public struct TemplateMessage: Codable, MessageTypeCompatible {
    let type = MessageType.template
    
    /// An alternate text to show in LINE push notification or chat preview.
    public var altText: String
    
    /// The content of this template message.
    public var payload: TemplateMessagePayload
    
    /// Creates a template message with given information.
    ///
    /// - Parameters:
    ///   - altText: An alternate text to show in LINE push notification or chat preview.
    ///   - payload: The content of this template message.
    public init(altText: String, payload: TemplateMessageConvertible) {
        self.altText = altText
        self.payload = payload.payload
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case altText
        case payload = "template"
    }
}

extension TemplateMessage: MessageConvertible {
    /// Returns a converted `Message` which wraps this `TemplateMessage`.
    public var message: Message { return .template(self) }
}
