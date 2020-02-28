//
//  LineSDKMessagingResponse.swift
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

#if !LineSDKCocoaPods && !LineSDKBinary
import LineSDK
#endif

@objcMembers
public class LineSDKMessageSendingStatus: NSObject {
    let _value: MessageSendingStatus
    init(_ value: MessageSendingStatus) { _value = value }
    
    public static let statusOK = LineSDKMessageSendingStatus(.ok)
    public static let statusDiscarded = LineSDKMessageSendingStatus(.discarded)
    
    public func isEqualToStatus(_ another: LineSDKMessageSendingStatus) -> Bool {
        return _value == another._value
    }
    
    public var isOK: Bool {
        return _value.isOK
    }
    
    var unwrapped: MessageSendingStatus { return _value }
}

@objcMembers
public class LineSDKPostSendMessagesResponse: NSObject {
    let _value: PostSendMessagesRequest.Response
    init(_ value: PostSendMessagesRequest.Response) { _value = value }
    
    public var status: LineSDKMessageSendingStatus { return .init(_value.status) }
}

@objcMembers
public class LineSDKPostMultisendMessagesResponseSendingResult: NSObject {
    let _value: PostMultisendMessagesRequest.Response.SendingResult
    init(_ value: PostMultisendMessagesRequest.Response.SendingResult) { _value = value }
    
    public var to: String { return _value.to }
    public var status: LineSDKMessageSendingStatus { return .init(_value.status) }
}

@objcMembers
public class LineSDKPostMultisendMessagesResponse: NSObject {
    let _value: PostMultisendMessagesRequest.Response
    init(_ value: PostMultisendMessagesRequest.Response) { _value = value }
    
    public var result: [LineSDKPostMultisendMessagesResponseSendingResult] { return _value.results.map { .init($0) } }
}
