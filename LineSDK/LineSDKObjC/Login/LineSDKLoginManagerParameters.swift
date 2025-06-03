//
//  LineSDKLoginManagerParameters.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

@objcMembers
public class LineSDKLoginManagerParameters: NSObject {
    
    var _value: LoginManager.Parameters
    
    public override init() {
        _value = LoginManager.Parameters()
    }
    
    init(_ value: LoginManager.Parameters) { _value = value }
    
    public var onlyWebLogin: Bool {
        get { return _value.onlyWebLogin }
        set { _value.onlyWebLogin = newValue }
    }
    
    public var botPromptStyle: LineSDKLoginManagerBotPrompt? {
        get { return _value.botPromptStyle.map(LineSDKLoginManagerBotPrompt.init) }
        set { _value.botPromptStyle = newValue?._value }
    }

    public var promptBotID: String? {
        get { return _value.promptBotID }
        set { _value.promptBotID = newValue }
    }

    public var initialWebAuthenticationMethod: LineSDKLoginManagerWebAuthenticationMethod {
        get { return LineSDKLoginManagerWebAuthenticationMethod(_value.initialWebAuthenticationMethod) }
        set { _value.initialWebAuthenticationMethod = newValue._value }
    }

    public var preferredWebPageLanguage: String? {
        get { return _value.preferredWebPageLanguage?.rawValue }
        set { _value.preferredWebPageLanguage = newValue.map { .init(rawValue: $0) } }
    }

    public var IDTokenNonce: String? {
        get { return _value.IDTokenNonce }
        set { _value.IDTokenNonce = newValue }
    }
}

@objcMembers
final public class LineSDKLoginManagerBotPrompt: NSObject, Sendable {

    let _value: LoginManager.BotPrompt
    init(_ value: LoginManager.BotPrompt) { _value = value }
    
    public static let normal = LineSDKLoginManagerBotPrompt(.normal)
    public static let aggressive = LineSDKLoginManagerBotPrompt(.aggressive)
    
    public var rawValue: String { return _value.rawValue }
}

@objcMembers
final public class LineSDKLoginManagerWebAuthenticationMethod: NSObject, Sendable {

    let _value: LoginManager.WebAuthenticationMethod
    init(_ value: LoginManager.WebAuthenticationMethod) { _value = value }

    public static let email = LineSDKLoginManagerWebAuthenticationMethod(.email)
    public static let qrCode = LineSDKLoginManagerWebAuthenticationMethod(.qrCode)

    public var rawValue: String { return _value.rawValue }
}
