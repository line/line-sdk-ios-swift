//
//  LoginManagerOptions.swift
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

/// Represents the possible options when login to LINE with `LoginManager`
public struct LoginManagerOptions: OptionSet {
    
    /// Raw value of the option
    public let rawValue: Int
    
    /// Initializes an option from raw value.
    ///
    /// - Parameter rawValue: Underlying raw value of option.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Skips LINE client app auth flow. Only uses web login flow to login.
    public static let onlyWebLogin = LoginManagerOptions(rawValue: 1 << 0)
    
    /// Includes an option to add a bot as friend in the consent screen.
    /// If `.botPromptNormal` and `.botPromptAggressive` is set at the same time, `.botPromptAggressive` will be used.
    public static let botPromptNormal = LoginManagerOptions(rawValue: 1 << 1)
    
    /// Opens a new screen to add the bot as friend after the user agrees to the permissions in the consent screen.
    /// If `.botPromptNormal` and `.botPromptAggressive` is set at the same time, `.botPromptAggressive` will be used.
    public static let botPromptAggressive = LoginManagerOptions(rawValue: 1 << 2)
    
    var botPrompt: LoginProcess.BotPrompt? {
        if contains(.botPromptAggressive) { return .aggressive }
        if contains(.botPromptNormal) { return .normal }
        return nil
    }
}
