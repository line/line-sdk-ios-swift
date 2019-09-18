//
//  SelectedTargetViewCell.swift
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

class SelectedTargetPanelCell: UICollectionViewCell {

    enum Design {
        static let size = CGSize(width: 50, height: 66)
        static let avatarFrame = CGRect(x: 0, y: 4, width: 45, height: 45)
        static let nameLabelTopSpacing: CGFloat = 1
        static let deleteSize = CGSize(width: 21, height: 21)

        static var textColor: UIColor { return .compatibleColor(light: 0x596478, dark: 0xEBEBF5) }
        static var font: UIFont { return .systemFont(ofSize: 12) }
    }

    static let reuseIdentifier = String(describing: self)

    private let avatarImageView: DownloadableImageView = {
        let imageView = DownloadableImageView(frame: Design.avatarFrame)
        imageView.layer.cornerRadius = Design.avatarFrame.width / 2;
        imageView.clipsToBounds = true
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = Design.font
        label.textColor = Design.textColor
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    private let deleteIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(bundleNamed: "list_icon_delete_normal")
        return imageView
    }()

    func setShareTarget(_ target: ShareTarget) {
        nameLabel.text = target.displayName
        avatarImageView.setImage(target.avatarURL, placeholder: target.placeholderImage)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupLayouts()
    }

    private func setupSubviews() {
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(deleteIconImageView)
    }

    private func setupLayouts() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: Design.nameLabelTopSpacing),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: Design.avatarFrame.maxX - Design.size.width),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor),
            ])

        deleteIconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteIconImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            deleteIconImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            deleteIconImageView.widthAnchor.constraint(equalToConstant: Design.deleteSize.width),
            deleteIconImageView.heightAnchor.constraint(equalToConstant: Design.deleteSize.height),
            ])
    }
}
