//
//  ShareViewControllerTests.swift
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
class ShareViewControllerTests: XCTestCase, ViewControllerCompatibleTest {
    
    // MARK: - Properties
    
    var window: UIWindow!
    private var shareViewController: ShareViewController!
    private var mockDelegate: MockShareViewControllerDelegate!
    private var originalToken: AccessToken?
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        LoginManager.shared.setup(channelID: "test_channel_id", universalLinkURL: nil)
        shareViewController = ShareViewController()
        shareViewController.loadViewIfNeeded()
        shareViewController.rootViewController.loadViewIfNeeded()
        mockDelegate = MockShareViewControllerDelegate()
        
        // Store original token state
        originalToken = AccessTokenStore.shared.current
    }
    
    override func tearDown() async throws {
        resetViewController()
        shareViewController = nil
        mockDelegate = nil
        
        // Restore original token state
        AccessTokenStore.shared.current = originalToken
        LoginManager.shared.reset()
    }
    
    // MARK: - Core Tests
    
    func testInitializationAndBasicProperties() {
        // Test initialization
        XCTAssertNotNil(shareViewController)
        XCTAssertEqual(shareViewController.viewControllers.count, 1)
        XCTAssertTrue(shareViewController.viewControllers.first is ShareRootViewController)
        XCTAssertNil(shareViewController.shareDelegate)
        XCTAssertNil(shareViewController.messages)
        
        // Test messages property
        let testMessages: [MessageConvertible] = [
            TextMessage(text: "Test message 1"),
            TextMessage(text: "Test message 2")
        ]
        shareViewController.messages = testMessages
        XCTAssertEqual(shareViewController.messages?.count, 2)
        
        // Test delegate property with weak reference
        weak var weakDelegate: MockShareViewControllerDelegate?
        autoreleasepool {
            let delegate = MockShareViewControllerDelegate()
            weakDelegate = delegate
            shareViewController.shareDelegate = delegate
            XCTAssertNotNil(shareViewController.shareDelegate)
        }
        XCTAssertNil(weakDelegate)
        XCTAssertNil(shareViewController.shareDelegate)
        
        // Test style inheritance
        shareViewController.navigationBarTintColor = .red
        shareViewController.statusBarStyle = .darkContent
        XCTAssertEqual(shareViewController.navigationBarTintColor, .red)
        XCTAssertEqual(shareViewController.statusBarStyle, .darkContent)
        XCTAssertEqual(shareViewController.preferredStatusBarStyle, shareViewController.statusBarStyle)
    }
    
    func testAuthorizationStatus() {
        // Test without token
        AccessTokenStore.shared.current = nil
        let status1 = ShareViewController.localAuthorizationStatusForSendingMessage()
        guard case .lackOfToken = status1 else {
            XCTFail("Expected .lackOfToken, got \(status1)")
            return
        }
        
        // Test with insufficient permissions
        let tokenWithoutPermissions = """
        {
            "access_token": "test_token",
            "expires_in": 3600,
            "scope": "",
            "token_type": "Bearer",
            "refresh_token": "test_refresh"
        }
        """
        let tokenData1 = tokenWithoutPermissions.data(using: .utf8)!
        let testToken1 = try! JSONDecoder().decode(AccessToken.self, from: tokenData1)
        AccessTokenStore.shared.current = testToken1
        
        let status2 = ShareViewController.localAuthorizationStatusForSendingMessage()
        guard case .lackOfPermissions(let lacking) = status2 else {
            XCTFail("Expected .lackOfPermissions, got \(status2)")
            return
        }
        XCTAssertTrue(lacking.contains(.oneTimeShare))
        
        // Test with valid permissions
        let tokenWithPermissions = """
        {
            "access_token": "test_token",
            "expires_in": 3600,
            "scope": "onetime.share",
            "token_type": "Bearer",
            "refresh_token": "test_refresh"
        }
        """
        let tokenData2 = tokenWithPermissions.data(using: .utf8)!
        let testToken2 = try! JSONDecoder().decode(AccessToken.self, from: tokenData2)
        AccessTokenStore.shared.current = testToken2
        
        let status3 = ShareViewController.localAuthorizationStatusForSendingMessage()
        guard case .authorized = status3 else {
            XCTFail("Expected .authorized, got \(status3)")
            return
        }
        
        // Test permissions parameter checking
        let status4 = ShareViewController.localAuthorizationStatusForSendingMessage(permissions: [])
        guard case .lackOfPermissions(let lacking4) = status4 else {
            XCTFail("Expected .lackOfPermissions")
            return
        }
        XCTAssertEqual(lacking4, [.oneTimeShare])
        
        let status5 = ShareViewController.localAuthorizationStatusForSendingMessage(permissions: [.oneTimeShare])
        guard case .authorized = status5 else {
            XCTFail("Expected .authorized")
            return
        }
    }
    
    func testDelegateIntegration() {
        shareViewController.shareDelegate = mockDelegate
        shareViewController.messages = [TextMessage(text: "Test")]
        _ = setupViewController(shareViewController)
        
        let rootVC = shareViewController.viewControllers.first as! ShareRootViewController
        rootVC.loadViewIfNeeded()
        let mockTargets: [ShareTarget] = [TestData.createMockUser(id: "user1", name: "Test User")]
        
        // Test presentation controller delegate setup
        XCTAssertNotNil(shareViewController.presentationController?.delegate)
        XCTAssertTrue(shareViewController.presentationController?.delegate === shareViewController)
        
        // Test cancellation delegate
        rootVC.onCancelled.call(())
        let cancelExpectation = expectation(description: "Cancel delegate")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.mockDelegate.didCancelSharingCalled)
            XCTAssertTrue(self.mockDelegate.lastCancelledController === self.shareViewController)
            cancelExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        // Test loading failure delegate
        let testError = LineSDKError.requestFailed(reason: .lackOfAccessToken)
        rootVC.onLoadingFailed.call((MessageShareTargetType.friends, testError))
        XCTAssertTrue(mockDelegate.didFailLoadingCalled)
        XCTAssertEqual(mockDelegate.lastFailedLoadingType, .friends)
        
        // Test message sending delegate
        mockDelegate.messagesToReturn = [TextMessage(text: "Delegate message")]
        let returnedMessages = rootVC.onSendingMessage.call(mockTargets)
        XCTAssertTrue(mockDelegate.messagesForSendingCalled)
        XCTAssertEqual(returnedMessages?.count, 1)
        
        // Test success delegate
        let successData = ShareRootViewController.OnSendingSuccessData(messages: [TextMessage(text: "Test")], targets: mockTargets)
        rootVC.onSendingSuccess.call(successData)
        XCTAssertTrue(mockDelegate.didSendMessagesCalled)
        
        // Test failure delegate
        let failureData = ShareRootViewController.OnSendingFailureData(messages: [TextMessage(text: "Test")], targets: mockTargets, error: testError)
        rootVC.onSendingFailure.call(failureData)
        XCTAssertTrue(mockDelegate.didFailSendingMessagesCalled)
        
        // Test dismiss delegate
        mockDelegate.shouldDismiss = false
        let shouldDismiss = rootVC.onShouldDismiss.call(())
        XCTAssertEqual(shouldDismiss, false)
        XCTAssertTrue(mockDelegate.shouldDismissAfterSendingCalled)
        
        // Test presentation controller dismissal
        let presentationController = UIPresentationController(presentedViewController: shareViewController, presenting: nil)
        shareViewController.presentationControllerDidDismiss(presentationController)
        XCTAssertTrue(mockDelegate.didCancelSharingCalled)
    }
    
    func testMessageHandlingWorkflow() {
        _ = setupViewController(shareViewController)
        let rootVC = shareViewController.viewControllers.first as! ShareRootViewController
        rootVC.loadViewIfNeeded()
        let mockTargets: [ShareTarget] = [TestData.createMockUser(id: "user1", name: "Test User")]
        
        // Test with messages property only
        shareViewController.messages = [TextMessage(text: "Property message")]
        let propertyMessages = rootVC.onSendingMessage.call(mockTargets)
        XCTAssertEqual(propertyMessages?.count, 1)
        if let textMessage = propertyMessages?.first as? TextMessage {
            XCTAssertEqual(textMessage.text, "Property message")
        }
        
        // Test with delegate override
        shareViewController.shareDelegate = mockDelegate
        mockDelegate.messagesToReturn = [TextMessage(text: "Delegate message")]
        let delegateMessages = rootVC.onSendingMessage.call(mockTargets)
        XCTAssertEqual(delegateMessages?.count, 1)
        if let textMessage = delegateMessages?.first as? TextMessage {
            XCTAssertEqual(textMessage.text, "Delegate message")
        }
        
        // Test without delegate and without messages (should trigger error in production)
        shareViewController.shareDelegate = nil
        shareViewController.messages = nil
        XCTAssertNil(shareViewController.messages)
        XCTAssertNil(shareViewController.shareDelegate)
        
        // Test message propagation to root controller
        shareViewController.messages = [TextMessage(text: "Propagated message")]
        XCTAssertEqual(rootVC.messages?.count, 1)
    }
}

// MARK: - Test Data and Mock Objects

private enum TestData {
    static func createMockUser(id: String, name: String) -> User {
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
    
    static func createMockGroup(id: String, name: String) -> Group {
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
}

private class MockShareViewControllerDelegate: ShareViewControllerDelegate {
    
    // Tracking flags
    var didFailLoadingCalled = false
    var didCancelSharingCalled = false
    var didFailSendingMessagesCalled = false
    var didSendMessagesCalled = false
    var shouldDismissAfterSendingCalled = false
    var messagesForSendingCalled = false
    
    // Last called values
    var lastFailedLoadingType: MessageShareTargetType?
    var lastLoadingError: LineSDKError?
    var lastCancelledController: ShareViewController?
    var lastFailedSendingMessages: [MessageConvertible]?
    var lastFailedSendingTargets: [ShareTarget]?
    var lastSendingError: LineSDKError?
    var lastSentMessages: [MessageConvertible]?
    var lastSentTargets: [ShareTarget]?
    var lastSendingTargets: [ShareTarget]?
    
    // Return values
    var shouldDismiss = true
    var messagesToReturn: [MessageConvertible]?
    
    func shareViewController(
        _ controller: ShareViewController,
        didFailLoadingListType shareType: MessageShareTargetType,
        withError error: LineSDKError
    ) {
        didFailLoadingCalled = true
        lastFailedLoadingType = shareType
        lastLoadingError = error
    }
    
    func shareViewControllerDidCancelSharing(_ controller: ShareViewController) {
        didCancelSharingCalled = true
        lastCancelledController = controller
    }
    
    func shareViewController(
        _ controller: ShareViewController,
        didFailSendingMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget],
        withError error: LineSDKError
    ) {
        didFailSendingMessagesCalled = true
        lastFailedSendingMessages = messages
        lastFailedSendingTargets = targets
        lastSendingError = error
    }
    
    func shareViewController(
        _ controller: ShareViewController,
        didSendMessages messages: [MessageConvertible],
        toTargets targets: [ShareTarget]
    ) {
        didSendMessagesCalled = true
        lastSentMessages = messages
        lastSentTargets = targets
    }
    
    func shareViewControllerShouldDismissAfterSending(_ controller: ShareViewController) -> Bool {
        shouldDismissAfterSendingCalled = true
        return shouldDismiss
    }
    
    func shareViewController(
        _ controller: ShareViewController,
        messagesForSendingToTargets targets: [ShareTarget]
    ) -> [MessageConvertible] {
        messagesForSendingCalled = true
        lastSendingTargets = targets
        return messagesToReturn ?? []
    }
}
