//
//  LineSDKMessage.swift
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

import LineSDK

@objcMembers
public class LineSDKMessage: NSObject {

    public var textMessage: LineSDKTextMessage? {
        return toMessage().asTextMessage.map { .init($0) }
    }
    
    public var imageMessage: LineSDKImageMessage? {
        return toMessage().asImageMessage.map { .init($0) }
    }
    
    public var videoMessage: LineSDKVideoMessage? {
        return toMessage().asVideoMessage.map { .init($0) }
    }
    
    public var locationMessage: LineSDKLocationMessage? {
        return toMessage().asLocationMessage.map { .init($0) }
    }
    
    func toMessage() -> Message { fatalError() }
}

@objcMembers
public class LineSDKMessageSender: NSObject {
    var _value: MessageSender
    init(_ value: MessageSender) { _value = value }
    public var label: String {
        get { return _value.label }
        set { _value.label = newValue }
    }
    public var iconURL: URL {
        get { return _value.iconURL }
        set { _value.iconURL = newValue }
    }
    public var linkURL: URL? {
        get { return _value.linkURL }
        set { _value.linkURL = newValue }
    }
    public convenience init(label: String, iconURL: URL, linkURL: URL?) {
        self.init(.init(label: label, iconURL: iconURL, linkURL: linkURL))
    }
}


