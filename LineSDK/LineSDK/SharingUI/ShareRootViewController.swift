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

protocol ShareRootViewControllerDelegate: class {
    func shareRootViewController(
        _ controller: ShareRootViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError error: LineSDKError)
}

class ShareRootViewController: UIViewController {
    typealias ColumnIndex = ColumnDataStore<ShareTarget>.ColumnIndex

    private let store = ColumnDataStore<ShareTarget>(columnCount: MessageShareTargetType.allCases.count)

    // States
    @objc dynamic private var allLoaded: Bool = false

    // Observers
    private var selectingObserver: NotificationToken!
    private var deselectingObserver: NotificationToken!

    private var loadedObserver: NSKeyValueObservation?

    weak var shareDelegate: ShareRootViewControllerDelegate?

    private lazy var selectedTargetView = SelectedTargetView()

    private var indicatorContainer: UIView?

    private lazy var pageViewController: PageViewController = {
        let controllers = MessageShareTargetType.allCases.map { index -> ShareTargetSelectingViewController in
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

        setupSubviews()

        setupLayouts()

        // default
        selectedTargetView.setMode(.hide, animated: false)

        // Wait for child view controllers setup themselves.
        loadGraphList()
        setupObservers()
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

    private func setupSubviews() {
        addChild(pageViewController, to: view)
        view.addSubview(selectedTargetView)
    }

    private func setupLayouts() {
        selectedTargetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedTargetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectedTargetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            selectedTargetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectedTargetView.topAnchor.constraint(equalTo: safeBottomAnchor,
                                                    constant: -SelectedTargetView.Design.height)
            ])
    }
}

// MARK: - Controller Actions
extension ShareRootViewController {

    private func loadGraphList() {

        let friendsRequest = GetFriendsRequest(sort: .relation, pageToken: nil)
        let chainedFriendsRequest = ChainedPaginatedRequest(originalRequest: friendsRequest)
        chainedFriendsRequest.onPageLoaded.delegate(on: self) { (self, response) in
            self.store.append(data: response.friends, to: MessageShareTargetType.friends.rawValue)
        }

        let groupsRequest = GetGroupsRequest(pageToken: nil)
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
                self.shareDelegate?.shareRootViewController(self, didFailLoadingListType: .friends, withError: error)
            }
        }

        sendingDispatchGroup.enter()
        Session.shared.send(chainedGroupsRequest) { result in
            sendingDispatchGroup.leave()
            switch result {
            case .success:
                break
            case .failure(let error):
                self.shareDelegate?.shareRootViewController(self, didFailLoadingListType: .groups, withError: error)
            }
        }

        sendingDispatchGroup.notify(queue: .main) {
            self.allLoaded = true
        }
    }

    private func handleSelectingChange(_ notification: Notification) {
        let count = store.selected.count
        if count == 0 {
            navigationItem.rightBarButtonItem = nil
        } else {
            let title = Localization.string("common.action.send")
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "\(title) (\(count))", style: .plain, target: self, action: #selector(sendMessage))
        }
    }

    @objc private func sendMessage() {
        print("Send")
    }
}

// MARK: - Selecting view controller delegate
extension ShareRootViewController: ShareTargetSelectingViewControllerDelegate {
    func shouldSearchStart(_ viewController: ShareTargetSelectingViewController) -> Bool {
        if allLoaded {
            return true
        }

        addLoadingIndicator()
        loadedObserver = observe(\.allLoaded, options: .new) { [weak self] controller, change in
            guard let self = self else { return }
            if let loaded = change.newValue, loaded {
                self.removeLoadingIndicator()
                self.loadedObserver = nil
                viewController.continueSearch()
            }
        }

        return false
    }

    private func addLoadingIndicator() {
        let container = UIView(frame: .zero)
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .gray

        indicator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ])

        // Add the loading indicator container to root view controller (page), so user has a chance to
        // close the sharing UI by tapping "Close" button in the navigation bar.
        view.addChildSubview(container)

        indicator.startAnimating()

        indicatorContainer = container
    }

    private func removeLoadingIndicator() {
        guard let container = indicatorContainer else {
            return
        }
        container.removeFromSuperview()
    }
}
