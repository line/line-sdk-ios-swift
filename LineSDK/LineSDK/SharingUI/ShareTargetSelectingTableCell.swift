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
        static var height: CGFloat { return 54.0 }

        static var tickLeading: CGFloat { return 10.0 }
        static var tickWidth: CGFloat { return 22.0 }

        static var avatarLeading: CGFloat { return 10.0 }
        static var avatarWidth: CGFloat { return 44.0 }

        static var displayNameLeading: CGFloat { return 10.0 }
        static var displayNameTrailing: CGFloat { return 10.0 }
        static var displayNameTextColor: UIColor { return .black }
        static var displayNameFont: UIFont { return .systemFont(ofSize: 16) }
        static var displayNameHighlightedNameColor: UIColor { return .init(hex6: 0x13C84D) }

        static var separatorInset: UIEdgeInsets { return .init(top: 0, left: 96, bottom: 0, right: 0) }
        static var separatorColorRGB:  UIColor { return .init(hex6: 0xE6E7EA) }
        static var bgColor: UIColor { return .white }
    }

    let tickImageView = UIImageView.init(frame: .zero)
    let avatarImageView = DownloadableImageView(frame: .zero)
    let displayNameLabel = UILabel(frame: .zero)

    static let reuseIdentifier = "\(ShareTargetSelectingTableCell.self)"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        backgroundColor = Design.bgColor
        selectionStyle = .gray
        separatorInset = Design.separatorInset

        setupSubviews()
        setupLayouts()
    }

    private func setupSubviews() {
        contentView.addSubview(tickImageView)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(displayNameLabel)

        avatarImageView.layer.cornerRadius = Design.avatarWidth / 2;
        avatarImageView.clipsToBounds = true
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
                .constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -Design.displayNameTrailing)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ShareTargetSelectingTableCell {

    func displayNameAttributedString(_ name: String, highlightText: String? = nil) -> NSAttributedString {
        let displayNameAttributedString = NSMutableAttributedString(
            string: name,
            attributes: [
                .font: Design.displayNameFont,
                .foregroundColor: Design.displayNameTextColor
            ])
        if let highlightText = highlightText {
            let range = NSString(string: name).range(of: highlightText, options: .caseInsensitive)
            if range.location != NSNotFound {
                displayNameAttributedString.addAttribute(
                    .foregroundColor, value: Design.displayNameHighlightedNameColor, range: range)
            }
        }
        return displayNameAttributedString
    }

    func setShareTarget(_ target: ShareTarget, selected: Bool, highlightText: String? = nil) {

        displayNameLabel.attributedText =
            displayNameAttributedString(target.displayName, highlightText: highlightText)

        avatarImageView.setImage(target.avatarURL, placeholder: target.placeholderImage())

        let selectedImage = selected ?
            UIImage(named: "friend_check_on", in: .frameworkBundle, compatibleWith: nil) :
            UIImage(named: "friend_check_off", in: .frameworkBundle, compatibleWith: nil)
        tickImageView.image = selectedImage
    }
}
