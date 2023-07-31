//
//  ToastView.swift
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

class ToastView: UIView {
    
    let containerView: UIStackView
    let padding: UIEdgeInsets
    
    let onDisappeared = Delegate<(), Void>()
    
    init(views: [UIView], padding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)) {
        self.containerView = UIStackView(arrangedSubviews: views)
        self.padding = padding
        super.init(frame: .zero)
        setup()
    }
    
    func setup() {
        containerView.axis = .vertical
        containerView.distribution = .fill
        containerView.alignment = .center
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: padding.top),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding.left),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding.bottom),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding.right)
        ])
        
        layer.cornerRadius = 5
        clipsToBounds = true
    }
    
    func dismiss(fadeOut: Bool) {
        if fadeOut {
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self.alpha = 0
                },
                completion: { _ in
                    self.removeFromSuperview()
                    self.onDisappeared.call()
                }
            )
        } else {
            removeFromSuperview()
            onDisappeared.call()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ToastLabelView: ToastView {
    init(label: UILabel, padding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)) {
        super.init(views: [label], padding: padding)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ToastView {
    @discardableResult
    static func show(
        text: String,
        in view: UIView,
        fadeIn: Bool = true,
        fadeOut: Bool = true,
        duration: TimeInterval = 2.0
    ) -> ToastLabelView {
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.white.withAlphaComponent(0.85)
        label.text = text
        label.numberOfLines = 0
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(lessThanOrEqualToConstant: view.frame.width * 0.5)
        ])
        
        let toast = ToastLabelView(label: label)
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        
        view.addSubview(toast)

        toast.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        if fadeIn {
            toast.alpha = 0
            UIView.animate(withDuration: 0.25) {
                toast.alpha = 1
            }
        }
        
        let showTime = max(duration, 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + showTime) {
            toast.dismiss(fadeOut: fadeOut)
        }
        
        return toast
    }
}
