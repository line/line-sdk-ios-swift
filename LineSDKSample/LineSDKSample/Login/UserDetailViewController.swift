//
//  UserDetailViewController.swift
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
import LineSDK

class UserDetailViewController: UITableViewController, CellCopyable {

    enum Section: Int {
        case user
        case token
        
        static var count: Int { return 2 }
    }
    
    var profile: UserProfile?
    var token: AccessToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailTableCell", for: indexPath)
        switch Section(rawValue: indexPath.section)! {
        case .user:
            configUserCell(cell, at: indexPath.row)
        case .token:
            configTokenCell(cell, at: indexPath.row)
        }
        return cell
    }
    
    private func configUserCell(_ cell: UITableViewCell, at row: Int) {
        let content: (String, String)
        switch row {
        case 0:
            content = ("Display Name", profile?.displayName ?? "N/A")
        case 1:
            content = ("Status Message", profile?.statusMessage ?? "N/A")
        case 2:
            content = ("UserID", profile?.userID ?? "N/A")
        case 3:
            content = ("Avatar URL", profile?.pictureURL?.absoluteString ?? "N/A")
        default:
            fatalError("Not Implemented yet.")
        }
        cell.textLabel?.text = content.0
        cell.detailTextLabel?.text = content.1
    }
    
    private func configTokenCell(_ cell: UITableViewCell, at row: Int) {
        let content: (String, String)
        switch row {
        case 0:
            content = ("Access", token?.value ?? "N/A")
        case 1:
            content = ("Created", token?.createdAt.description ?? "N/A")
        case 2:
            content = ("Expire", token?.expiresAt.description ?? "N/A")
        case 3:
            let permissions = token?.permissions ?? []
            let text = permissions.map { $0.rawValue }.joined(separator: " ")
            content = ("Permissions", text)
        default:
            fatalError("Not Implemented yet.")
        }
        cell.textLabel?.text = content.0
        cell.detailTextLabel?.text = content.1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .user: return 4
        case .token: return 4
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .user: return "User"
        case .token: return "Token"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        copyCellDetailContent(at: indexPath)
    }
}
