//
//  ShareTargetSelectingTableCell.swift
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

final class ShareTargetSelectingTableCell: UITableViewCell {

    enum Design {
        static let height: CGFloat = 53.0

        static let tickLeading: CGFloat = 10.0
        static let tickWidth: CGFloat = 22.0

        static let avatarLeading: CGFloat = 10.0
        static let avatarWidth: CGFloat = 43.0

        static let displayNameLeading: CGFloat = 10.0
        static let displayNameTrailing: CGFloat = 10.0

        static let separatorInset = UIEdgeInsets(top: 0, left: 95, bottom: 0, right: 0)
        static let separatorColorRGB =  UIColor(hex6: 0xE6E7EA)
        static let bgColor = UIColor.white
        static let highlightedBgColor = UIColor(hex6: 0xF5F5F5)
        static let highlightedNameColor = UIColor(hex6: 0x13C84D)
    }

    let tickImageView = UIImageView.init(frame: .zero)
    let avatarImageView = UIImageView(frame: .zero)
    let displayNameLabel = UILabel(frame: .zero)

    static let reuseIdentifier = "\(ShareTargetSelectingTableCell.self)"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        backgroundColor = Design.bgColor
        selectionStyle = .none
        separatorInset = Design.separatorInset

        setupSubviews()
        setupLayouts()
    }

    private func setupSubviews() {
        contentView.addSubview(tickImageView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(displayNameLabel)
    }

    private func setupLayouts() {
        tickImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        displayNameLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tickImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Design.tickLeading),
            tickImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tickImageView.widthAnchor  .constraint(equalToConstant: Design.tickWidth),
            tickImageView.heightAnchor .constraint(equalTo: tickImageView.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor
                .constraint(equalTo: tickImageView.trailingAnchor, constant: Design.avatarLeading),
            avatarImageView.centerYAnchor
                .constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: Design.avatarWidth),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            displayNameLabel.leadingAnchor
                .constraint(equalTo: avatarImageView.trailingAnchor, constant: Design.displayNameLeading),
            displayNameLabel.centerYAnchor
                .constraint(equalTo: contentView.centerYAnchor),
            displayNameLabel.trailingAnchor
                .constraint(greaterThanOrEqualTo: contentView.trailingAnchor, constant: Design.displayNameTrailing)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
