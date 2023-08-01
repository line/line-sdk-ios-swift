//
//  OpenChatUserProfileViewController.swift
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

class OpenChatUserProfileViewController: UIViewController {
    
    enum Design {
        static var backgroundColor: UIColor { return .systemGroupedBackground }
    }
    
    struct TextViewStyle: CountLimitedTextViewStyle {
        let font: UIFont = .systemFont(ofSize: 22, weight: .semibold)
        let textColor: UIColor = .label
        let placeholderFont: UIFont = .systemFont(ofSize: 22, weight: .semibold)
        let placeholderColor = UIColor.secondaryLabel.withAlphaComponent(0.7)
        let textCountLabelFont: UIFont = .systemFont(ofSize: 12)
        let textCountLabelColor: UIColor = .secondaryLabel
        let showCountLimitLabel = false
        let showUnderBorderLine = true
    }
    
    var formItem: OpenChatCreatingFormItem! {
        didSet {
            updateViews()
        }
    }
    
    let onProfileDone = Delegate<OpenChatCreatingFormItem, Void>()
    
    private var containerBottomConstraint: NSLayoutConstraint?
    private var textViewHeightConstraint: NSLayoutConstraint?
    
    private let textViewVerticalSpacing: CGFloat = 20
    private let textViewInitialContentHeight: CGFloat = 43
    
    // MARK: - Subviews
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nameTextView, nickNameTipLabel])

        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.backgroundColor = UIColor.yellow.withAlphaComponent(0.4)
        return stackView
    }()
    
    private lazy var nameTextView: CountLimitedTextView = {
        let textView = CountLimitedTextView(style: TextViewStyle())
        textView.placeholderText = Localization.string("openchat.create.profile.input.placeholder")
        textView.maximumCount = 20
        textView.text = self.formItem.userName
        
        textView.onTextUpdated.delegate(on: self) { (self, name) in
            self.formItem.userName = name
        }
        textView.onTextViewChangeContentSize.delegate(on: self) { (self, size) in
            self.textViewHeightConstraint?.constant =
                self.textViewVerticalSpacing * 2 + max(size.height, self.textViewInitialContentHeight)
        }
        textView.onTextCountLimitReached.delegate(on: self) { (self, _) in
            let alreadyShown = self.textCountLimitationToast != nil
            self.textCountLimitationToast?.dismiss(fadeOut: false)
            self.textCountLimitationToast = ToastView.show(
                text: Localization.string("openchat.create.profile.input.max.count"),
                in: self.view,
                fadeIn: !alreadyShown
            )
        }
        textView.onShouldReplaceText.delegate(on: self) { (self, value) in
            let (_, text) = value
            if text.containsNewline {
                self.view.endEditing(false)
                return false
            }
            return true
        }
        return textView
    }()

    private lazy var nickNameTipLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor.secondaryLabel.withAlphaComponent(0.7)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = String(format: Localization.string("openchat.create.profile.input.guide"), formItem.roomName)
        return label
    }()
    
    // Conforming to `KeyboardObservable`
    var keyboardObservers: [NotificationToken] = []
    
    var contentViewBottomConstraint: NSLayoutConstraint?
    
    private weak var textCountLimitationToast: ToastView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Design.backgroundColor
        
        setupSubviews()
        setupLayouts()
        setupNavigationBar()
        
        updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addKeyboardObserver()
        
        nameTextView.textView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeKeyboardObserver()
        super.viewDidDisappear(animated)
    }
    
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    }
    
    private func setupLayouts() {
        
        contentViewBottomConstraint = scrollView.bottomAnchor.constraint(equalTo: safeBottomAnchor)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeTopAnchor),
            contentViewBottomConstraint!
        ])
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -12),
        ])
        
        nameTextView.translatesAutoresizingMaskIntoConstraints = false
        textViewHeightConstraint = nameTextView.heightAnchor.constraint(
            equalToConstant: textViewVerticalSpacing * 2 + textViewInitialContentHeight
        )
        NSLayoutConstraint.activate([
            nameTextView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 32),
            nameTextView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -32),
            textViewHeightConstraint!
        ])
        
        nickNameTipLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nickNameTipLabel.widthAnchor.constraint(equalTo: nameTextView.widthAnchor, multiplier: 0.75)
        ])
    }
    
    private func setupNavigationBar() {
        title = Localization.string("openchat.create.profile.title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done, target: self, action: #selector(profileDone)
        )
    }
    
    private func handleKeyboardChange(_ keyboardInfo: KeyboardInfo) {
        if keyboardInfo.isVisible, let endFrame = keyboardInfo.endFrame {
            contentViewBottomConstraint?.constant = -endFrame.height
        } else {
            contentViewBottomConstraint?.constant = 0
        }
        UIView.animate(withDuration: keyboardInfo.duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateViews() {
        navigationItem.rightBarButtonItem?.isEnabled = !formItem.userName.isEmpty
    }
    
    @objc private func profileDone() {
        view.endEditing(false)
        
        formItem.normalize()
        onProfileDone.call(formItem)
    }
}

extension OpenChatUserProfileViewController: KeyboardObservable {
    func keyboardInfoWillChange(keyboardInfo: KeyboardInfo) {
        handleKeyboardChange(keyboardInfo)
    }
}
