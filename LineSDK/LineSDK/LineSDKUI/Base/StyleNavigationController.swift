//
//  LineSDKNavigationController.swift
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

import UIKit

open class StyleNavigationController: UINavigationController {
    enum Design {
        static var navigationBarTintColor: UIColor {
            return .compatibleColor(light: 0x283145, dark: 0x161B26)
        }
        static var preferredStatusBarStyle: UIStatusBarStyle  { return .lightContent }
        static var navigationBarTextColor:  UIColor { return .white }
    }
    
    /// The bar tint color of the navigation bar.
    public var navigationBarTintColor = Design.navigationBarTintColor {
        didSet { updateNavigationStyles() }
    }

    /// The color of text, including navigation bar title and bar button text, on the navigation bar.
    public var navigationBarTextColor = Design.navigationBarTextColor {
        didSet { updateNavigationStyles() }
    }

    /// The preferred status bar style of this navigation controller.
    public var statusBarStyle = Design.preferredStatusBarStyle {
        didSet { updateNavigationStyles() }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationStyles()
    }
    
    private func updateNavigationStyles() {
        navigationBar.shadowImage = UIImage()
        navigationBar.barTintColor = navigationBarTintColor
        navigationBar.tintColor = navigationBarTextColor
        navigationBar.titleTextAttributes = [.foregroundColor: navigationBarTextColor]
    }
    
    /// :nodoc:
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
}
