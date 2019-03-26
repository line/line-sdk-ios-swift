//
//  Constant.swift
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

/// Constants used in the LINE SDK.
public struct Constant {
    
    /// The version of the current LINE SDK.
    public static let SDKVersion: String = {
        let bundle = Bundle.frameworkBundle
        guard let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            Log.fatalError("SDK resource bundle cannot be loaded, " +
                           "please verify your installation is not corrupted and try to reinstall LineSDK.")
        }
        
        return version
    }()
    
    static var SDKVersionString: String {
        return "LINE SDK iOS v\(SDKVersion)"
    }
    
    static var thirdPartyAppReturnScheme: String {
        guard let appID = Bundle.main.bundleIdentifier else {
            Log.fatalError("You need to specify a bundle ID in your app's Info.plist")
        }
        return "\(Constant.thirdPartySchemePrefix).\(appID)"
    }
    
    static var thirdPartyAppReturnURL: String {
        return "\(Constant.thirdPartyAppReturnScheme)://authorize/"
    }
    
    static var lineAppAuthURLv2: URL {
        return URL(string: "\(Constant.lineAuthV2Scheme)://authorize/")!
    }
}

extension Bundle {
    static let frameworkBundle: Bundle = {
        let frameworkBundle = Bundle(for: LoginManager.self)
        guard let path = frameworkBundle.path(forResource: "Resource", ofType: "bundle"),
            let bundle = Bundle(path: path) else
        {
            Log.fatalError("SDK resource bundle cannot be found, " +
                           "please verify your installation is not corrupted and try to reinstall LineSDK.")
        }
        return bundle
    }()
}
