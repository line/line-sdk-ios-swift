//
//  OpenChatRoomInfoViewController.swift
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

class OpenChatRoomInfoViewController: UITableViewController {
    
    enum Design {
        static var backgroundColor: UIColor { return .LineSDKSystemGroupedBackground }
    }
    
    let onClose = Delegate<OpenChatRoomInfoViewController, Void>()
    let onNext = Delegate<OpenChatCreatingFormItem, Void>()
    
    var formItem = OpenChatCreatingFormItem() {
        didSet {
            print("Item Updated: \(formItem)")
            updateViews()
        }
    }
    
    lazy var roomName: RoomNameText = {
        let entry = RoomNameText()
        entry.onTextUpdated.delegate(on: self) { (self, text) in
            self.formItem.roomName = text
        }
        return entry
    }()
    
    lazy var roomDescription: RoomDescriptionText = {
        let entry = RoomDescriptionText()
        entry.onTextUpdated.delegate(on: self) { (self, text) in
            self.formItem.roomDescription = text
        }
        entry.onTextHeightUpdated.delegate(on: self) { (self, _) in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        return entry
    }()
    
    lazy var category: Option<OpenChatCategory> = {
        let entry = Option<OpenChatCategory>(title: "Category", options: OpenChatCategory.allCases)
        entry.onValueChange.delegate(on: self) { (self, selected) in
            self.formItem.category = selected
        }
        entry.onPresenting.delegate(on: self) { (self, _) in
            return self
        }
        return entry
    }()
    
    lazy var enableSearch: Toggle = {
        let entry = Toggle(title: "Allow search", initialValue: formItem.allowSearch)
        entry.onValueChange.delegate(on: self) { (self, allowSearch) in
            self.formItem.allowSearch = allowSearch
        }
        return entry
    }()
    
    lazy var sections: [FormSection] = [
        FormSection(entries: [roomName], footerText: "The profile photo will also be set as its wallpaper."),
        FormSection(entries: [roomDescription], footerText: "Enter keywords using #hashtags"),
        FormSection(entries: [category], footerText: "Your OpenChat will be displayed in the selected category."),
        FormSection(entries: [enableSearch], footerText: "Others can search for this OpenChat by its name or description."),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Design.backgroundColor
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.keyboardDismissMode = .interactive
    }
    
    private func setupNavigationBar() {
        
        title = "Creating OpenChat"
        
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
            title: "Next",
            style: .plain,
            target: self,
            action: #selector(nextPage)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc private func closeForm() {
        onClose.call(self)
    }
    
    @objc private func nextPage() {
        onNext.call(formItem)
    }
    
    private func updateViews() {
        navigationItem.rightBarButtonItem?.isEnabled = !formItem.roomName.isEmpty
    }
}

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

extension OpenChatRoomInfoViewController {
    static func createViewController(
        _ controller: OpenChatController
    ) -> (OpenChatCreatingNavigationController, OpenChatRoomInfoViewController)
    {
        let viewController = OpenChatRoomInfoViewController(style: .grouped)
        let navigation = OpenChatCreatingNavigationController(rootViewController: viewController)
        navigation.controller = controller
        return (navigation, viewController)
    }
}
