//
//  ShareMessagesTableViewController.swift
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

class ShareMessagesTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(ShareMessagesTableViewController.self)")
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageStore.shared.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(ShareMessagesTableViewController.self)", for: indexPath)
        cell.textLabel?.text = MessageStore.shared.messages[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = MessageStore.shared.messages[indexPath.row]

        let viewController = ShareViewController()
        viewController.messages = [message.message]
        viewController.shareDelegate = self
        present(viewController, animated: true)

    }
}

extension ShareMessagesTableViewController: ShareViewControllerDelegate {
    func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError error: LineSDKError)
    {
        print("Sharing list did not finish loading. Error: \(error)")
        dismiss(animated: true) {
            UIAlertController.present(in: self, error: error)
        }
    }

    func shareViewControllerDidCancelSharing(_ controller: ShareViewController) {
        UIAlertController.present(
            in: self, title: nil, message: "User Cancelled", actions: [.init(title: "OK", style: .cancel)])
    }

    func shareViewController(
        _ controller: ShareViewController,
        messagesForSendingToTargets targets: [ShareTarget]) -> [MessageConvertible]
    {
        print("LineSDK will send message \(controller.messages!) to \(targets).")
        return controller.messages!
    }

    func shareViewController(
        _ controller: ShareViewController,
        didSendMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget])
    {
        print("Sharing is done.")
        dismiss(animated: true) {
            UIAlertController.present(in: self, successResult: "Share done.")
        }
    }

    func shareViewController(
        _ controller: ShareViewController,
        didFailSendingMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        withError error: LineSDKError)
    {
        print("Sharing finished with error: \(error)")
        dismiss(animated: true) {
            UIAlertController.present(in: self, error: error)
        }
    }

    func shareViewControllerShouldDismissAfterSending(_ controller: ShareViewController) -> Bool {
        return false
    }
}
