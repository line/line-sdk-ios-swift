//
//  ShareTargetSearchResultViewController.swift
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

class ShareTargetSearchResultViewController: UIViewController {

    var searchText: String {
        get { return tableViewController.searchText }
        set { tableViewController.searchText = newValue }
    }

    var sectionOrder: [MessageShareTargetType] {
        get { return tableViewController.sectionOrder }
        set { tableViewController.sectionOrder = newValue }
    }

    // Conforming to `KeyboardObservable`
    var keyboardObservers: [NotificationToken] = []

    private let store: ColumnDataStore<ShareTarget>
    private let tableViewController: ShareTargetSearchResultTableViewController

    private (set) lazy var panelViewController = SelectedTargetPanelViewController(store: store)
    private let panelContainer = UILayoutGuide()

    private var panelBottomConstraint: NSLayoutConstraint?
    private var panelHeightConstraint: NSLayoutConstraint?

    init(store: ColumnDataStore<ShareTarget>) {
        self.store = store
        self.tableViewController = ShareTargetSearchResultTableViewController(store: store)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        setupSubviews()
        setupLayouts()
    }

    private func setupSubviews() {
        addChild(tableViewController, to: view)

        view.addLayoutGuide(panelContainer)
        addChild(panelViewController, to: panelContainer)
    }

    private func setupLayouts() {
        NSLayoutConstraint.activate([
            panelContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])

        panelBottomConstraint = panelContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        panelBottomConstraint!.isActive = true

        let panelHeight = SelectedTargetPanelViewController.Design.height + safeAreaInsets.bottom
        panelHeightConstraint = panelContainer.heightAnchor.constraint(equalToConstant: panelHeight)
        panelHeightConstraint!.isActive = true
    }

    func start() {
        tableViewController.startObserving()
    }

    func clear() {
        tableViewController.stopObserving()
    }
}

// MARK: - SelectedTargetPanelViewController
extension ShareTargetSearchResultViewController {

    private func updatePanelBottomConstraint(keyboardInfo: KeyboardInfo) {

        panelBottomConstraint?.isActive = false
        panelHeightConstraint?.isActive = false

        let keyboardOverlayHeight: CGFloat
        let panelHeight: CGFloat
        if keyboardInfo.isVisible, let keyboardOrigin = keyboardInfo.endFrame?.origin
        {
            let viewFrameInWindow = view.convert(view.bounds, to: nil)
            keyboardOverlayHeight = max(0, viewFrameInWindow.maxY - keyboardOrigin.y)
            panelHeight = SelectedTargetPanelViewController.Design.height
        } else {
            keyboardOverlayHeight = 0
            panelHeight = SelectedTargetPanelViewController.Design.height + safeAreaInsets.bottom
        }

        let bottomConstraint = panelContainer.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -keyboardOverlayHeight)
        bottomConstraint.isActive = true
        panelBottomConstraint = bottomConstraint

        let heightConstraint = panelContainer.heightAnchor.constraint(equalToConstant: panelHeight)
        heightConstraint.isActive = true
        panelHeightConstraint = heightConstraint
    }

    private func handleKeyboardChange(_ keyboardInfo: KeyboardInfo) {
        // Wait for iOS layout the current vc. It happens when presenting `self`
        // with a `.formSheet` style in landscape mode.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updatePanelBottomConstraint(keyboardInfo: keyboardInfo)
            UIView.animate(withDuration: keyboardInfo.duration) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension ShareTargetSearchResultViewController: KeyboardObservable {
    func keyboardInfoWillChange(keyboardInfo: KeyboardInfo) {
        if !isViewLoaded {
            // Force load view to make initial layout
            _ = view
        }
        handleKeyboardChange(keyboardInfo)
    }
}
