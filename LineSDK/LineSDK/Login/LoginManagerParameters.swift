//
//  LoginManagerParameters.swift
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

extension LoginManager {
    
    /// Parameters used during login.
    public struct Parameters {
        
        /// Forces the use of web authentication flow instead of LINE app-to-app authentication flow.
        public var onlyWebLogin: Bool = false
        
        /// The style for showing the "Add bot as friend" prompt on the consent screen.
        public var botPromptStyle: BotPrompt? = nil
        
        /// Sets the preferred language used when logging in with the web authorization flow.
        ///
        /// If not set, the web authentication flow shows the login page in the user's device language, or falls
        /// back to English. Once set, the web page is displayed in the preferred language.
        ///
        /// - Note:
        ///   This property does not affect the preferred language when LINE is used for authorization.
        ///   LINE and the login screen are always displayed in the user's device language.
        ///
        public var preferredWebPageLanguage: WebPageLanguage? = nil
        
        /// Sets the nonce value for ID token verification. This value is used when requesting user authorization
        /// with `.openID` permission to prevent replay attacks to your backend server. If not set, LINE SDK will
        /// generate a random value as the token nonce. Whether set or not, LINE SDK verifies against the nonce value
        /// in received ID token locally.
        public var IDTokenNonce: String? = nil
        
        /// Determines whether it's possible to create another login process while the original one is still valid.
        /// If `true`, when a new login action is started, any existing one ends with a
        /// `GeneralErrorReason.processDiscarded` error. If `false`, the new login action is ignored, and the
        /// existing one continues to wait for a result.
        /// When the deploy target is **macCatalyst**, the default value is `true`. In other cases, it's `false`.
        #if targetEnvironment(macCatalyst)
        public var allowRecreatingLoginProcess = true
        #else
        public var allowRecreatingLoginProcess = false
        #endif
        
        /// Creates a default `LoginManager.Parameters` value.
        public init() {}
        
        // MARK: - Deprecated
        /// :nodoc:
        @available(*, deprecated,
        message: "Internally deprecated to suppress warning. Set properties in `Parameters` instead.")
        public init(options: LoginManagerOptions, language: WebPageLanguage?) {
            self.onlyWebLogin = options.contains(.onlyWebLogin)
            self.botPromptStyle = options.botPrompt
            self.preferredWebPageLanguage = language
        }
    }
}

extension LoginManager {
    
    /// The style for showing the "Add bot as friend" prompt on the consent screen.
    public enum BotPrompt: String {
        /// Includes an option to add a bot as friend on the consent screen.
        case normal
        /// Opens a new screen to add a bot as a friend after the user agrees to the permissions on the consent
        /// screen.
        case aggressive
    }
    
    /// Represents the language used in the web page.
    public struct WebPageLanguage {
        /// :nodoc:
        public let rawValue: String

        /// Creates a web page language with a given raw string language code value.
        ///
        /// - Parameter rawValue: The value represents the language code.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        /// The Arabic language.
        public static let arabic = WebPageLanguage(rawValue: "ar")
        /// The German language.
        public static let german = WebPageLanguage(rawValue: "de")
        /// The English language.
        public static let english = WebPageLanguage(rawValue: "en")
        /// The Spanish language.
        public static let spanish = WebPageLanguage(rawValue: "es")
        /// The French language.
        public static let french = WebPageLanguage(rawValue: "fr")
        /// The Indonesian language.
        public static let indonesian = WebPageLanguage(rawValue: "id")
        /// The Italian language.
        public static let italian = WebPageLanguage(rawValue: "it")
        /// The Japanese language.
        public static let japanese = WebPageLanguage(rawValue: "ja")
        /// The Korean language.
        public static let korean = WebPageLanguage(rawValue: "ko")
        /// The Malay language.
        public static let malay = WebPageLanguage(rawValue: "ms")
        /// The Brazilian Portuguese language.
        public static let portugueseBrazilian = WebPageLanguage(rawValue: "pt-BR")
        /// The European Portuguese language.
        public static let portugueseEuropean = WebPageLanguage(rawValue: "pt-PT")
        /// The Russian language.
        public static let russian = WebPageLanguage(rawValue: "ru")
        /// The Thai language.
        public static let thai = WebPageLanguage(rawValue: "th")
        /// The Turkish language.
        public static let turkish = WebPageLanguage(rawValue: "tr")
        /// The Vietnamese language.
        public static let vietnamese = WebPageLanguage(rawValue: "vi")
        /// The Simplified Chinese language.
        public static let chineseSimplified = WebPageLanguage(rawValue: "zh-Hans")
        /// The Traditional Chinese language.
        public static let chineseTraditional = WebPageLanguage(rawValue: "zh-Hant")
    }
}
