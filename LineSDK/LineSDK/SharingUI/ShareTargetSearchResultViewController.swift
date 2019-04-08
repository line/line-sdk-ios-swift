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
        get {
            return tableViewController.searchText
        }
        set {
            tableViewController.searchText = newValue
        }
    }

    private let store: ColumnDataStore<ShareTarget>

    private let tableViewController: ShareTargetSearchResultTableViewController

    var sectionOrder: [MessageShareTargetType] {
        get { return tableViewController.sectionOrder }
        set { tableViewController.sectionOrder = newValue }
    }

    var keyboardObserver: [NotificationToken] = []
    private var keyboardInfo: KeyboardInfo?

    private lazy var panelViewController = SelectedTargetPanelViewController(store: store)
    private lazy var panelContainer = UILayoutGuide()
    private var panelTopConstraint: NSLayoutConstraint?

    init(store: ColumnDataStore<ShareTarget>) {
        self.store = store
        self.tableViewController = ShareTargetSearchResultTableViewController(store: store)
        super.init(nibName: nil, bundle: nil)
        addKeyboardObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        automaticallyAdjustsScrollViewInsets = false

        addChild(tableViewController, to: view)

        setupSelectPanel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start() {
        tableViewController.start()
    }

    func clear() {
        tableViewController.clear()
    }
}

// MARK: - SelectedTargetPanelViewController

extension ShareTargetSearchResultViewController {
    private func setupSelectPanel() {
        view.addLayoutGuide(panelContainer)
        addChild(panelViewController, to: panelContainer)

        NSLayoutConstraint.activate([
            panelContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            ])
        panelTopConstraint = newPanelTopConstraint(keyboardInfo: keyboardInfo)
    }

    private func newPanelTopConstraint(keyboardInfo: KeyboardInfo?) -> NSLayoutConstraint {
        let constraint: NSLayoutConstraint
        if keyboardInfo?.isVisible == true, let y = keyboardInfo?.endFrame?.origin.y {
            constraint = panelContainer.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: y - SelectedTargetPanelViewController.Design.height
            )
        } else {
            constraint = panelContainer.topAnchor.constraint(
                equalTo: safeBottomAnchor,
                constant: -SelectedTargetPanelViewController.Design.height
            )
        }
        constraint.isActive = true
        return constraint
    }

    private func handleKeyboardChange(_ keyboardInfo: KeyboardInfo) {
        self.keyboardInfo = keyboardInfo
        guard viewIfLoaded?.window != nil else { return }

        panelTopConstraint?.isActive = false
        panelTopConstraint = newPanelTopConstraint(keyboardInfo: keyboardInfo)

        UIView.animate(
            withDuration: keyboardInfo.duration,
            delay: 0,
            options: .beginFromCurrentState,
            animations: {
                UIView.setAnimationCurve(keyboardInfo.animationCurve)
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

extension ShareTargetSearchResultViewController: KeyboardObservable {
    func keyboardInfoWillChange(keyboardInfo: KeyboardInfo) {
        handleKeyboardChange(keyboardInfo)
    }
}
