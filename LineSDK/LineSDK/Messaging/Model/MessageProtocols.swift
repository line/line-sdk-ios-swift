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

/// LINE internal use only.
/// Represents a type which could be converted to a `Message` directly.
public protocol MessageConvertible {
    /// Returns a converted `Message` which wraps `Self`.
    var message: Message { get }
}

/// Represents a type which could be converted to a `Message` with a given alternate text.
public protocol AltTextMessageConvertible {
    
    /// Returns a converted `Message` which wraps `Self` with an alternate text.
    ///
    /// - Parameter text: An alternate text to show in LINE push notification or chat preview.
    /// - Returns: A converted `Message`.
    func messageWithAltText(_ text: String) -> Message
}

/// Represents a type which could be converted to a `TemplateMessage`.
public protocol TemplateMessageConvertible: AltTextMessageConvertible {
    
    /// The payload from which a `TemplateMessage` would be converted to.
    var payload: TemplateMessagePayload { get }
}

public extension TemplateMessageConvertible {
    
    /// Returns a converted `Message` which wraps `Self` with an alternate text.
    ///
    /// - Parameter text: The alternate text if the message cannot be displayed correctly.
    /// - Returns: A converted `Message`.
    func messageWithAltText(_ text: String) -> Message {
        return TemplateMessage(altText: text, payload: payload).message
    }
}

/// Represents a type which could be converted to a `FlexMessage`.
public protocol FlexMessageConvertible: AltTextMessageConvertible {
    
    /// The container from which a `FlexMessage` would be converted to.
    var container: FlexMessageContainer { get }
}

extension FlexMessageConvertible {
    
    /// Returns a converted `Message` which wraps `Self` with an alternate text.
    ///
    /// - Parameter text: The alternate text if the message cannot be displayed correctly.
    /// - Returns: A converted `Message`.
    public func messageWithAltText(_ text: String) -> Message {
        return FlexMessage(altText: text, container: container).message
    }
}

/// Represents a type which could be converted to a `FlexMessageComponent`.
public protocol FlexMessageComponentConvertible {
    
    /// Returns a converted `FlexMessageComponent` which wraps `Self`.
    var component: FlexMessageComponent { get }
}

/// Represents a type which could be converted to a `MessageAction`.
public protocol MessageActionConvertible {
    
    /// Returns a converted `MessageAction` which wraps `Self`.
    var action: MessageAction { get }
}

/// Represents a type in which an action is contained. It is used to simplify the action setting behavior.
public protocol MessageActionContainer {
    var action: MessageAction? { get set }
}

extension MessageActionContainer {
    /// Sets the `action` for the conforming type.
    ///
    /// - Parameter value: The action to set.
    public mutating func setAction(_ value: MessageActionConvertible?) {
        action = value?.action
    }
}

/// Represents a type which contains a `type` key. It could indicate a `Message` case.
protocol MessageTypeCompatible {
    var type: MessageType { get }
}

/// Represents a type which contains a `type` key. It could indicate a `TemplateMessagePayload` case.
protocol TemplateMessagePayloadTypeCompatible {
    var type: TemplateMessagePayloadType { get }
}

/// Represents a type which contains a `type` key. It could indicate a `MessageAction` case.
protocol TemplateMessageActionTypeCompatible {
    var type: MessageActionType { get }
}

/// Represents a type which contains a `type` key. It could indicate a `FlexMessageContainer` case.
protocol FlexMessageContainerTypeCompatible {
    var type: FlexMessageContainerType { get }
}

/// Represents a type which contains a `type` key. It could indicate a `FlexMessageComponent` case.
protocol FlexMessageComponentTypeCompatible {
    var type: FlexMessageComponentType { get }
}

/// Asserts if a parameter meets a give `condition`. If fails, a `LineSDKError.generalError` with
/// `.parameterError` as its reason will be thrown.
///
/// - Parameters:
///   - name: The name of input parameter. It will be used as the `parameterName` in `.parameterError`.
///   - reason: The description of the error. It will be used as the `description` in `.parameterError`.
///   - condition: Assertion condition to check.
/// - Throws: A `LineSDKError.generalError` with `.parameterError` as its reason, if condition does not
///           pass the assertion.
///
func assertParameter(
    name: @autoclosure () -> String,
    reason: @autoclosure () -> String,
    unless condition: () -> Bool) throws
{
    guard !condition() else { return }
    throw LineSDKError.generalError(reason: .parameterError(parameterName: name(), description: reason()))
}

/// Asserts if `url` contains a scheme of "https".
///
/// - Parameters:
///   - url: Input URL to assert.
///   - parameterName: The name of input parameter. It will be used as the `parameterName` in `.parameterError`.
/// - Throws: A `LineSDKError.generalError` with `.parameterError` as its reason, if condition does not
///           pass the assertion.
func assertHTTPSScheme(url: URL, parameterName: String) throws {
    try assertParameter(
        name: parameterName,
        reason: "HTTPS scheme is required for `\(parameterName)`.")
    {
        url.scheme?.lowercased() == "https"
    }
}
