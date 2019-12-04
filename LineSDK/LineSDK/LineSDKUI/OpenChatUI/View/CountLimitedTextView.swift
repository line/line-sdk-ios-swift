//
//  CountLimitedTextView.swift
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

class CountLimitedTextView: UIView {
    
    let onTextUpdated = Delegate<String, Void>()
    
    var placeholderText: String? {
        didSet { placeholderLabel.text = placeholderText }
    }
    
    private var validator: TextCountValidator?
    
    var maximumCount: Int? = nil {
        didSet {
            validator = maximumCount.map { TextCountValidator(maxCount: $0) }
            validateString(textView.text)
        }
    }
    
    var text: String {
        get { return textView.text }
        set {
            textView.text = newValue
            textViewDidChange(textView)
            layoutIfNeeded()
        }
    }
    
    lazy private(set) var textView: VerticallyCenteredTextView = {
        let textView = VerticallyCenteredTextView()
        textView.backgroundColor = .clear
        textView.alwaysBounceVertical = false
        textView.alwaysBounceHorizontal = false
        textView.textColor = .LineSDKLabel
        textView.font = .boldSystemFont(ofSize: 18)
        textView.layer.borderWidth = 0
        textView.delegate = self
        
        return textView
    }()
    
    private(set) var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .LineSDKSecondaryLabel
        return label
    }()
    
    private(set) var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.setImage(UIImage(bundleNamed: "setting_icon_delete_normal"), for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(clearText), for: .touchUpInside)
        return button
    }()
    
    private(set) var textCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .LineSDKSecondaryLabel
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
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
    }
    
    @objc private func clearText() {
        text = ""
    }
    
    private func validateString(_ text: String) {
        guard let validator = validator, let maximumCount = maximumCount else {
            textCountLabel.isHidden = true
            return
        }
        textCountLabel.isHidden = false
        let validated = validator.validatedString(text)
        textView.text = validated
        textCountLabel.text = "\(validated.count)/\(maximumCount)"
    }
}

extension CountLimitedTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        placeholderLabel.isHidden = !textView.text.isEmpty
        clearButton.isHidden = textView.text.isEmpty
        
        guard textView.markedTextRange == nil else { return }
        validateString(textView.text)
        onTextUpdated.call(textView.text)
    }
}
