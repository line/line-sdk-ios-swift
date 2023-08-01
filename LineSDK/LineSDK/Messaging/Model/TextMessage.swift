//
//  TextMessage.swift
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
/// Represents a message containing only text.
public struct TextMessage: Codable, MessageTypeCompatible {
    
    let type = MessageType.text
    
    /// Text content of message. You can include either Unicode emoji or LINE original
    /// emoji (Unicode codepoint table for LINE original emoji) as well.
    public var text: String
    
    /// Message agent who sends this message on behalf of the sender.
    public var sender: MessageSender?
    
    /// Creates a text message with given information.
    ///
    /// - Parameters:
    ///   - text: Text content of message. You can include either Unicode emoji or LINE original
    ///           emoji (Unicode codepoint table for LINE original emoji) as well.
    ///   - sender: Message agent who sends this message on behalf of the sender.
    public init(text: String, sender: MessageSender? = nil) {
        self.text = text
        self.sender = sender
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case sender = "sentBy"
    }
}

extension TextMessage: MessageConvertible {
    /// Returns a converted `Message` which wraps this `TextMessage`.
    public var message: Message { return .text(self) }
}
