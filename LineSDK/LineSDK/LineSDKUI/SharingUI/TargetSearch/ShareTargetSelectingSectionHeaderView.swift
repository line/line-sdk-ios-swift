//
//  ShareTargetSelectingSectionHeaderView.swift
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

class ShareTargetSelectingSectionHeaderView: UIView {

    enum Design {
        static var height:          CGFloat { return 25 }
        static var fontSize:        CGFloat { return 12 }
        static var fontColor:       UIColor { return .compatibleColor(light: 0x797F8C, dark: 0xF5F5F5) }
        static var backgroundColor: UIColor { return .compatibleColor(light: 0xF9F9F9, dark: 0x000000) }
        static var borderColor:     UIColor { return .compatibleColor(light: 0xEDEDF1, dark: 0x171717) }
        static var borderWidth:     CGFloat { return 0.5 }
    }

    let titleLabel = UILabel(frame: .zero)

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Design.backgroundColor
        layer.borderColor = Design.borderColor.cgColor
        layer.borderWidth = Design.borderWidth

        titleLabel.font = UIFont.systemFont(ofSize: Design.fontSize)
        titleLabel.textColor = Design.fontColor

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
