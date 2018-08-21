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

public struct TemplateConfirmPayload: Codable, TemplateMessagePayloadTypeCompatible {
    let type = TemplateMessagePayloadType.confirm
    public var text: String
    
    public var confirmAction: MessageAction {
        get { return actions[0] }
        set { actions[0] = newValue }
    }
    public var cancelAction: MessageAction {
        get { return actions[1] }
        set { actions[1] = newValue }
    }
    
    var actions: [MessageAction]
    
    public init(text: String, confirmAction: MessageAction, cancelAction: MessageAction) {
        self.text = text
        self.actions = [confirmAction, cancelAction]
    }
}

extension TemplateConfirmPayload {
    public var payload: TemplateMessagePayload { return .confirm(self) }
}

extension Message {
    public static func templateConfirmMessage(
        altText: String,
        text: String,
        confirmAction: MessageAction,
        cancelAction: MessageAction) -> Message
    {
        let payload = TemplateConfirmPayload(
            text: text,
            confirmAction: confirmAction,
            cancelAction: cancelAction).payload
        return payload.messageWithAltText(altText)
    }
}
