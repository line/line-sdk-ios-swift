//
//  ShareRootViewController.swift
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

class ShareRootViewController: UIViewController {

    struct OnSendingSuccessData {
        let messages: [MessageConvertible]
        let targets: [ShareTarget]
    }

    struct OnSendingFailureData {
        let messages: [MessageConvertible]
        let targets: [ShareTarget]
        let error: LineSDKError
    }

    typealias ColumnIndex = ColumnDataStore<ShareTarget>.ColumnIndex

    private let store = ColumnDataStore<ShareTarget>(columnCount: MessageShareTargetType.allCases.count)

    // States
    @objc dynamic private var allLoaded: Bool = false

    // Observers
    private var selectingObserver: NotificationToken!
    private var deselectingObserver: NotificationToken!

    private var loadedObserver: NSKeyValueObservation?

    let onCancelled      = Delegate<(), Void>()
    let onLoadingFailed  = Delegate<(MessageShareTargetType, LineSDKError), Void>()
    let onSendingMessage = Delegate<[ShareTarget], [MessageConvertible]>()

    let onSendingSuccess = Delegate<OnSendingSuccessData, Void>()
    let onSendingFailure = Delegate<OnSendingFailureData, Void>()
    let onShouldDismiss  = Delegate<(), Bool>()

    private lazy var panelContainer = UILayoutGuide()
    private lazy var panelViewController = SelectedTargetPanelViewController(store: store)

    var messages: [MessageConvertible]?

    var selectedCount: Int {
        return store.selectedIndexes.count
    }

    private lazy var pageViewController: PageViewController = {
        let controllers = MessageShareTargetType.allCases
            .map { index -> ShareTargetSelectingViewController in
                let controller = ShareTargetSelectingViewController(store: store, columnIndex: index.rawValue)
                // Force load view for pages to setup table view initial state.
                _ = controller.view
                return controller
            }

        controllers.forEach { $0.delegate = self }

        let pages = zip(MessageShareTargetType.allCases, controllers).map {
            index, controller -> PageViewController.Page in
            return .init(viewController: controller, title: index.title)
        }

        return PageViewController(pages: pages)
    }()

    deinit {
        ImageManager.shared.purgeCache()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "LINE"
        navigationItem.leftBarButtonItem =
            UIBarButtonItem(
                title: Localization.string("common.action.close"),
                style: .plain,
                target: self,
                action: #selector(cancelSharing))


        setupSubviews()
        setupLayouts()

        loadGraphList()
        setupObservers()
    }

    private func setupSubviews() {
        addChild(pageViewController, to: view)

        view.addLayoutGuide(panelContainer)
        addChild(panelViewController, to: panelContainer)
    }

    private func setupLayouts() {
        NSLayoutConstraint.activate([
            panelContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            panelContainer.topAnchor.constraint(
                equalTo: safeBottomAnchor,
                constant: -SelectedTargetPanelViewController.Design.height)
            ])
    }

    private func setupObservers() {
        selectingObserver = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidSelect, object: store, queue: nil)
        {
            [unowned self] noti in
            self.handleSelectingChange(noti)
        }

        deselectingObserver = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidDeselect, object: store, queue: nil)
        {
            [unowned self] noti in
            self.handleSelectingChange(noti)
        }
    }
}

// MARK: - Controller Actions
extension ShareRootViewController {
    @objc private func cancelSharing() {
        onCancelled.call()
    }
}


// MARK: - Controller Actions
extension ShareRootViewController {

    private func loadGraphList() {

        let friendsRequest = GetShareFriendsRequest(sort: .relation)
        let chainedFriendsRequest = ChainedPaginatedRequest(originalRequest: friendsRequest)
        chainedFriendsRequest.onPageLoaded.delegate(on: self) { (self, response) in
            self.store.append(data: response.friends, to: MessageShareTargetType.friends.rawValue)
        }

        let groupsRequest = GetShareGroupsRequest()
        let chainedGroupsRequest = ChainedPaginatedRequest(originalRequest: groupsRequest)
        chainedGroupsRequest.onPageLoaded.delegate(on: self) { (self, response) in
            self.store.append(data: response.groups, to: MessageShareTargetType.groups.rawValue)
        }

        let sendingDispatchGroup = DispatchGroup()

        sendingDispatchGroup.enter()
        Session.shared.send(chainedFriendsRequest) { result in
            sendingDispatchGroup.leave()
            switch result {
            case .success:
                break
            case .failure(let error):
                self.onLoadingFailed.call((.friends, error))
            }
        }

        sendingDispatchGroup.enter()
        Session.shared.send(chainedGroupsRequest) { result in
            sendingDispatchGroup.leave()
            switch result {
            case .success:
                break
            case .failure(let error):
                self.onLoadingFailed.call((.groups, error))
            }
        }

        sendingDispatchGroup.notify(queue: .main) {
            self.allLoaded = true
        }
    }

    private func handleSelectingChange(_ notification: Notification) {
        if selectedCount == 0 {
            navigationItem.rightBarButtonItem = nil
        } else {
            let title = Localization.string("common.action.send")
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "\(title) (\(selectedCount))", style: .plain, target: self, action: #selector(sendMessage))
        }
    }

    @objc private func sendMessage() {
        let selected = store.selectedData

        // `onSendingMessage` is expected to be always delegated.
        let messages = onSendingMessage.call(selected)!

        func callbackFailure(_ error: LineSDKError) {
            let failureData = OnSendingFailureData(messages: messages, targets: selected, error: error)
            self.onSendingFailure.call(failureData)
        }

        func callbackSuccess(_ response: Unit) {
            let successData = OnSendingSuccessData(messages: messages, targets: selected)
            self.onSendingSuccess.call(successData)
        }

        let indicator = LoadingIndicator.add(to: view)
        API.getMessageSendingOneTimeToken(userIDs: selected.map { $0.targetID }) { result in
            switch result {
            case .success(let token):
                API.multiSendMessages(messages, withMessageToken: token) { result in
                    indicator.remove()
                    switch result {
                    case .success(let response): callbackSuccess(response)
                    case .failure(let error):    callbackFailure(error)
                    }

                    let shouldDismiss = self.onShouldDismiss.call() ?? true
                    if shouldDismiss {
                        self.dismiss(animated: true)
                    }
                }
            case .failure(let error):
                indicator.remove()
                callbackFailure(error)
            }
        }
    }
}

// MARK: - Selecting view controller delegate
extension ShareRootViewController: ShareTargetSelectingViewControllerDelegate {
    func shouldSearchStart(_ viewController: ShareTargetSelectingViewController) -> Bool {
        if allLoaded { return true }

        let indicator = LoadingIndicator.add(to: view)
        loadedObserver = observe(\.allLoaded, options: .new) { [weak self] controller, change in
            guard let self = self else { return }
            if let loaded = change.newValue, loaded {
                indicator.remove()
                self.loadedObserver = nil
                viewController.continueSearch()
            }
        }

        return false
    }

    func correspondingSelectedPanelViewController(
        for viewController: ShareTargetSelectingViewController
    ) -> SelectedTargetPanelViewController
    {
        return panelViewController
    }

    func pageViewController(
        for viewController: ShareTargetSelectingViewController
    ) -> PageViewController
    {
        return pageViewController
    }
}
