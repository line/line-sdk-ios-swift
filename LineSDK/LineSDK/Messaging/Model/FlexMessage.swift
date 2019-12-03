//
//  FlexMessage.swift
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
/// Represents a flexible message which consists of an alternative text and a flex container.
/// Flex messages are messages with a customizable layout. You can customize the layout freely by combining
/// multiple elements.
///
/// To create a `FlexMessage`, firstly you need to create a certain container, and then pass it with an `altText`
/// to initializer.
///
/// For more information, see https://developers.line.biz/en/docs/messaging-api/message-types/#flex-messages .
public struct FlexMessage: Codable, MessageTypeCompatible {
    let type = MessageType.flex
    
    /// An alternate text to show in LINE push notification or chat preview.
    public var altText: String
    
    /// The content of this flex message.
    public var contents: FlexMessageContainer
    
    /// Creates a flex message with given information.
    ///
    /// - Parameters:
    ///   - altText: An alternate text to show in LINE push notification or chat preview.
    ///   - container: The content of this flex message.
    public init(altText: String, container: FlexMessageConvertible) {
        self.altText = altText
        self.contents = container.container
    }
}

extension FlexMessage: MessageConvertible {
    /// Returns a converted `Message` which wraps this `FlexMessage`.
    public var message: Message { return .flex(self) }
}
