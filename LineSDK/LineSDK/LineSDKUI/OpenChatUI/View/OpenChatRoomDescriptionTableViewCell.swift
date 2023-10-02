//
//  OpenChatRoomDescriptionTableViewCell.swift
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

class OpenChatRoomDescriptionTableViewCell: UITableViewCell {
    
    struct TextViewStyle: CountLimitedTextViewStyle {
        let font: UIFont = .boldSystemFont(ofSize: 15)
        let textColor: UIColor = .label
        let placeholderFont: UIFont = .boldSystemFont(ofSize: 15)
        let placeholderColor: UIColor = .secondaryLabel
        let textCountLabelFont: UIFont = .systemFont(ofSize: 12)
        let textCountLabelColor: UIColor = .secondaryLabel
    }
    
    lazy var textView: CountLimitedTextView = {
        let textView = CountLimitedTextView(style: TextViewStyle())
        textView.maximumTextContentHeight = 100
        return textView
    }()
    
    private var contentHeightConstraint: NSLayoutConstraint!
    private let textViewVerticalSpacing: CGFloat = 20
    private let textViewInitialContentHeight: CGFloat = 34
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)
        
        setupSubviews()
        setupLayouts()
    }
    
    private func setupSubviews() {
        contentView.addSubview(textView)
    }
    
    private func setupLayouts() {
        let contentHeight = contentView.heightAnchor.constraint(
            equalToConstant: textViewVerticalSpacing * 2 + textViewInitialContentHeight
        )
        contentHeight.priority = .init(999)
        contentHeight.isActive = true
        
        contentHeightConstraint = contentHeight
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -13),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func updateContentHeightConstraint(_ contentHeight: CGFloat) {
        let height = textViewVerticalSpacing * 2 + max(textViewInitialContentHeight, contentHeight)
        contentHeightConstraint.constant = height
    }
    
    @objc private func tapped() {
        let textView = self.textView.textView
        if !textView.isFirstResponder, textView.canBecomeFirstResponder {
            textView.becomeFirstResponder()
        }
    }
}
