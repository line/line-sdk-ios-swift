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

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showMessageChooser" {
            let status = ShareViewController.localAuthorizationStatusForSendingMessage()
            switch status {
            case .authorized:
                return true
            case .lackOfPermissions(let p):
                UIAlertController.present(
                    in: self,
                    title: nil,
                    message: "Lack of permissions: \(p)",
                    actions: [.init(title: "OK", style: .cancel)]
                )
                return false
            case .lackOfToken:
                UIAlertController.present(
                    in: self,
                    title: nil,
                    message: "Please login first.",
                    actions: [.init(title: "OK", style: .cancel)]
                )
                return false
            }
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            let openChatController = OpenChatController()
            openChatController.delegate = self
            openChatController.loadAndPresent(in: self) { result in
                switch result {
                case .success: print("Presented without problem.")
                case .failure(let error):
                    UIAlertController.present(in: self, error: error)
                }
            }
        }
    }
}


extension SampleUIHomeViewController: OpenChatControllerDelegate {
    func openChatController(
        _ controller: OpenChatController,
        didCreateChatRoom room: OpenChatRoomInfo,
        withCreatingItem item: OpenChatRoomCreatingItem
    )
    {
        UIPasteboard.general.string = room.squareMid
        let text = "Chat room created.\nURL: \(room.url)\nRoom ID: \(room.squareMid)"
        UIAlertController.present(in: self, successResult: text)
    }
    
    func openChatController(
        _ controller: OpenChatController,
        didFailWithError error: LineSDKError,
        withCreatingItem item: OpenChatRoomCreatingItem,
        presentingViewController: UIViewController
    )
    {
        var errorText = error.errorDescription ?? ""
        errorText.append("\nTried creating: \(item)")
        UIAlertController.present(in: presentingViewController, error: errorText)
    }
    
    func openChatController(
        _ controller: OpenChatController,
        didEncounterUserAgreementError error: LineSDKError,
        presentingViewController: UIViewController)
    {
        UIAlertController.present(in: presentingViewController, error: error)
    }
    
    func openChatControllerDidCancelCreating(_ controller: OpenChatController) {
        UIAlertController.present(in: self, error: "User cancelled.")
    }
    
    func openChatController(
        _ controller: OpenChatController,
        willPresentCreatingNavigationController navigationController: OpenChatCreatingNavigationController
    )
    {
        print("willPresentCreatingNavigationController: \(navigationController)")
    }
    
    
}
