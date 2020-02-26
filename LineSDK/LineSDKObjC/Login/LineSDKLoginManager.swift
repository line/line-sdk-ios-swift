//
//  LineSDKLoginManager.swift
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

import UIKit
#if !LineSDKCocoaPods && !LineSDKBinary
import LineSDK
#endif

@objcMembers
public class LineSDKLoginManager: NSObject {
    let _value: LoginManager
    init(_ value: LoginManager) { _value = value }
    
    public static let sharedManager = LineSDKLoginManager(.shared)
    public var currentProcess: LineSDKLoginProcess? { return _value.currentProcess.map { .init($0) } }
    public var isSetupFinished: Bool { return _value.isSetupFinished }
    public var isAuthorized: Bool { return _value.isAuthorized }
    public var isAuthorizing: Bool { return _value.isAuthorizing }
    
    @available(*, deprecated,
    message: "Set `preferredWebPageLanguage` in `LineSDKLoginManagerParameters` instead.")
    public var preferredWebPageLanguage: String? {
        get { return _value.preferredWebPageLanguage?.rawValue }
        set { _value.preferredWebPageLanguage = newValue.map { .init(rawValue: $0) } }
    }
    
    public func setup(channelID: String, universalLinkURL: URL?) {
        _value.setup(channelID: channelID, universalLinkURL: universalLinkURL)
    }

    @discardableResult
    public func login(
        permissions: Set<LineSDKLoginPermission>?,
        inViewController viewController: UIViewController?,
        completionHandler completion: @escaping (LineSDKLoginResult?, Error?) -> Void
    ) -> LineSDKLoginProcess?
    {
        let parameters = LineSDKLoginManagerParameters()
        return login(
            permissions: permissions,
            inViewController: viewController,
            parameters: parameters,
            completionHandler: completion
        )
    }

    @discardableResult
    public func login(
        permissions: Set<LineSDKLoginPermission>?,
        inViewController viewController: UIViewController?,
        parameters: LineSDKLoginManagerParameters,
        completionHandler completion: @escaping (LineSDKLoginResult?, Error?) -> Void
    ) -> LineSDKLoginProcess?
    {
        let process = _value.login(
            permissions: Set((permissions ?? [.profile]).map { $0.unwrapped }),
            in: viewController,
            parameters: parameters._value)
        {
            result in
            result
                .map(LineSDKLoginResult.init)
                .match(with: completion)
        }
        return process.map { .init($0) }
    }

    public func logout(completionHandler completion: @escaping (Error?) -> Void) {
        _value.logout { result in result.matchFailure(with: completion) }
    }
    
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return _value.application(app, open: url, options: options)
    }
    
    // MARK: - Deprecated
    
    @available(*, deprecated, message: """
    Convert the `options` to a `LoginManager.Parameters` value and
    use `login(permissions:inViewController:parameters:completionHandler:)` instead.")
    """)
    @discardableResult
    public func login(
        permissions: Set<LineSDKLoginPermission>?,
        inViewController viewController: UIViewController?,
        options: [LineSDKLoginManagerOptions]?,
        completionHandler completion: @escaping (LineSDKLoginResult?, Error?) -> Void
    ) -> LineSDKLoginProcess?
    {
        let options: LoginManagerOptions = (options ?? []).reduce([]) { (result, option) in
            result.union(option.unwrapped)
        }
        
        let parameters = LoginManager.Parameters(
            options: options,
            language: preferredWebPageLanguage.map { .init(rawValue: $0) }
        )
        return login(
            permissions: permissions,
            inViewController: viewController,
            parameters: .init(parameters),
            completionHandler: completion
        )
    }
}
