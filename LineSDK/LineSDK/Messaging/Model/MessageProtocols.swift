//
//  MessageProtocols.swift
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

public protocol MessageConvertible {
    var message: Message { get }
}

public protocol AltTextMessageConvertible {
    func messageWithAltText(_ text: String) -> Message
}

public protocol TemplateMessageConvertible: AltTextMessageConvertible {
    var payload: TemplateMessagePayload { get }
}

public extension TemplateMessageConvertible {
    func messageWithAltText(_ text: String) -> Message {
        return TemplateMessage(altText: text, payload: payload).message
    }
}

public protocol FlexMessageConvertible: AltTextMessageConvertible {
    var container: FlexMessageContainer { get }
}

public extension FlexMessageConvertible {
    public func messageWithAltText(_ text: String) -> Message {
        return FlexMessage(altText: text, contents: container).message
    }
}

public protocol FlexMessageComponentConvertible {
    var component: FlexMessageComponent { get }
}

protocol MessageTypeCompatible {
    var type: MessageType { get }
}

protocol TemplateMessagePayloadTypeCompatible {
    var type: TemplateMessagePayloadType { get }
}

protocol TemplateMessageActionTypeCompatible {
    var type: MessageActionType { get }
}

protocol FlexMessageContainerTypeCompatible {
    var type: FlexMessageContainerType { get }
}

protocol FlexMessageComponentTypeCompatible {
    var type: FlexMessageComponentType { get }
}

func assertHTTPSScheme(url: URL, parameterName: String) throws {
    try assertParameter(
        name: parameterName,
        reason: "HTTPS scheme is required for `\(parameterName)`.")
    {
        url.scheme?.lowercased() == "https"
    }
}

func assertParameter(
    name: @autoclosure () -> String,
    reason: @autoclosure () -> String,
    unless condition: () -> Bool) throws
{
    guard !condition() else { return }
    throw LineSDKError.generalError(reason: .parameterError(parameterName: name(), description: reason()))
}
