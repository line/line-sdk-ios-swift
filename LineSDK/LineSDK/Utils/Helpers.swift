//
//  Helpers.swift
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

struct Log {
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
        line: UInt = #line) -> Never
    {
        Swift.fatalError("[LineSDK] \(message())", file: file, line: line)
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
}

extension UIViewController {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return topLayoutGuide.bottomAnchor
        }
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomLayoutGuide.topAnchor
        }
    }

    var safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .zero
        }
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
        if #available(iOS 13.0, *) {
            return 54
        } else if #available(iOS 11.0, *) {
            // On iOS 11, the window safeAreaInsets.top returns wrong value (0).
            let topInset = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
            if topInset == 20 || // Normal screen on iOS 12+.
               topInset == 0     // Normal screen on iOS 11.
            {
                return 44
            } else {             // Notch screen.
                return 54
            }
        } else { // iOS 10
            return 44 + 20
        }
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
