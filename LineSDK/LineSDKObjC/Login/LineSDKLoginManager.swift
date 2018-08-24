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

import LineSDK

@objcMembers
public class LineSDKLoginManager: NSObject {
    let _value: LoginManager
    init(_ value: LoginManager) { _value = value }
    
    public static let sharedManager = LineSDKLoginManager(.shared)
    public var currentProcess: LineSDKLoginProcess? { return _value.currentProcess.map { .init($0) } }
    public var isSetupFinished: Bool { return _value.isSetupFinished }
    public var isAuthorized: Bool { return _value.isAuthorized }
    public var isAuthorizing: Bool { return _value.isAuthorizing }
    public func setup(channelID: String, universalLinkURL: URL?) {
        _value.setup(channelID: channelID, universalLinkURL: universalLinkURL)
    }
    @discardableResult
    public func login(
        permissions: Set<LineSDKLoginPermission>?,
        inViewController viewController: UIViewController? = nil,
        options: [LineSDKLoginManagerOption]?,
        completionHandler completion: @escaping (LineSDKLoginResult?, Error?) -> Void) -> LineSDKLoginProcess?
    {
        let process = _value.login(
            permissions: Set((permissions ?? [.profile]).map { $0._value }),
            in: viewController,
            options: (options ?? []).map { $0._value })
        {
            result in
            completion(result.value.map { .init($0) }, result.error)
        }
        return process.map { .init($0) }
    }
    
    public func logout(completionHandler completion: @escaping (Error?) -> Void) {
        _value.logout { result in completion(result.error) }
    }
    
    @available(iOS 9.0, *)
    public func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return _value.application(app, open: url, options: options)
    }
    
    @available(iOS, deprecated:9.0, message: "Use application(_:open:options:) instead.")
    public func application(
        _ application: UIApplication,
        open url: URL,
        sourceApplication: String?,
        annotation: Any) -> Bool
    {
        return _value.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}
