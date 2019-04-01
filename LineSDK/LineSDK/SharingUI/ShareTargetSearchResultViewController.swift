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

final class ShareTargetSearchResultViewController: UITableViewController, ShareTargetTableViewStyling {

    typealias ColumnIndex = ColumnDataStore<ShareTarget>.ColumnIndex

    var store: ColumnDataStore<ShareTarget>!

    var selectingObserver: NotificationToken!
    var deselectingObserver: NotificationToken!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    deinit {
        print("Deinit: \(self)")
    }

    var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            filteredIndexes = MessageShareTargetType.allCases.map {
                store.indexes(atColumn: $0.rawValue) { $0.displayName.contains(searchText) }
            }
        }
    }

    var filteredIndexes: [[ColumnIndex]] = [] {
        didSet { tableView.reloadData() }
    }

    func start() {
        setupObservers()
    }

    func clear() {
        stopObservers()
        searchText = ""
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

    private func stopObservers() {
        selectingObserver = nil
        deselectingObserver = nil
    }

    private func handleSelectingChange(_ notification: Notification) {
        guard let index = notification.userInfo?[LineSDKNotificationKey.selectingIndex] as? ColumnIndex else {
            assertionFailure("The `columnDataStoreSelected` notification should contain " +
                "`selectingIndex` in `userInfo`. But got `userInfo`: \(String(describing: notification.userInfo))")
            return
        }

        guard let row = filteredIndexes[index.column].firstIndex(of: index) else {
            return
        }

        let indexPath = IndexPath(row: row, section: index.column)

        if let cell = tableView.cellForRow(at: indexPath) as? ShareTargetSelectingTableCell {
            let target = store.data(at: index)
            let selected = store.isSelected(at: index)
            cell.setShareTarget(target, selected: selected, highlightText: searchText)
        }
    }

    private func setupTableView() {
        setupTableViewStyle()
        automaticallyAdjustsScrollViewInsets = false
        tableView.contentInset = UIEdgeInsets(top: expectedSearchBarHeight, left: 0, bottom: 0, right: 0)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return filteredIndexes.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredIndexes[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ShareTargetSelectingTableCell.reuseIdentifier,
            for: indexPath) as! ShareTargetSelectingTableCell

        let dataIndex = filteredIndexes[indexPath.section][indexPath.row]
        let target = store.data(at: dataIndex)
        let selected = store.isSelected(at: dataIndex)
        cell.setShareTarget(target, selected: selected, highlightText: searchText)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if filteredIndexes[section].isEmpty {
            return 0
        }
        return ShareTargetSelectingSectionHeaderView.Design.height
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if filteredIndexes[section].isEmpty {
            return nil
        }
        let view = ShareTargetSelectingSectionHeaderView(frame: .zero)
        view.titleLabel.text = MessageShareTargetType(rawValue: section)?.title
        return view
    }
}

extension ShareTargetSearchResultViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedIndex = filteredIndexes[indexPath.section][indexPath.row]
        let toggled = store.toggleSelect(atColumn: selectedIndex.column, row: selectedIndex.row)
        if !toggled {
            popSelectingLimitAlert(max: store.maximumSelectedCount)
        }
    }
}
