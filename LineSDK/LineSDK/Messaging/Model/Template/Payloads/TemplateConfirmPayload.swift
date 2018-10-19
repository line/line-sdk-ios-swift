//
//  TemplateConfirmPayload.swift
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
/// Represents a template payload with a text and two action button.
/// Use this template if you want users to answer between "Yes" or "No".
public struct TemplateConfirmPayload: Codable, TemplateMessagePayloadTypeCompatible {
    let type = TemplateMessagePayloadType.confirm
    
    /// Message text in the chat bubble.
    public var text: String
    
    /// Positive confirm action of the payload.
    /// To set the `confirmAction` with any `MessageActionConvertible` type, use `setConfirmAction` method.
    public var confirmAction: MessageAction {
        get { return actions[0] }
        set { actions[0] = newValue }
    }
    
    /// Negative cancel action of the payload.
    /// To set the `cancelAction` with any `MessageActionConvertible` type, use `setCancelAction` method.
    public var cancelAction: MessageAction {
        get { return actions[1] }
        set { actions[1] = newValue }
    }
    
    var actions: [MessageAction]
    
    /// Creates a confirm payload with given information.
    ///
    /// - Parameters:
    ///   - text: Message text in the chat bubble.
    ///   - confirmAction: Positive confirm action of the payload.
    ///   - cancelAction: Negative cancel action of the payload.
    public init(text: String, confirmAction: MessageActionConvertible, cancelAction: MessageActionConvertible) {
        self.text = text
        self.actions = [confirmAction.action, cancelAction.action]
    }
    
    /// Sets the `confirmAction` with a `MessageActionConvertible` type.
    ///
    /// - Parameter value: The action needs to be set.
    public mutating func setConfirmAction(_ value: MessageActionConvertible) {
        confirmAction = value.action
    }
    
    /// Sets the `cancelAction` with a `MessageActionConvertible` type.
    ///
    /// - Parameter value: The action needs to be set.
    public mutating func setCancelAction(_ value: MessageActionConvertible) {
        cancelAction = value.action
    }
}

extension TemplateConfirmPayload: TemplateMessageConvertible {
    /// Returns a converted `TemplateMessagePayload` which wraps this `TemplateConfirmPayload`.
    public var payload: TemplateMessagePayload { return .confirm(self) }
}
