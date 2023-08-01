//
//  LoginSettingsViewController.swift
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

protocol LoginSettingsViewControllerDelegate: AnyObject {
    func loginSettingsViewControllerWillDisappear(_ viewController: LoginSettingsViewController)
}

class LoginSettingsViewController: UITableViewController {
    enum Section: Int, CaseIterable {
        case permissions
        case openID
        case parameters

        var sectionTitle: String {
            switch self {
            case .permissions:
                return "Permissions"
            case .openID:
                return "Open ID"
            case .parameters:
                return "Parameters"
            }
        }
    }

    struct PermissionItem {
        let title: String
        let permission: LoginPermission
    }

    struct ParameterItem {
        let title: String
        var text: (LoginManager.Parameters) -> String
        let action: (inout LoginManager.Parameters) -> Void
    }

    let permissions: [PermissionItem] = {
        return LoginSettings.normalPermissions.map { PermissionItem(title: $0.rawValue, permission: $0) }
    }()

    let openIDs: [PermissionItem] = {
        return LoginSettings.openIDPermissions.map { PermissionItem(title: $0.rawValue, permission: $0) }
    }()

    let parameters: [ParameterItem] = [
        ParameterItem(
            title: "Only Web Login",
            text: { p in
                return p.onlyWebLogin ? "Yes" : "No"
            },
            action: { p in
                p.onlyWebLogin.toggle()
            }
        ),
        ParameterItem(
            title: "Bot Prompt",
            text: { p in
                switch p.botPromptStyle {
                case .aggressive: return "Aggressive"
                case .normal: return "Normal"
                case .none: return "None"
                }
            }, action: { p in
                switch p.botPromptStyle {
                case .aggressive: p.botPromptStyle = .normal
                case .normal: p.botPromptStyle = .none
                case .none: p.botPromptStyle = .aggressive
                }
            }
        )
    ]

    var loginSettings: LoginSettings!
    weak var delegate: LoginSettingsViewControllerDelegate?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.loginSettingsViewControllerWillDisappear(self)
    }

    @IBAction func donePressed(_ sender: Any) {
        dismiss(animated: true)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .permissions: return permissions.count
        case .openID: return openIDs.count
        case .parameters: return parameters.count
        case .none: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        guard let section = Section(rawValue: indexPath.section) else {
            preconditionFailure()
        }
        switch section {
        case .permissions:
            let p = permissions[indexPath.row]
            cell.textLabel?.text = p.title
            cell.detailTextLabel?.text = nil
            cell.accessoryType = loginSettings.permissionIsSelected(p.permission) ? .checkmark : .none
        case .openID:
            let p = openIDs[indexPath.row]
            cell.textLabel?.text = p.title
            cell.detailTextLabel?.text = nil
            cell.accessoryType = loginSettings.permissionIsSelected(p.permission) ? .checkmark : .none
        case .parameters:
            let p = parameters[indexPath.row]
            cell.textLabel?.text = p.title
            cell.detailTextLabel?.text = p.text(loginSettings.parameters)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.sectionTitle
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            return
        }
        switch section {
        case .permissions:
            let p = permissions[indexPath.row]
            loginSettings.togglePermission(p.permission)
        case .openID:
            let p = openIDs[indexPath.row]
            loginSettings.togglePermission(p.permission)
        case .parameters:
            let p = parameters[indexPath.row]
            p.action(&loginSettings.parameters)
        }
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
