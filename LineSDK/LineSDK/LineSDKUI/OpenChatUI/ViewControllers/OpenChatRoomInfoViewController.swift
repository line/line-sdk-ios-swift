//
//  OpenChatRoomInfoViewController.swift
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

class OpenChatRoomInfoViewController: UITableViewController {
    
    enum Design {
        static var backgroundColor: UIColor { return .systemGroupedBackground }
    }
    
    let onClose = Delegate<OpenChatRoomInfoViewController, Void>()
    let onNext = Delegate<OpenChatCreatingFormItem, Void>()
    
    /// The pre-selected category in the list.
    var suggestedCategory: OpenChatCategory = .notSelected
    
    var formItem = OpenChatCreatingFormItem() {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - Setting entries
    private lazy var roomName: RoomNameText = {
        let entry = RoomNameText()
        entry.onTextUpdated.delegate(on: self) { (self, text) in
            self.formItem.roomName = text
        }
        return entry
    }()
    
    private lazy var roomDescription: RoomDescriptionText = {
        let entry = RoomDescriptionText()
        entry.onTextUpdated.delegate(on: self) { (self, text) in
            self.formItem.roomDescription = text
        }
        entry.onTextHeightUpdated.delegate(on: self) { (self, _) in
            // This updates the cell height in the table view.
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        return entry
    }()
    
    private lazy var category: Option<OpenChatCategory> = {
        let entry = Option<OpenChatCategory>(
            title: Localization.string("openchat.create.room.category"),
            options: OpenChatCategory.allCases,
            selectedOption: suggestedCategory
        )
        entry.onValueChange.delegate(on: self) { (self, selected) in
            self.formItem.category = selected
        }
        entry.onPresenting.delegate(on: self) { (self, _) in
            return self
        }
        return entry
    }()
    
    private lazy var enableSearch: Toggle = {
        let entry = Toggle(
            title: Localization.string("openchat.create.room.search"),
            initialValue: formItem.allowSearch
        )
        entry.onValueChange.delegate(on: self) { (self, allowSearch) in
            self.formItem.allowSearch = allowSearch
        }
        return entry
    }()
    
    private lazy var sections: [FormSection] = [
        FormSection(
            entries: [roomName],
            footerText: nil),
        FormSection(
            entries: [roomDescription],
            footerText: Localization.string("openchat.create.room.description.guide")),
        FormSection(
            entries: [category],
            footerText: Localization.string("openchat.create.room.category.guide")),
        FormSection(
            entries: [enableSearch],
            footerText: Localization.string("openchat.create.room.search.guide")),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Design.backgroundColor
        setupNavigationBar()
        setupTableView()
        
        updateViews()
    }
    
    private func setupTableView() {
        tableView.keyboardDismissMode = .interactive
    }
    
    private func setupNavigationBar() {
        
        title = Localization.string("openchat.create.room.title")
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(bundleNamed: "navi_icon_close"),
            style: .plain,
            target: self,
            action: #selector(closeForm)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Localization.string("common.next"),
            style: .plain,
            target: self,
            action: #selector(nextPage)
        )
    }
    
    @objc private func closeForm() {
        view.endEditing(true)
        onClose.call(self)
    }
    
    @objc private func nextPage() {
        view.endEditing(true)
        
        formItem.normalize()
        onNext.call(formItem)
    }
    
    private func updateViews() {
        navigationItem.rightBarButtonItem?.isEnabled = !formItem.roomName.isEmpty
    }
}

// MARK: - Table view related methods
extension OpenChatRoomInfoViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].formEntries.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].formEntries[indexPath.row].cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].renderer.footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].renderer.heightOfFooterView(in: tableView.frame.width)
    }
}

// MARK: - Factory
extension OpenChatRoomInfoViewController {
    static func createViewController(
        _ controller: OpenChatCreatingController
    ) -> (OpenChatCreatingNavigationController, OpenChatRoomInfoViewController)
    {
        let viewController = OpenChatRoomInfoViewController(style: .grouped)
        let navigation = OpenChatCreatingNavigationController(rootViewController: viewController)
        navigation.controller = controller
        return (navigation, viewController)
    }
}
