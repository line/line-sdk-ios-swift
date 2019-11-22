//
//  KeyboardObservable.swift
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

protocol KeyboardObservable: AnyObject {

    var keyboardObservers: [NotificationToken] { get set }

    func addKeyboardObserver()

    func removeKeyboardObserver()

    func keyboardInfoWillChange(keyboardInfo: KeyboardInfo)
}

extension KeyboardObservable {
    func addKeyboardObserver() {
        keyboardObservers = [
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillChangeFrameNotification,
                object: nil,
                queue: .main,
                using: { [unowned self] in
                    guard let userInfo = $0.userInfo else { return }
                    if let keyboardInfo = KeyboardInfo(from: userInfo) {
                        self.keyboardInfoWillChange(keyboardInfo: keyboardInfo)
                    }
                }
            )
        ]
    }

    func removeKeyboardObserver() {
        keyboardObservers.removeAll()
    }
}

struct KeyboardInfo {
    let isVisible: Bool
    let endFrame: CGRect?
    let duration: TimeInterval
    let animationCurve: UIView.AnimationCurve
    let isLocal: Bool?

    init?(from userInfo: [AnyHashable : Any]) {
        guard let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return nil
        }
        self.endFrame = endFrame
        isVisible = endFrame.minY < UIScreen.main.bounds.maxY
        duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        isLocal = (userInfo[UIResponder.keyboardIsLocalUserInfoKey] as? NSNumber)?.boolValue

        if let rawValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue {
            animationCurve = UIView.AnimationCurve(rawValue: rawValue) ?? .linear
        } else {
            animationCurve = .linear
        }
    }
}
