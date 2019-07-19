//
//  ResourceLoading.swift
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

enum Localization {
    static func string(_ key: String) -> String {
        return NSLocalizedString(key, bundle: .frameworkResourceBundle, comment: "")
    }
}

extension UIImage {

    /// Creates a `UIImage` object in current framework bundle.
    ///
    /// - Parameters:
    ///   - name: The image name.
    ///   - trait: The traits associated with the intended environment for the image.
    convenience init?(bundleNamed name: String, compatibleWith trait: UITraitCollection? = nil) {
        let bundle: Bundle
        #if LineSDKCocoaPods
        bundle = .sdkBundle
        #else
        bundle = .frameworkBundle
        #endif
        self.init(named: name, in: bundle, compatibleWith: trait)
    }
}

extension Bundle {
    static let frameworkResourceBundle: Bundle = {
        let parentBundle: Bundle
        #if LineSDKCocoaPods
        parentBundle = sdkBundle
        #else
        parentBundle = frameworkBundle
        #endif

        guard let path = parentBundle.path(forResource: "Resource", ofType: "bundle"),
              let bundle = Bundle(path: path) else
        {
            Log.fatalError("SDK resource bundle cannot be found, " +
                           "please verify your installation is not corrupted and try to reinstall LineSDK.")
        }
        return bundle
    }()

    #if LineSDKCocoaPods
    // SDK Bundle is for CocoaPods: ( sp.resource_bundles = { 'LineSDK' => [ ... ] } )
    static let sdkBundle: Bundle = {
        guard let path = Bundle.frameworkBundle.path(forResource: "LineSDK", ofType: "bundle"),
              let bundle = Bundle(path: path) else
        {
            Log.fatalError("LineSDK.bundle cannot be found, " +
                           "please verify your installation is not corrupted and try to reinstall LineSDK.")
        }
        return bundle
    }()
    #endif

    static let frameworkBundle: Bundle = {
        return Bundle(for: LoginManager.self)
    }()
}
