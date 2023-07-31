//
//  CountLimitedTextView.swift
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

protocol CountLimitedTextViewStyle {
    var font: UIFont { get }
    var textColor: UIColor { get }
    var placeholderFont: UIFont { get }
    var placeholderColor: UIColor { get }
    var textCountLabelFont: UIFont { get }
    var textCountLabelColor: UIColor { get }
    
    var showCountLimitLabel: Bool { get }
    var showUnderBorderLine: Bool { get }
}

extension CountLimitedTextViewStyle {
    var showCountLimitLabel: Bool { return true }
    var showUnderBorderLine: Bool { return false }
}

class CountLimitedTextView: UIView {
    
    var style: CountLimitedTextViewStyle {
        didSet {
            textView.font = style.font
            textView.textColor = style.textColor
            
            placeholderLabel.font = style.placeholderFont
            placeholderLabel.textColor = style.placeholderColor
            
            textCountLabel.font = style.textCountLabelFont
            textCountLabel.textColor = style.textCountLabelColor
            
            layoutIfNeeded()
        }
    }
    
    let onTextUpdated = Delegate<String, Void>()
    let onTextViewChangeContentSize = Delegate<CGSize, Void>()
    let onTextCountLimitReached = Delegate<(), Void>()
    
    let onShouldReplaceText = Delegate<(NSRange, String), Bool>()
    
    var maximumTextContentHeight: CGFloat?
    
    var placeholderText: String? {
        didSet { placeholderLabel.text = placeholderText }
    }

    var maximumCount: Int? = nil {
        didSet { textViewDidChange(textView) }
    }
    
    var text: String {
        get { return textView.text }
        set {
            textView.text = newValue
            textViewDidChange(textView)
        }
    }
    
    private(set) lazy var textView: VerticallyCenteredTextView = {
        let textView = VerticallyCenteredTextView()
        textView.backgroundColor = .clear
        textView.alwaysBounceVertical = false
        textView.alwaysBounceHorizontal = false
        textView.textColor = style.textColor
        textView.font = style.font
        textView.layer.borderWidth = 0
        textView.textContainerInset = .zero
        textView.delegate = self
        return textView
    }()
    
    private(set) lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = style.placeholderFont
        label.textColor = style.placeholderColor
        return label
    }()
    
    private(set) lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.setImage(UIImage(bundleNamed: "setting_icon_delete_normal"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        return button
    }()
    
    private(set) lazy var textCountLabel: UILabel = {
        let label = UILabel()
        label.font = style.textCountLabelFont
        label.textColor = style.textCountLabelColor
        return label
    }()
    
    private(set) lazy var underline: UIView? = {
        if self.style.showUnderBorderLine {
            let line = UIView()
            line.backgroundColor = style.placeholderColor
            return line
        } else {
            return nil
        }
    }()
    
    init(style: CountLimitedTextViewStyle) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupSubviews()
        setupLayouts()

    }
    
    private func setupSubviews() {
        addSubview(textView)
        addSubview(placeholderLabel)
        addSubview(clearButton)
        addSubview(textCountLabel)
        
        if let underline = underline {
            addSubview(underline)
        }
    }
    
    private func setupLayouts() {
        // Text View
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -39),
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
        ])
        
        // Count Label
        textCountLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textCountLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            textCountLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
        
        // Clear Button
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearButton.trailingAnchor
                .constraint(equalTo: trailingAnchor, constant: -13 + clearButton.contentEdgeInsets.right)
        ])
        
        // Placeholder
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0),
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        if let underline = underline {
            underline.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                underline.leadingAnchor.constraint(equalTo: placeholderLabel.leadingAnchor),
                underline.trailingAnchor.constraint(equalTo: clearButton.trailingAnchor),
                underline.topAnchor.constraint(equalTo: textView.bottomAnchor),
                underline.heightAnchor.constraint(equalToConstant: 1)
            ])
        }
    }
    
    @objc private func clearText() {
        text = ""
        textView.sizeToFit()
    }
    
    private func validateString(_ text: String) {
        guard let maximumCount = maximumCount else {
            textCountLabel.isHidden = true
            return
        }
        textCountLabel.isHidden = !style.showCountLimitLabel || false
        
        let trimmed = text.prefixNormalized.trimming(upper: maximumCount)
        let textCount = text.count
        if trimmed.count == text.count {
            // Nothing is trimmed
            textCountLabel.text = "\(textCount)/\(maximumCount)"
        } else {
            textView.text = trimmed
            textCountLabel.text = "\(trimmed.count)/\(maximumCount)"
            
            onTextCountLimitReached.call()
        }
    }
}

extension CountLimitedTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        placeholderLabel.isHidden = !textView.text.isEmpty
        clearButton.isHidden = textView.text.isEmpty
        
        guard textView.markedTextRange == nil else { return }
        validateString(textView.text)
        
        onTextUpdated.call(textView.text)
        
        if maximumTextContentHeight == nil || textView.contentSize.height <= maximumTextContentHeight! {
            textView.layoutIfNeeded()
            self.onTextViewChangeContentSize.call(textView.contentSize)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return onShouldReplaceText.call((range, text)) ?? true
    }
}
