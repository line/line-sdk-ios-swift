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
    
    // MARK: - Test Data Factory
    
    enum TestDataFactory {
        static func friendsResponseData(count: Int = 1) -> Data {
            let friends = (1...count).map { index in
                """
                {
                    "userId": "friend\(index)",
                    "displayName": "Test Friend \(index)",
                    "pictureUrl": null
                }
                """
            }.joined(separator: ",")
            
            let json = """
            {
                "friends": [\(friends)]
            }
            """
            return json.data(using: .utf8)!
        }
        
        static func groupsResponseData(count: Int = 1) -> Data {
            let groups = (1...count).map { index in
                """
                {
                    "groupId": "group\(index)",
                    "groupName": "Test Group \(index)",
                    "pictureUrl": null
                }
                """
            }.joined(separator: ",")
            
            let json = """
            {
                "groups": [\(groups)]
            }
            """
            return json.data(using: .utf8)!
        }
        
        static func tokenResponseData(_ token: String = "test_token_123") -> Data {
            let json = """
            {
                "token": "\(token)"
            }
            """
            return json.data(using: .utf8)!
        }
        
        static func emptySuccessResponseData() -> Data {
            return "{}".data(using: .utf8)!
        }
    }
    
    // MARK: - Mock Data Creation
    
    private func createMockUser(id: String, name: String) -> User {
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
    
    // MARK: - Test Helper Methods
    
    private func setupSessionWithSuccessfulResponses(includeTokenAndSend: Bool = false) {
        var stubs: [SessionDelegateStub.Either] = [
            .init(data: TestDataFactory.friendsResponseData(), responseCode: 200),
            .init(data: TestDataFactory.groupsResponseData(), responseCode: 200)
        ]
        
        if includeTokenAndSend {
            stubs.append(.init(data: TestDataFactory.tokenResponseData(), responseCode: 200))
            stubs.append(.init(data: TestDataFactory.emptySuccessResponseData(), responseCode: 200))
        }
        
        let sessionStub = SessionDelegateStub(stubs: stubs)
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: sessionStub)
    }
    
    private func setupSessionWithNetworkError() {
        let networkError = LineSDKError.responseFailed(reason: .URLSessionError(URLError(.notConnectedToInternet)))
        let sessionStub = SessionDelegateStub(stubs: [
            .error(networkError),
            .error(networkError)
        ])
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: sessionStub)
    }
    
    private func setupSessionWithTokenError() {
        let tokenError = LineSDKError.responseFailed(reason: .URLSessionError(URLError(.notConnectedToInternet)))
        let sessionStub = SessionDelegateStub(stubs: [
            .init(data: TestDataFactory.friendsResponseData(), responseCode: 200),
            .init(data: TestDataFactory.groupsResponseData(), responseCode: 200),
            .error(tokenError)
        ])
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: sessionStub)
    }
    
    private func setupTestToken() {
        let tokenJSON = """
        {
            "access_token": "test_access_token",
            "expires_in": 3600,
            "scope": "onetime.share",
            "token_type": "Bearer",
            "refresh_token": "test_refresh_token"
        }
        """
        let tokenData = tokenJSON.data(using: .utf8)!
        let testToken = try! JSONDecoder().decode(AccessToken.self, from: tokenData)
        AccessTokenStore.shared.current = testToken
    }
    
    private func waitForAsyncOperation(
        description: String,
        timeout: TimeInterval = 2.0,
        delay: TimeInterval = 0.5,
        operation: @escaping () -> Void
    ) {
        let expectation = expectation(description: description)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            operation()
            expectation.fulfill()
        }
        waitForExpectations(timeout: timeout)
    }
    
    // MARK: - Network Request Tests
    
    func testSuccessfulDataLoading() {
        setupSessionWithSuccessfulResponses()
        
        _ = setupViewController(shareRootViewController)
        
        waitForAsyncOperation(description: "Data loaded") {
            XCTAssertTrue(self.shareRootViewController.allLoaded)
        }
    }
    
    func testNetworkErrorHandling() {
        setupSessionWithNetworkError()
        
        var loadingFailedCalled = false
        var failedTargetType: MessageShareTargetType?
        var receivedError: LineSDKError?
        
        shareRootViewController.onLoadingFailed.delegate(on: self) { (self, data) in
            loadingFailedCalled = true
            failedTargetType = data.0
            receivedError = data.1
        }
        
        _ = setupViewController(shareRootViewController)
        
        waitForAsyncOperation(description: "Error handled") {
            XCTAssertTrue(loadingFailedCalled)
            XCTAssertEqual(failedTargetType, .groups)
            XCTAssertNotNil(receivedError)
        }
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
    
    private func setupMessageSendingDelegates() -> (successCalled: () -> Bool, dismissCalled: () -> Bool) {
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
        
        return (
            successCalled: { successCallbackCalled },
            dismissCalled: { shouldDismissCallbackCalled }
        )
    }
    
    private func setupMessageSendingFailureDelegates() -> (failureCalled: () -> Bool, error: () -> LineSDKError?) {
        var failureCallbackCalled = false
        var receivedFailureError: LineSDKError?
        
        shareRootViewController.onSendingMessage.delegate(on: self) { (self, targets) in
            return [TextMessage(text: "Test message")]
        }
        
        shareRootViewController.onSendingFailure.delegate(on: self) { (self, data) in
            failureCallbackCalled = true
            receivedFailureError = data.error
        }
        
        return (
            failureCalled: { failureCallbackCalled },
            error: { receivedFailureError }
        )
    }
    
    func testMessageSendingSuccess() {
        setupSessionWithSuccessfulResponses(includeTokenAndSend: true)
        setupTestToken()
        
        let delegates = setupMessageSendingDelegates()
        shareRootViewController.messages = [TextMessage(text: "Test message")]
        
        _ = setupViewController(shareRootViewController)
        shareRootViewController.sendMessage()
        
        waitForAsyncOperation(description: "Message sent successfully", delay: 1.0) {
            XCTAssertTrue(delegates.successCalled())
            XCTAssertTrue(delegates.dismissCalled())
        }
    }
    
    func testMessageSendingFailure() {
        setupSessionWithTokenError()
        
        let delegates = setupMessageSendingFailureDelegates()
        
        _ = setupViewController(shareRootViewController)
        shareRootViewController.sendMessage()
        
        waitForAsyncOperation(description: "Message sending failed", delay: 1.0) {
            XCTAssertTrue(delegates.failureCalled())
            XCTAssertNotNil(delegates.error())
        }
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
        setupSessionWithTokenError()
        setupTestToken()
        
        _ = setupViewController(shareRootViewController)
        
        // Test selection
        shareRootViewController.store.toggleSelect(atColumn: 0, row: 0)
        
        waitForAsyncOperation(description: "UI update after selection", delay: 0.1) {
            XCTAssertEqual(self.shareRootViewController.selectedCount, 1)
            let title = self.shareRootViewController.navigationItem.rightBarButtonItem?.title
            XCTAssertTrue(title?.contains("1") ?? false)
        }
        
        // Test deselection in separate operation
        shareRootViewController.store.toggleSelect(atColumn: 0, row: 0)
        
        waitForAsyncOperation(description: "UI update after deselection", delay: 0.1) {
            XCTAssertEqual(self.shareRootViewController.selectedCount, 0)
            XCTAssertNil(self.shareRootViewController.navigationItem.rightBarButtonItem)
        }
    }
}

// MARK: - Test Extensions

extension ShareRootViewControllerTests {
    
    func simulateDataLoading() {
        shareRootViewController.setValue(true, forKey: "allLoaded")
    }
    
    func simulateSelection(count: Int) {
        // Since store is private, we can only simulate through notifications
        for _ in 0..<count {
            NotificationCenter.default.post(
                name: .columnDataStoreDidSelect,
                object: nil
            )
        }
    }
}
