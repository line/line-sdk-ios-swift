//
//  UIAlertControllerHelpers.swift
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
import LineSDK

extension UIAlertController {
    @discardableResult
    static func present(
        in viewController: UIViewController,
        title: String?,
        message: String?,
        style: UIAlertController.Style = .alert,
        actions: [UIAlertAction]) -> Bool
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach(alert.addAction)
        viewController.present(alert, animated: true, completion: nil)
        return true
    }
    
    @discardableResult
    static func present(
        in viewController: UIViewController,
        title: String?,
        textViewMessage: String?,
        style: UIAlertController.Style = .alert,
        actions: [UIAlertAction]) -> Bool
    {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: style)
        alert.addTextField { textField in
            textField.text =  textViewMessage
        }
        actions.forEach(alert.addAction)
        viewController.present(alert, animated: true, completion: nil)
        return true
    }

    @discardableResult
    static func present(
        in viewController: UIViewController,
        error: Error,
        done: (() -> Void)? = nil) -> Bool
    {
        return present(
            in: viewController,
            title: "Error",
            message: "\(error.localizedDescription)",
            actions: [
                .init(title: "OK", style: .cancel) { _ in done?() }
            ]
        )
    }

    @discardableResult
    static func present(
        in viewController: UIViewController,
        error: String,
        done: (() -> Void)? = nil) -> Bool
    {
        return present(
            in: viewController,
            title: "Error",
            message: error,
            actions: [
                .init(title: "OK", style: .cancel) { _ in done?() }
            ]
        )
    }
    
    @discardableResult
    static func present(
        in viewController: UIViewController,
        successResult result: String,
        done: (() -> Void)? = nil) -> Bool
    {
        return present(
            in: viewController,
            title: "Success",
            message: result,
            actions: [
                .init(title: "OK", style: .default) { _ in done?() }
            ]
        )
    }
}
