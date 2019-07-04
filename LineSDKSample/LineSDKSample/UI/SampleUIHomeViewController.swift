//
//  SampleUIHomeViewController.swift
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

class SampleUIHomeViewController: UITableViewController {

    enum Cell: Int {
        case shareMessage
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == Cell.shareMessage.rawValue {

            let status = ShareViewController.localAuthorizationStatusForSendingMessage()
            switch status {
            case .authorized:
                presentShareViewController()
            case .lackOfPermissions(let p):
                UIAlertController.present(
                    in: self,
                    title: nil,
                    message: "Lack of permissions: \(p)",
                    actions: [.init(title: "OK", style: .cancel)]
                )
            case .lackOfToken:
                UIAlertController.present(
                    in: self,
                    title: nil,
                    message: "Please login first.",
                    actions: [.init(title: "OK", style: .cancel)]
                )
            }
        }
    }

    private func presentShareViewController() {
        let viewController = ShareViewController()
        viewController.messages = [TextMessage(text: "Greeting from LINE SDK!")]
        viewController.shareDelegate = self
        present(viewController, animated: true)
    }
}

extension SampleUIHomeViewController: ShareViewControllerDelegate {
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
        dismiss(animated: true) {
            UIAlertController.present(
                in: self, title: nil, message: "User Cancelled", actions: [.init(title: "OK", style: .cancel)])
        }
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
