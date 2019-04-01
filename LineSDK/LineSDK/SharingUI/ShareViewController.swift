//
//  ShareViewController.swift
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

public protocol ShareViewControllerDelegate: AnyObject {
    func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError: LineSDKError)
    func shareViewControllerDidCancelSharing(_ controller: ShareViewController)
}

extension ShareViewControllerDelegate {
    public func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError: LineSDKError) { }
    public func shareViewControllerDidCancelSharing(_ controller: ShareViewController) { }
}

public enum MessageShareTargetType: Int, CaseIterable {
    case friends
    case groups

    var title: String {
        switch self {
        case .friends: return Localization.string("shareRecipient.section.friends.title")
        case .groups: return Localization.string("shareRecipient.section.groups.title")
        }
    }

    var requiredGraphPermission: LoginPermission? {
        switch self {
        case .friends: return .friends
        case .groups: return .groups
        }
    }
}

public enum MessageShareAuthorizationStatus {
    case lackOfToken
    case lackOfPermissions([LoginPermission])
    case authorized
}

public class ShareViewController: UINavigationController {

    enum Design {
        static var navigationBarTintColor: UIColor { return .init(hex6: 0x283145) }
        static var preferredStatusBarStyle: UIStatusBarStyle  { return  .lightContent }
        static var navigationBarTextColor:  UIColor { return  .white }
    }

    typealias ColumnIndex = ColumnDataStore<ShareTarget>.ColumnIndex

    public var navigationBarTintColor = Design.navigationBarTintColor { didSet { updateNavigationStyles() } }
    public var navigationBarTextColor = Design.navigationBarTextColor { didSet { updateNavigationStyles() } }
    public var statusBarStyle = Design.preferredStatusBarStyle { didSet { updateNavigationStyles() } }

    // Root & Data
    private var rootViewController: UIViewController! { didSet { print("Set") } }
    private var store: ColumnDataStore<ShareTarget>!

    // States
    @objc dynamic private var allLoaded: Bool = false

    // Observers
    private var selectingObserver: NotificationToken!
    private var deselectingObserver: NotificationToken!

    private var loadedObserver: NSKeyValueObservation?

    public weak var shareDelegate: ShareViewControllerDelegate?

    private lazy var selectedTargetView = SelectedTargetView()

    private var indicatorContainer: UIView?

    // MARK: - Initializers
    public init() {
        let store = ColumnDataStore<ShareTarget>(columnCount: MessageShareTargetType.allCases.count)
        let controllers = MessageShareTargetType.allCases.map { index -> ShareTargetSelectingViewController in
            let controller = ShareTargetSelectingViewController(store: store, columnIndex: index.rawValue)
            // Force load view for pages to setup table view initial state.
            _ = controller.view
            return controller
        }

        let pages = zip(MessageShareTargetType.allCases, controllers).map {
            index, controller -> PageViewController.Page in
            return .init(viewController: controller, title: index.title)
        }

        let rootViewController = PageViewController(pages: pages)

        super.init(rootViewController: rootViewController)

        self.store = store
        self.rootViewController = rootViewController
        controllers.forEach { $0.delegate = self }

        updateNavigationStyles()
    }

    deinit {
        ImageManager.shared.purgeCache()
    }

    @objc
    func foo() {
        selectedTargetView.setMode((selectedTargetView.mode == .show) ? .hide : .show,
                                   animated: true)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lift Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSubviews()
        setupLayouts()

        // default
        selectedTargetView.setMode(.hide, animated: false)

        // Wait for child view controllers setup themselves.
        loadGraphList()
        setupObservers()
    }

    // MARK: - Setup & Style
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }

    private func updateNavigationStyles() {

        rootViewController.title = "LINE"

        rootViewController.navigationItem.leftBarButtonItem =
            UIBarButtonItem(
                title: Localization.string("common.action.close"),
                style: .plain,
                target: self,
                action: #selector(cancelSharing))

        navigationBar.shadowImage = UIImage()
        navigationBar.barTintColor = navigationBarTintColor
        navigationBar.tintColor = navigationBarTextColor
        navigationBar.titleTextAttributes = [.foregroundColor: navigationBarTextColor]
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
extension ShareViewController {
    @objc private func cancelSharing() {
        dismiss(animated: true) {
            self.shareDelegate?.shareViewControllerDidCancelSharing(self)
        }
    }

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
                self.shareDelegate?.shareViewController(self, didFailLoadingListType: .friends, withError: error)
            }
        }

        sendingDispatchGroup.enter()
        Session.shared.send(chainedGroupsRequest) { result in
            sendingDispatchGroup.leave()
            switch result {
            case .success:
                break
            case .failure(let error):
                self.shareDelegate?.shareViewController(self, didFailLoadingListType: .groups, withError: error)
            }
        }

        sendingDispatchGroup.notify(queue: .main) {
            self.allLoaded = true
        }
    }

    private func handleSelectingChange(_ notification: Notification) {
        let count = store.selected.count
        if count == 0 {
            rootViewController.navigationItem.rightBarButtonItem = nil
        } else {
            let title = Localization.string("common.action.send")
            rootViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "\(title) (\(count))", style: .plain, target: self, action: #selector(sendMessage))
        }
    }

    @objc private func sendMessage() {
        print("Send")
    }
}

// MARK: - Authorization Helpers
extension ShareViewController {
    public static func authorizationStatusForSendingMessage(to type: MessageShareTargetType)
        -> MessageShareAuthorizationStatus
    {
        guard let token = AccessTokenStore.shared.current else {
            return .lackOfToken
        }

        var lackPermissions = [LoginPermission]()
        if let required = type.requiredGraphPermission, !token.permissions.contains(required) {
            lackPermissions.append(required)
        }
        if !token.permissions.contains(.messageWrite) {
            lackPermissions.append(.messageWrite)
        }
        guard lackPermissions.isEmpty else {
            return .lackOfPermissions(lackPermissions)
        }
        return .authorized
    }
}

extension ShareViewController: ShareTargetSelectingViewControllerDelegate {
    func shouldSearchStart(_ viewController: ShareTargetSelectingViewController) -> Bool {
        if !allLoaded {
            addLoadingIndicator()
            loadedObserver = observe(\.allLoaded, options: .new) { [weak self] controller, change in
                guard let self = self else { return }
                if let loaded = change.newValue, loaded {
                    self.removeLoadingIndicator()
                    self.loadedObserver = nil
                    viewController.continueSearch()
                }
            }
        }
        return allLoaded
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
        rootViewController.view.addChildSubview(container)

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
