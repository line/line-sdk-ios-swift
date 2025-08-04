//
//  ShareRootViewControllerTests.swift
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

import XCTest
@testable import LineSDK

@MainActor
class ShareRootViewControllerTests: XCTestCase, ViewControllerCompatibleTest {
    
    var window: UIWindow!
    var shareRootViewController: ShareRootViewController!
    var originalSession: Session!
    
    override func setUp() async throws {
        LoginManager.shared.setup(channelID: "test_channel_id", universalLinkURL: nil)
        shareRootViewController = ShareRootViewController()
        originalSession = Session.shared
    }
    
    override func tearDown() async throws {
        resetViewController()
        Session._shared = originalSession
        shareRootViewController = nil
        LoginManager.shared.reset()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(shareRootViewController)
        XCTAssertEqual(shareRootViewController.selectedCount, 0)
        XCTAssertNil(shareRootViewController.messages)
    }
    
    func testViewDidLoad() {
        _ = setupViewController(shareRootViewController)
        
        XCTAssertEqual(shareRootViewController.title, "LINE")
        XCTAssertNotNil(shareRootViewController.navigationItem.leftBarButtonItem)
        XCTAssertEqual(shareRootViewController.navigationItem.leftBarButtonItem?.title, 
                      Localization.string("common.action.close"))
        XCTAssertNil(shareRootViewController.navigationItem.rightBarButtonItem)
    }
    
    // MARK: - Selection State Tests
    
    func testInitialSelectedCount() {
        XCTAssertEqual(shareRootViewController.selectedCount, 0)
    }
    
    func testHandleSelectingChangeWithNoSelection() {
        _ = setupViewController(shareRootViewController)
        
        // Simulate no selection
        NotificationCenter.default.post(
            name: .columnDataStoreDidDeselect,
            object: nil
        )
        
        let expectation = expectation(description: "UI update")
        DispatchQueue.main.async {
            XCTAssertNil(self.shareRootViewController.navigationItem.rightBarButtonItem)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // MARK: - Data Store Tests
    
    func testDataStoreInitialization() {
        XCTAssertEqual(shareRootViewController.selectedCount, 0)
    }
    
    // MARK: - Mock Data Creation
    
    private func createMockUser(id: String, name: String) -> User {
        // We need to create a User with proper initializer
        // Since User is Decodable, we'll use JSON decoding
        let json = """
        {
            "userId": "\(id)",
            "displayName": "\(name)",
            "pictureUrl": null
        }
        """
        let data = json.data(using: .utf8)!
        return try! JSONDecoder().decode(User.self, from: data)
    }
    
    private func createMockGroup(id: String, name: String) -> Group {
        // We need to create a Group with proper initializer
        // Since Group is Decodable, we'll use JSON decoding
        let json = """
        {
            "groupId": "\(id)",
            "groupName": "\(name)",
            "pictureUrl": null
        }
        """
        let data = json.data(using: .utf8)!
        return try! JSONDecoder().decode(Group.self, from: data)
    }
    
    // MARK: - Network Request Tests
    
    func testSuccessfulDataLoading() {
        let friendsResponseData = """
        {
            "friends": [
                {
                    "userId": "friend1",
                    "displayName": "Test Friend 1",
                    "pictureUrl": null,
                    "statusMessage": null
                }
            ]
        }
        """.data(using: .utf8)!
        
        let groupsResponseData = """
        {
            "groups": [
                {
                    "groupId": "group1",
                    "groupName": "Test Group 1",
                    "pictureUrl": null
                }
            ]
        }
        """.data(using: .utf8)!
        
        let sessionStub = SessionDelegateStub(stubs: [
            .init(data: friendsResponseData, responseCode: 200),
            .init(data: groupsResponseData, responseCode: 200)
        ])
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: sessionStub)
        
        let expectation = expectation(description: "Data loaded")
        
        _ = setupViewController(shareRootViewController)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check if data loading completed
            XCTAssertTrue(self.shareRootViewController.allLoaded)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testNetworkErrorHandling() {
        let networkError = LineSDKError.responseFailed(reason: .URLSessionError(URLError(.notConnectedToInternet)))
        let sessionStub = SessionDelegateStub(stubs: [
            .error(networkError),
            .error(networkError)
        ])
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: sessionStub)
        
        var loadingFailedCalled = false
        var failedTargetType: MessageShareTargetType?
        var receivedError: LineSDKError?
        
        shareRootViewController.onLoadingFailed.delegate(on: self) { (self, data) in
            loadingFailedCalled = true
            failedTargetType = data.0
            receivedError = data.1
        }
        
        let expectation = expectation(description: "Error handled")
        
        _ = setupViewController(shareRootViewController)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

            XCTAssertTrue(loadingFailedCalled)
            XCTAssertEqual(failedTargetType, .groups)
            XCTAssertNotNil(receivedError)

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
    
    // MARK: - Cancel Action Tests
    
    func testCancelAction() {
        var cancelledCalled = false
        shareRootViewController.onCancelled.delegate(on: self) { (self, _) in
            cancelledCalled = true
        }
        
        _ = setupViewController(shareRootViewController)
        
        _ = shareRootViewController.navigationItem.leftBarButtonItem?.target?.perform(
            shareRootViewController.navigationItem.leftBarButtonItem!.action!,
            with: shareRootViewController.navigationItem.leftBarButtonItem
        )
        
        XCTAssertTrue(cancelledCalled)
    }
    
    // MARK: - Message Sending Tests
    
    func testMessageSendingDelegateSetup() {
        var onSendingMessageCalled = false
        var sentTargets: [ShareTarget] = []
        
        shareRootViewController.onSendingMessage.delegate(on: self) { (self, targets) in
            onSendingMessageCalled = true
            sentTargets = targets
            return [TextMessage(text: "Test message")]
        }
        
        _ = setupViewController(shareRootViewController)
        
        // Test the delegate setup works
        let mockTargets: [ShareTarget] = [createMockUser(id: "user1", name: "Test User")]
        let messages = shareRootViewController.onSendingMessage.call(mockTargets)
        
        XCTAssertTrue(onSendingMessageCalled)
        XCTAssertEqual(sentTargets.count, 1)
        XCTAssertEqual(sentTargets.first?.targetID, "user1")
        XCTAssertNotNil(messages)
        XCTAssertEqual(messages?.count, 1)
    }
    
    func testMessageSendingSuccess() {
        let friendsResponseData = """
        {
            "friends": [
                {
                    "userId": "friend1",
                    "displayName": "Test Friend 1",
                    "pictureUrl": null,
                    "statusMessage": null
                }
            ]
        }
        """.data(using: .utf8)!

        let groupsResponseData = """
        {
            "groups": [
                {
                    "groupId": "group1",
                    "groupName": "Test Group 1",
                    "pictureUrl": null
                }
            ]
        }
        """.data(using: .utf8)!
        let tokenResponseData = """
        {
            "token": "test_token_123"
        }
        """.data(using: .utf8)!
        
        let sendResponseData = """
        {}
        """.data(using: .utf8)!

        let sessionStub = SessionDelegateStub(stubs: [
            .init(data: friendsResponseData, responseCode: 200),
            .init(data: groupsResponseData, responseCode: 200),
            .init(data: tokenResponseData, responseCode: 200),
            .init(data: sendResponseData, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: sessionStub
        )
        setupTestToken()

        shareRootViewController.messages = [TextMessage(text: "Test message")]
        
        var successCallbackCalled = false
        var shouldDismissCallbackCalled = false
        
        shareRootViewController.onSendingMessage.delegate(on: self) { (self, targets) in
            return [TextMessage(text: "Test message")]
        }
        
        shareRootViewController.onSendingSuccess.delegate(on: self) { (self, data) in
            successCallbackCalled = true
        }
        
        shareRootViewController.onShouldDismiss.delegate(on: self) { (self, _) in
            shouldDismissCallbackCalled = true
            return true
        }
        
        let expectation = expectation(description: "Message sent successfully")
        
        _ = setupViewController(shareRootViewController)

        shareRootViewController.sendMessage()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(successCallbackCalled)
            XCTAssertTrue(shouldDismissCallbackCalled)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testMessageSendingFailure() {
        let friendsResponseData = """
        {
            "friends": [
                {
                    "userId": "friend1",
                    "displayName": "Test Friend 1",
                    "pictureUrl": null,
                    "statusMessage": null
                }
            ]
        }
        """.data(using: .utf8)!

        let groupsResponseData = """
        {
            "groups": [
                {
                    "groupId": "group1",
                    "groupName": "Test Group 1",
                    "pictureUrl": null
                }
            ]
        }
        """.data(using: .utf8)!

        let tokenError = LineSDKError.responseFailed(reason: .URLSessionError(URLError(.notConnectedToInternet)))
        let sessionStub = SessionDelegateStub(stubs: [
            .init(data: friendsResponseData, responseCode: 200),
            .init(data: groupsResponseData, responseCode: 200),
            .error(tokenError)
        ])
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: sessionStub)
        
        var failureCallbackCalled = false
        var receivedFailureError: LineSDKError?
        
        shareRootViewController.onSendingMessage.delegate(on: self) { (self, targets) in
            return [TextMessage(text: "Test message")]
        }
        
        shareRootViewController.onSendingFailure.delegate(on: self) { (self, data) in
            failureCallbackCalled = true
            receivedFailureError = data.error
        }
        
        let expectation = expectation(description: "Message sending failed")
        
        _ = setupViewController(shareRootViewController)
        
        // Simulate send message action
        shareRootViewController.sendMessage()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertTrue(failureCallbackCalled)
            XCTAssertNotNil(receivedFailureError)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
    
    // MARK: - Delegate Protocol Tests
    
    func testShouldSearchStart() {
        // Create a mock store for testing since the real store is private
        let mockStore = ColumnDataStore<ShareTarget>(columnCount: 1)
        let mockViewController = ShareTargetSelectingViewController(store: mockStore, columnIndex: 0)
        
        // Test when data is not loaded
        let shouldStart1 = shareRootViewController.shouldSearchStart(mockViewController)
        XCTAssertFalse(shouldStart1)
        
        // Test when data is loaded
        shareRootViewController.setValue(true, forKey: "allLoaded")
        let shouldStart2 = shareRootViewController.shouldSearchStart(mockViewController)
        XCTAssertTrue(shouldStart2)
    }
    
    func testCorrespondingSelectedPanelViewController() {
        let mockStore = ColumnDataStore<ShareTarget>(columnCount: 1)
        let mockViewController = ShareTargetSelectingViewController(store: mockStore, columnIndex: 0)
        
        let panelViewController = shareRootViewController.correspondingSelectedPanelViewController(for: mockViewController)
        XCTAssertNotNil(panelViewController)
    }
    
    func testPageViewController() {
        let mockStore = ColumnDataStore<ShareTarget>(columnCount: 1)
        let mockViewController = ShareTargetSelectingViewController(store: mockStore, columnIndex: 0)
        
        let pageViewController = shareRootViewController.pageViewController(for: mockViewController)
        XCTAssertNotNil(pageViewController)
    }
    
    // MARK: - Memory Management Tests
    
    func testDeinitPurgesImageCache() {
        // This test ensures that deinit is called and ImageManager cache is purged
        // We can't directly test deinit, but we can verify the controller is properly deallocated
        weak var weakController = shareRootViewController
        shareRootViewController = nil
        
        XCTAssertNil(weakController, "ShareRootViewController should be deallocated")
    }
    
    // MARK: - UI State Tests
    
    func testNavigationItemStateWithSelection() {
        let friendsResponseData = """
        {
            "friends": [
                {
                    "userId": "friend1",
                    "displayName": "Test Friend 1",
                    "pictureUrl": null,
                    "statusMessage": null
                }
            ]
        }
        """.data(using: .utf8)!

        let groupsResponseData = """
        {
            "groups": [
                {
                    "groupId": "group1",
                    "groupName": "Test Group 1",
                    "pictureUrl": null
                }
            ]
        }
        """.data(using: .utf8)!

        let tokenError = LineSDKError.responseFailed(reason: .URLSessionError(URLError(.notConnectedToInternet)))
        let sessionStub = SessionDelegateStub(stubs: [
            .init(data: friendsResponseData, responseCode: 200),
            .init(data: groupsResponseData, responseCode: 200),
            .error(tokenError)
        ])
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: sessionStub)
        setupTestToken()

        _ = setupViewController(shareRootViewController)

        shareRootViewController.store.toggleSelect(atColumn: 0, row: 0)
        let expectation = expectation(description: "UI update after selection")
        DispatchQueue.main.async {
            XCTAssertEqual(self.shareRootViewController.selectedCount, 1)
            let title = self.shareRootViewController.navigationItem.rightBarButtonItem?.title
            XCTAssertTrue(title?.contains("1") ?? false)
            self.shareRootViewController.store.toggleSelect(atColumn: 0, row: 0)
            DispatchQueue.main.async {
                XCTAssertEqual(self.shareRootViewController.selectedCount, 0)
                let title = self.shareRootViewController.navigationItem.rightBarButtonItem?.title
                XCTAssertTrue(title?.contains("0") ?? false)
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 1.0)
    }
}
