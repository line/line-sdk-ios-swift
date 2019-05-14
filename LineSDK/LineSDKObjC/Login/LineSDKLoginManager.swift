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

#if !LineSDKCocoaPods
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
        options: [LineSDKLoginManagerOptions]?,
        completionHandler completion: @escaping (LineSDKLoginResult?, Error?) -> Void) -> LineSDKLoginProcess?
    {
        let options: LoginManagerOptions = (options ?? []).reduce([]) { (result, option) in
            result.union(option.unwrapped)
        }
        let process = _value.login(
            permissions: Set((permissions ?? [.profile]).map { $0.unwrapped }),
            in: viewController,
            options: options)
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
}
