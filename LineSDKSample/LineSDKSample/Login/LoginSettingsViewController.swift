//
//  LoginSettingsViewController.swift
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
import LineSDK

protocol LoginSettingsViewControllerDelegate: AnyObject {
    func loginSettingsViewControllerWillDisappear(_ viewController: LoginSettingsViewController)
}

class LoginSettingsViewController: UITableViewController {
    enum Section: Int, CaseIterable {
        case channel
        case permissions
        case openID
        case parameters

        var sectionTitle: String {
            switch self {
            case .channel:
                return "Channel"
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
            title: "Bot (OA) Prompt",
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
        ),
        ParameterItem(
            title: "Initial Auth Method",
            text: { p in
                switch p.initialWebAuthenticationMethod {
                case .email: return "Email"
                case .qrCode: return "QR Code"
                }
            }, action: { p in
                switch p.initialWebAuthenticationMethod {
                case .email: p.initialWebAuthenticationMethod = .qrCode
                case .qrCode: p.initialWebAuthenticationMethod = .email
                }
            }
        )
    ]

    var loginSettings: LoginSettings!
    weak var delegate: LoginSettingsViewControllerDelegate?

    private weak var onlyResetAction: UIAlertAction?
    private weak var resetAndSetupAction: UIAlertAction?

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
        case .channel: return 1
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
        case .channel:
            cell.textLabel?.text = "Channel ID"
            cell.detailTextLabel?.text = SampleChannelSettings.storedChannelID ?? "Not Set"
            cell.accessoryType = .disclosureIndicator
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
            cell.accessoryType = .none
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
        case .channel:
            presentChannelEditing()
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
        if section == .parameters || section == .permissions || section == .openID {
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    private func presentChannelEditing() {
        let alert = UIAlertController(
            title: "Channel ID",
            message: "Enter the LINE channel ID to use with the SDK.",
            preferredStyle: .alert
        )
        alert.addTextField { [weak self] textField in
            textField.keyboardType = .numberPad
            textField.text = SampleChannelSettings.storedChannelID
            textField.clearButtonMode = .whileEditing
            if let self = self {
                textField.addTarget(self, action: #selector(LoginSettingsViewController.channelTextFieldDidChange(_:)), for: .editingChanged)
            }
        }

        let onlyReset = UIAlertAction(title: "Only Reset", style: .destructive) { [weak self, weak alert] _ in
            guard let channelID = self?.normalizedChannelID(from: alert) else {
                return
            }
            self?.applyChannelChange(channelID: channelID, shouldSetup: false)
        }
        onlyReset.isEnabled = false
        alert.addAction(onlyReset)

        let resetAndSetup = UIAlertAction(title: "Reset & Setup", style: .default) { [weak self, weak alert] _ in
            guard let channelID = self?.normalizedChannelID(from: alert) else {
                return
            }
            self?.applyChannelChange(channelID: channelID, shouldSetup: true)
        }
        resetAndSetup.isEnabled = false
        alert.addAction(resetAndSetup)

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        onlyResetAction = onlyReset
        resetAndSetupAction = resetAndSetup

        present(alert, animated: true) { [weak self, weak alert] in
            guard let textField = alert?.textFields?.first else { return }
            self?.updateChannelActions(for: textField.text)
        }
    }

    @objc private func channelTextFieldDidChange(_ sender: UITextField) {
        updateChannelActions(for: sender.text)
    }

    private func updateChannelActions(for text: String?) {
        let isValid = SampleChannelSettings.isValid(channelID: text ?? "")
        onlyResetAction?.isEnabled = isValid
        resetAndSetupAction?.isEnabled = isValid
    }

    private func normalizedChannelID(from alert: UIAlertController?) -> String? {
        guard let raw = alert?.textFields?.first?.text else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard SampleChannelSettings.isValid(channelID: trimmed) else { return nil }
        return trimmed
    }

    private func applyChannelChange(channelID: String, shouldSetup: Bool) {
        SampleChannelSettings.updateChannelID(channelID)
        LoginManager.shared.reset()

        if shouldSetup {
            LoginManager.shared.setup(channelID: channelID, universalLinkURL: nil)
        }

        let indexPath = IndexPath(row: 0, section: Section.channel.rawValue)
        tableView.reloadRows(at: [indexPath], with: .automatic)

        let message: String
        if shouldSetup {
            message = "The SDK was reset and configured with the new channel ID."
        } else {
            message = "The SDK was reset. Call setup again before performing login operations."
        }

        let confirmation = UIAlertController(title: "Channel Updated", message: message, preferredStyle: .alert)
        confirmation.addAction(UIAlertAction(title: "OK", style: .default))
        present(confirmation, animated: true)
    }
}
