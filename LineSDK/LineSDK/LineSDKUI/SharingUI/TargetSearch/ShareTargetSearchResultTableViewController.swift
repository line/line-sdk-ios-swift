//
//  ShareTargetSearchResultTableViewController.swift
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

final class ShareTargetSearchResultTableViewController: UITableViewController, ShareTargetTableViewStyling {

    // The order of search result section.
    var sectionOrder: [MessageShareTargetType] = [.friends, .groups]

    @objc dynamic var hasSearchResult: Bool = true
    
    var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            filteredIndexes = store.indexes {
                $0.displayName.localizedCaseInsensitiveContains(searchText)
            }
            hasSearchResult = searchText.isEmpty || filteredIndexes.contains { !$0.isEmpty }
        }
    }

    private typealias ColumnIndex = ColumnDataStore<ShareTarget>.ColumnIndex
    private let store: ColumnDataStore<ShareTarget>

    private var selectingObserver: NotificationToken!
    private var deselectingObserver: NotificationToken!

    init(store: ColumnDataStore<ShareTarget>) {
        self.store = store
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    private var filteredIndexes = [[ColumnIndex]](
        repeating: [], count: MessageShareTargetType.allCases.count)
    {
        didSet { tableView.reloadData() }
    }

    func startObserving() {
        setupObservers()
    }

    func stopObserving() {
        stopObservers()
        searchText = ""
    }

    private func setupObservers() {
        selectingObserver = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidSelect, object: store, queue: nil)
        {
            [unowned self] notification in
            self.handleSelectingChange(notification)
        }

        deselectingObserver = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidDeselect, object: store, queue: nil)
        {
            [unowned self] notification in
            self.handleSelectingChange(notification)
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

        let section = actualSection(index.column)
        let indexPath = IndexPath(row: row, section: section)

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
        return filteredIndexes[actualSection(section)].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ShareTargetSelectingTableCell.reuseIdentifier,
            for: indexPath
        ) as! ShareTargetSelectingTableCell

        let section = actualSection(indexPath.section)
        let dataIndex = filteredIndexes[section][indexPath.row]
        let target = store.data(at: dataIndex)
        let selected = store.isSelected(at: dataIndex)
        cell.setShareTarget(target, selected: selected, highlightText: searchText)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let section = actualSection(section)
        if filteredIndexes[section].isEmpty {
            return 0
        }
        return ShareTargetSelectingSectionHeaderView.Design.height
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = actualSection(section)
        if filteredIndexes[section].isEmpty {
            return nil
        }
        let view = ShareTargetSelectingSectionHeaderView(frame: .zero)
        view.titleLabel.text = MessageShareTargetType(rawValue: section)?.title
        return view
    }

    private func actualSection(_ section: Int) -> Int {
        return sectionOrder[section].rawValue
    }
}

extension ShareTargetSearchResultTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = actualSection(indexPath.section)
        let selectedIndex = filteredIndexes[section][indexPath.row]
        let toggled = store.toggleSelect(atColumn: selectedIndex.column, row: selectedIndex.row)
        if !toggled {
            popSelectingLimitAlert(max: store.maximumSelectedCount)
        }
    }
}
