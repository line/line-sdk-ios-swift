//
//  OpenChatRoomTableViewController.swift
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

class OpenChatRoomTableViewController: UITableViewController, IndicatorDisplay {

    enum Section: Int, CaseIterable {
        case builtIn = 0
        case created = 1

        var title: String {
            switch self {
            case .builtIn: return "Built-in Rooms"
            case .created: return "Created Rooms"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        OpenChatRoom.onUpdated = { [weak self] in
            self?.tableView.reloadData()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .builtIn:
            return OpenChatRoom.builtInRooms.count
        default:
            return OpenChatRoom.createdRooms.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OpenChatRoomCell", for: indexPath)
        let room = roomAtIndexPath(indexPath)
        configure(cell: cell, room: room)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let room = roomAtIndexPath(indexPath)

        var errors: [LineSDKError] = []

        var roomStatus: GetOpenChatRoomStatusRequest.Status?
        var membership: GetOpenChatRoomMembershipStateRequest.State?
        var joinType: GetOpenChatRoomJoinTypeRequest.RoomType?

        showIndicatorOnWindow()

        let group = DispatchGroup()

        group.enter()
        API.getOpenChatRoomStatus(openChatId: room.chatRoomId) { result in
            switch result {
            case .success(let response):
                roomStatus = response.status
            case .failure(let error):
                errors.append(error)
            }
            group.leave()
        }

        group.enter()
        API.getOpenChatRoomMembershipState(openChatId: room.chatRoomId) { result in
            switch result {
            case .success(let response):
                membership = response.state
            case .failure(let error):
                errors.append(error)
            }

            group.leave()
        }


        group.enter()
        API.getOpenChatRoomJoinType(openChatId: room.chatRoomId) { result in
            switch result {
            case .success(let response):
                joinType = response.type
            case .failure(let error):
                errors.append(error)
            }
            group.leave()
        }

        group.notify(queue: .main) {
            self.hideIndicatorFromWindow()
            guard errors.isEmpty else {
                let errorMessages = errors.map { $0.errorDescription ?? "Unknown Error" }.joined(separator: "\n")
                UIAlertController.present(in: self, error: errorMessages)
                return
            }
            self.showRoomDetail(room: room, roomStatus: roomStatus!, membership: membership!, joinType: joinType!)
        }

    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title ?? ""
    }

    private func configure(cell: UITableViewCell, room: OpenChatRoom) {
        cell.textLabel?.text = room.chatRoomId
        cell.detailTextLabel?.text = room.url.absoluteString
        cell.accessoryType = .disclosureIndicator
    }

    private func roomAtIndexPath(_ indexPath: IndexPath) -> OpenChatRoom {
        switch Section(rawValue: indexPath.section) {
        case .builtIn:
            return OpenChatRoom.builtInRooms[indexPath.row]
        case .created:
            return OpenChatRoom.createdRooms[indexPath.row]
        default:
            preconditionFailure("Invalid section")
        }
    }

    private func showRoomDetail(
        room: OpenChatRoom,
        roomStatus: GetOpenChatRoomStatusRequest.Status,
        membership: GetOpenChatRoomMembershipStateRequest.State,
        joinType: GetOpenChatRoomJoinTypeRequest.RoomType
    ) {
        guard roomStatus == .alive else {
            UIAlertController.present(in: self, error: "The room is not valid anymore. State: \(roomStatus.rawValue)")
            return
        }

        let alert = UIAlertController(
            title: "Open Chat Room",
            message: "Room Status: \(roomStatus)\nJoin State: \(membership)\nRoom Join Type:\(joinType)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        switch (membership, joinType) {
        case (.joined, _):
            alert.addAction(UIAlertAction(title: "Open", style: .default) { _ in self.openRoom(room) })
        case (.notJoined, .default):
            alert.addAction(UIAlertAction(title: "Join", style: .default) { _ in self.joinRoom(room) })
        case (.notJoined, .undefined):
            alert.message?.append("\n\nUndefined join type. Upgrade your LINE SDK.")
        case (.notJoined, _):
            alert.message?.append("\n\nUnsupported room type. Cannot join.")
        case (.undefined, _):
            alert.message?.append("\n\nUndefined membership. Upgrade your LINE SDK.")
        }

        present(alert, animated: true)
    }

    private func openRoom(_ room: OpenChatRoom) {
        UIApplication.shared.open(room.url, options: [:])
    }

    private func joinRoom(_ room: OpenChatRoom) {

        showIndicatorOnWindow()
        API.getProfile { result in
            switch result {
            case .success(let profile):
                API.postOpenChatRoomJoin(openChatId: room.chatRoomId, displayName: profile.displayName) { result in
                    self.hideIndicatorFromWindow()
                    switch result {
                    case .success:
                        UIAlertController.present(in: self, successResult: "Joined.")
                    case .failure(let error):
                        UIAlertController.present(in: self, error: error)
                    }
                }
            case .failure(let error):
                self.hideIndicatorFromWindow()
                UIAlertController.present(in: self, error: error)
            }
        }
    }

    @IBAction func createRoom(_ sender: Any) {
        let status = OpenChatCreatingController.localAuthorizationStatusForCreatingOpenChat()
        switch status {
        case .authorized:
            let openChatCreatingController = OpenChatCreatingController()
            openChatCreatingController.delegate = self

            showIndicatorOnWindow()
            openChatCreatingController.loadAndPresent(in: self) { result in
                self.hideIndicatorFromWindow()
                switch result {
                case .success: print("Presented without problem.")
                case .failure(let error):
                    UIAlertController.present(in: self, error: error)
                }
            }
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

extension OpenChatRoomTableViewController: OpenChatCreatingControllerDelegate {
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didCreateChatRoom room: OpenChatRoomInfo,
        withCreatingItem item: OpenChatRoomCreatingItem
    )
    {
        UIPasteboard.general.string = room.openChatId
        let text = "Chat room created.\nURL: \(room.url)\nRoom ID: \(room.openChatId)"
        UIAlertController.present(in: self, successResult: text)

        OpenChatRoom.createdRooms.append(.init(chatRoomId: room.openChatId, url: room.url))
    }

    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didFailWithError error: LineSDKError,
        withCreatingItem item: OpenChatRoomCreatingItem,
        presentingViewController: UIViewController
    )
    {
        var errorText = error.errorDescription ?? ""
        errorText.append("\nTried creating: \(item)")
        UIAlertController.present(in: presentingViewController, error: errorText)
    }

    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        shouldPreventUserTermAlertFrom presentingViewController: UIViewController
    ) -> Bool
    {
        print("The term is not agreed yet. Asking user action...")
        return false
    }

    func openChatCreatingControllerDidCancelCreating(_ controller: OpenChatCreatingController) {
        UIAlertController.present(in: self, error: "User cancelled.")
    }

    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        willPresentCreatingNavigationController navigationController: OpenChatCreatingNavigationController
    )
    {
        print("willPresentCreatingNavigationController: \(navigationController)")
    }
}
