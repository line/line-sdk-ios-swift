//
//  SelectedTargetView.swift
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

class SelectedTargetView: UIView {
    enum Design {
        static var height: CGFloat { return 79 }
        static var bgColor: UIColor { return .init(hex6: 0xF7F8FA) }
        static var borderColor: UIColor { return .init(hex6: 0xE6E7EA) }
        static var borderWidth: CGFloat { return 0.5 }
    }

    private var slideAnimationViewTopConstraint: NSLayoutConstraint!

    private let slideAnimationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = Design.bgColor
        view.layer.borderWidth = Design.borderWidth
        view.layer.borderColor = Design.borderColor.cgColor
        return view
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        setupSubviews()

        setupLayouts()
    }

    private func setupSubviews() {
        addSubview(slideAnimationView)
    }

    private func setupLayouts() {
        slideAnimationView.translatesAutoresizingMaskIntoConstraints = false
        slideAnimationViewTopConstraint = slideAnimationView.topAnchor.constraint(equalTo: topAnchor)
        slideAnimationViewTopConstraint.isActive = true
        NSLayoutConstraint.activate([
            slideAnimationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            slideAnimationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            slideAnimationView.heightAnchor.constraint(equalTo: heightAnchor)
            ])
    }

    enum Mode {
        case show
        case hide
    }

    var mode = Mode.hide

    func updateLayout(animated: Bool) {
        self.slideAnimationViewTopConstraint.isActive = false
        let anchor: NSLayoutYAxisAnchor
        let alpha: CGFloat
        switch self.mode {
        case .show:
            anchor = topAnchor
            isUserInteractionEnabled = true
            alpha = 1
        case .hide:
            anchor = bottomAnchor
            isUserInteractionEnabled = false
            alpha = 0
        }
        self.slideAnimationViewTopConstraint = slideAnimationView.topAnchor.constraint(equalTo: anchor)
        self.slideAnimationViewTopConstraint.isActive = true

        if animated {
            UIView.animate(withDuration: 0.2) {
                self.alpha = alpha
                self.layoutIfNeeded()
            }
        } else {
            self.alpha = alpha
            self.layoutIfNeeded()
        }
    }
}
