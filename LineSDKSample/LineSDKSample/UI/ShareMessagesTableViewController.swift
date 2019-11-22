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

    private var observerToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        observerToken = NotificationCenter.default.addObserver(
            forName: .messageStoreMessageInserted,
            object: MessageStore.shared,
            queue: .main,
            using: { [weak self] _ in
                self?.tableView.reloadData()
            })
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:)))
        tableView.allowsMultipleSelection = true
    }

    var addButton: UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:)))
    }

    var sendButton: UIBarButtonItem {
        return UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendMessages(_:)))
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageStore.shared.messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        cell.textLabel?.text = MessageStore.shared.messages[indexPath.row].name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationItem.rightBarButtonItem = sendButton
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.indexPathsForSelectedRows == nil {
            navigationItem.rightBarButtonItem = addButton
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            MessageStore.shared.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    @IBAction func unwindFromAdding(segue: UIStoryboardSegue) { }

    @objc func add(_ sender: Any) {
        performSegue(withIdentifier: "showMessageAdding", sender: self)
    }

    @objc func sendMessages(_ sender: Any) {
        guard let indexes = tableView.indexPathsForSelectedRows else {
            return
        }

        let viewController = ShareViewController()

        let messages = indexes.map { MessageStore.shared.messages[$0.row].message }
        viewController.messages = messages

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
