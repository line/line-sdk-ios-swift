//
//  Helpers.swift
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

enum Log {
    static func assertionFailure(
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line)
    {
        Swift.assertionFailure("[LineSDK] \(message())", file: file, line: line)
    }
    
    static func fatalError(
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Never
    {
        Swift.fatalError("[LineSDK] \(message())", file: file, line: line)
    }
    
    static func precondition(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        line: UInt = #line
    )
    {
        Swift.precondition(condition(), "[LineSDK] \(message())", file: file, line: line)
    }
    
    static func print(_ items: Any...) {
        let s = items.reduce("") { result, next in
            return result + String(describing: next)
        }
        Swift.print("[LineSDK] \(s)")
    }
}

/// Possible keys in the `userInfo` property of notifications related to the LINE Platform.
public struct LineSDKNotificationKey {}

extension UIApplication {
    func openLINEInAppStore() {
        let url = URL(string: "https://itunes.apple.com/app/id443904275?mt=8")!
        open(url, options: [:], completionHandler: nil)
    }
    
    func openLINEApp() {
        let url = URL(string: "\(Constant.lineAuthV2Scheme)://")!
        open(url, options: [:], completionHandler: nil)
    }
}

extension UIView {
    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.leadingAnchor
    }
    
    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        return safeAreaLayoutGuide.trailingAnchor
    }
}

extension UIViewController {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        return view.safeAreaLayoutGuide.topAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        return view.safeAreaLayoutGuide.bottomAnchor
    }
    
    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        return view.safeAreaLayoutGuide.leadingAnchor
    }
    
    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        return view.safeAreaLayoutGuide.trailingAnchor
    }

    var safeAreaInsets: UIEdgeInsets {
        return view.safeAreaInsets
    }

    func addChild(_ viewController: UIViewController, to containerView: UIView) {
        addChild(viewController)
        containerView.addChildSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    func addChild(_ viewController: UIViewController, to layoutGuide: UILayoutGuide) {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
            ])
    }
}

extension UIViewController {
    var expectedSearchBarHeight: CGFloat {
        return 54
    }
}

extension UIView {
    // Add a subview as `self` is a container. Layout the added `child` to match `self` size.
    func addChildSubview(_ child: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        addSubview(child)
        NSLayoutConstraint.activate([
            child.topAnchor     .constraint(equalTo: topAnchor),
            child.leadingAnchor .constraint(equalTo: leadingAnchor),
            child.trailingAnchor.constraint(equalTo: trailingAnchor),
            child.bottomAnchor  .constraint(equalTo: bottomAnchor),
        ])
    }
}

func guardSharedProperty<T>(_ input: T?) -> T {
    guard let shared = input else {
        Log.fatalError("Use \(T.self) before setup. " +
            "Please call `LoginManager.setup` before you do any other things in LineSDK.")
    }
    return shared
}

extension Constant {
    static var isLINEInstalled: Bool {
        return UIApplication.shared.canOpenURL(Constant.lineAppAuthURLv2)
    }
}
