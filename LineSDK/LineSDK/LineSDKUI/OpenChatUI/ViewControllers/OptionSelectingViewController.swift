//
//  OptionSelectingViewController.swift
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

class OptionSelectingViewController<T: CustomStringConvertible & Equatable>: UITableViewController {
    
    let onSelected = Delegate<T, Void>()
    
    private var data: [T] = []
    private var selected: T?
    
    private var cellResultIdentifier: String { return String(describing: OptionSelectingViewController.self) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellResultIdentifier)
    }
    
    private func setupNavigationBar() {
        title = Localization.string("openchat.create.room.category")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(bundleNamed: "navi_icon_close"),
            style: .plain,
            target: self,
            action: #selector(closeCategory)
        )
    }
    
    @objc private func closeCategory() {
        dismiss(animated: true)
    }
    
    // MARK: - Table view related methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellResultIdentifier, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = data[indexPath.row].description
        if data[indexPath.row] == selected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // For visual effect that the target option was selected
        selected = data[indexPath.row]
        tableView.reloadData()
        
        closeCategory()
        onSelected.call(data[indexPath.row])
    }
}

// MARK: - Factory
extension OptionSelectingViewController {
    static func createViewController(
        data: [T],
        selected: T?
    ) -> (UINavigationController, OptionSelectingViewController)
    {
        let optionSelecting = OptionSelectingViewController<T>(style: .grouped)
        optionSelecting.data = data
        optionSelecting.selected = selected
        
        let navigation = StyleNavigationController(rootViewController: optionSelecting)
        return (navigation, optionSelecting)
    }
}
