//
//  OpenChatCreatingControllerTests.swift
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
import ObjectiveC

class OpenChatCreatingControllerTests: XCTestCase, ViewControllerCompatibleTest {

    var window: UIWindow!
    
    override func setUp() async throws {
        LoginManager.shared.setup(channelID: "123", universalLinkURL: nil)
    }

    override func tearDown() async throws {
        LoginManager.shared.reset()
        resetViewController()
    }
    
    // MARK: - Helper Methods
    
    private func setupMockSession(success: Bool, roomCreation: Bool = false) {
        if roomCreation {
            if success {
                let successData = """
                {
                    "openchatId": "test-openchat-id-12345",
                    "url": "https://line.me/ti/g2/test-room-url"
                }
                """.data(using: .utf8)!
                let delegateStub = SessionDelegateStub(stubs: [.init(data: successData, responseCode: 200)])
                Session._shared = Session(configuration: LoginConfiguration.shared, delegate: delegateStub)
            } else {
                let networkError = LineSDKError.responseFailed(reason: .URLSessionError(URLError(.badServerResponse)))
                let delegateStub = SessionDelegateStub(stub: .error(networkError))
                Session._shared = Session(configuration: LoginConfiguration.shared, delegate: delegateStub)
            }
        } else {
            let agreed = success ? "true" : "false"
            let delegateStub = SessionDelegateStub(stubs: [
                .init(data: "{\"agreed\": \(agreed)}".data(using: .utf8)!, responseCode: 200)
            ])
            Session._shared = Session(configuration: LoginConfiguration.shared, delegate: delegateStub)
        }
    }
    
    func testLocalAuthorizationStatusForCreatingOpenChat() {
        // Test with no token
        LoginManager.shared.reset()
        LoginManager.shared.setup(channelID: "123", universalLinkURL: nil)
        
        let statusNoToken = OpenChatCreatingController.localAuthorizationStatusForCreatingOpenChat()
        guard case .lackOfToken = statusNoToken else {
            XCTFail("Expected .lackOfToken but got \(statusNoToken)")
            return
        }
        
        // Test with valid token
        let tokenData = """
        {
            "access_token": "test_access_token",
            "expires_in": 3600,
            "id_token": null,
            "refresh_token": "test_refresh_token",
            "scope": "profile openid openchat.term.agreement.status openchat.create.join",
            "token_type": "Bearer"
        }
        """.data(using: .utf8)!
        
        let token = try! JSONDecoder().decode(AccessToken.self, from: tokenData)
        try! AccessTokenStore.shared.setCurrentToken(token)
        
        let statusWithToken = OpenChatCreatingController.localAuthorizationStatusForCreatingOpenChat()
        guard case .authorized = statusWithToken else {
            XCTFail("Expected .authorized but got \(statusWithToken)")
            return
        }
    }

    func testLocalAuthorizationLackForOpenChat() {
        let result = OpenChatCreatingController.localAuthorizationStatusForOpenChat(permissions: [])
        guard case .lackOfPermissions(let permissions) = result else {
            XCTFail("Expected .lackOfPermissions but got \(result)")
            return
        }
        XCTAssertEqual(permissions, [.openChatTermStatus, .openChatRoomCreateAndJoin])
    }

    func testPresentTermAgreementAlert() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        setupMockSession(success: false) // not agreed
        setupTestToken()
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        // Test loadAndPresent flow when terms not agreed
        controller.loadAndPresent(
            in: viewController,
            presentingAnimation: false,
            navigationDismissAnimating: false
        ) { result in
            switch result {
            case .success(let resultVC):
                XCTAssertNotNil(viewController.presentedViewController)
                XCTAssertEqual(resultVC, viewController.presentedViewController)
                XCTAssertViewController(resultVC, isKindOf: UIAlertController.self)
                
                // Test direct presentTermAgreementAlert method
                let alert = resultVC as! UIAlertController
                XCTAssertGreaterThan(alert.actions.count, 0)
                expect.fulfill()
            case .failure(let error):
                XCTFail("\(error)")
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testCanPresentCreatingViewControllerWhenAgreed() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let delegateStub = SessionDelegateStub(stubs: [
            // GetOpenChatTermAgreementStatusRequest -> true
            .init(data: "{\"agreed\": true}".data(using: .utf8)!, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )
        setupTestToken()
        
        let viewController = setupViewController()
        
        let controller = OpenChatCreatingController()
        controller.loadAndPresent(
            in: viewController,
            presentingAnimation: false,
            navigationDismissAnimating: false
        ) { result in
            expect.fulfill()
            switch result {
            case .success:
                XCTAssertNotNil(viewController.presentedViewController)
                XCTAssertViewController(
                    viewController.presentedViewController!,
                    isKindOf: OpenChatRoomInfoViewController.self
                )
            case .failure(let error):
                XCTFail("\(error)")
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    
    func testPresentCreatingViewControllerDelegates() {
        let expect = expectation(description: "\(#file)_\(#line)")
        expect.expectedFulfillmentCount = 2 // Test both onClose and onNext
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        controller.delegate = mockDelegate
        
        controller.presentCreatingViewController(
            in: viewController,
            presentingAnimation: false,
            navigationDismissAnimating: false
        ) { result in
            switch result {
            case .success(let navigationVC):
                XCTAssertNotNil(viewController.presentedViewController)
                XCTAssertEqual(navigationVC, viewController.presentedViewController)
                
                guard let navigation = navigationVC as? UINavigationController,
                      let roomInfoVC = navigation.viewControllers.first as? OpenChatRoomInfoViewController else {
                    XCTFail("Expected OpenChatRoomInfoViewController in navigation")
                    return
                }
                
                // Test onNext delegate
                var formItem = OpenChatCreatingFormItem()
                formItem.roomName = "Test Room"
                formItem.category = .study
                roomInfoVC.onNext.call(formItem)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    XCTAssertEqual(navigation.viewControllers.count, 2)
                    XCTAssertTrue(navigation.viewControllers[1] is OpenChatUserProfileViewController)
                    expect.fulfill()
                    
                    // Test onClose delegate
                    roomInfoVC.onClose.call(roomInfoVC)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        XCTAssertTrue(mockDelegate.didCancelCreatingCalled)
                        expect.fulfill()
                    }
                }
                
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }

    func testOnProfileDoneSuccess() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        setupMockSession(success: true, roomCreation: true)
        setupTestToken()
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        controller.delegate = mockDelegate
        
        controller.presentCreatingViewController(
            in: viewController,
            presentingAnimation: false,
            navigationDismissAnimating: false
        ) { result in
            switch result {
            case .success(let navigationVC):
                guard let navigation = navigationVC as? UINavigationController,
                      let roomInfoVC = navigation.viewControllers.first as? OpenChatRoomInfoViewController else {
                    XCTFail("Expected OpenChatRoomInfoViewController")
                    expect.fulfill()
                    return
                }
                
                var formItem = OpenChatCreatingFormItem()
                formItem.roomName = "Test Room"
                formItem.category = .study
                roomInfoVC.onNext.call(formItem)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard let userProfileVC = navigation.viewControllers[1] as? OpenChatUserProfileViewController else {
                        XCTFail("Expected OpenChatUserProfileViewController")
                        expect.fulfill()
                        return
                    }
                    
                    var profileFormItem = formItem
                    profileFormItem.userName = "Success User"
                    userProfileVC.onProfileDone.call(profileFormItem)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        XCTAssertTrue(mockDelegate.didCreateChatRoomCalled, "Success: didCreateChatRoom should be called")
                        XCTAssertFalse(mockDelegate.didFailWithErrorCalled, "Success: didFailWithError should not be called")
                        expect.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testOnProfileDoneFailure() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        setupMockSession(success: false, roomCreation: true)
        setupTestToken()
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        controller.delegate = mockDelegate
        
        controller.presentCreatingViewController(
            in: viewController,
            presentingAnimation: false,
            navigationDismissAnimating: false
        ) { result in
            switch result {
            case .success(let navigationVC):
                guard let navigation = navigationVC as? UINavigationController,
                      let roomInfoVC = navigation.viewControllers.first as? OpenChatRoomInfoViewController else {
                    XCTFail("Expected OpenChatRoomInfoViewController")
                    expect.fulfill()
                    return
                }
                
                var formItem = OpenChatCreatingFormItem()
                formItem.roomName = "Test Room"
                formItem.category = .study
                roomInfoVC.onNext.call(formItem)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard let userProfileVC = navigation.viewControllers[1] as? OpenChatUserProfileViewController else {
                        XCTFail("Expected OpenChatUserProfileViewController")
                        expect.fulfill()
                        return
                    }
                    
                    var profileFormItem = formItem
                    profileFormItem.userName = "Failure User"
                    userProfileVC.onProfileDone.call(profileFormItem)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        XCTAssertFalse(mockDelegate.didCreateChatRoomCalled, "Failure: didCreateChatRoom should not be called")
                        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "Failure: didFailWithError should be called")
                        expect.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testOnProfileDoneCaching() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        setupMockSession(success: true, roomCreation: true)
        setupTestToken()
        UserDefaultsValue.cachedOpenChatUserProfileName = nil
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        controller.delegate = mockDelegate
        
        controller.presentCreatingViewController(
            in: viewController,
            presentingAnimation: false,
            navigationDismissAnimating: false
        ) { result in
            switch result {
            case .success(let navigationVC):
                guard let navigation = navigationVC as? UINavigationController,
                      let roomInfoVC = navigation.viewControllers.first as? OpenChatRoomInfoViewController else {
                    XCTFail("Expected OpenChatRoomInfoViewController")
                    expect.fulfill()
                    return
                }
                
                var formItem = OpenChatCreatingFormItem()
                formItem.roomName = "Test Room"
                formItem.category = .study
                roomInfoVC.onNext.call(formItem)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard let userProfileVC = navigation.viewControllers[1] as? OpenChatUserProfileViewController else {
                        XCTFail("Expected OpenChatUserProfileViewController")
                        expect.fulfill()
                        return
                    }
                    
                    var profileFormItem = formItem
                    profileFormItem.userName = "Cached User"
                    userProfileVC.onProfileDone.call(profileFormItem)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        XCTAssertTrue(mockDelegate.didCreateChatRoomCalled, "Caching: didCreateChatRoom should be called")
                        XCTAssertEqual(UserDefaultsValue.cachedOpenChatUserProfileName, "Cached User", "Username should be cached")
                        expect.fulfill()
                    }
                }
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testDelegatePreventUserTermAlert() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let delegateStub = SessionDelegateStub(stubs: [
            // GetOpenChatTermAgreementStatusRequest -> false
            .init(data: "{\"agreed\": false}".data(using: .utf8)!, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )
        setupTestToken()
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        mockDelegate.shouldPreventUserTermAlert = true
        controller.delegate = mockDelegate
        
        // Start the load and present operation
        controller.loadAndPresent(
            in: viewController,
            presentingAnimation: false,
            navigationDismissAnimating: false
        ) { result in
            // This should not be called when delegate prevents the alert
            XCTFail("Handler should not be called when delegate prevents alert")
        }
        
        // Wait for async operation to complete and check delegate was called
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(mockDelegate.shouldPreventUserTermAlertCalled)
            XCTAssertNil(viewController.presentedViewController)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testLoadAndPresentWithNetworkError() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let networkError = LineSDKError.responseFailed(reason: .URLSessionError(URLError(.notConnectedToInternet)))
        let delegateStub = SessionDelegateStub(stub: .error(networkError))
        
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )
        setupTestToken()
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        controller.loadAndPresent(
            in: viewController,
            presentingAnimation: false,
            navigationDismissAnimating: false
        ) { result in
            expect.fulfill()
            switch result {
            case .success:
                XCTFail("Expected network error")
            case .failure:
                XCTAssertNil(viewController.presentedViewController)
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testWillPresentCreatingNavigationControllerDelegate() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        controller.delegate = mockDelegate
        
        controller.presentCreatingViewController(
            in: viewController,
            presentingAnimation: false,
            navigationDismissAnimating: false
        ) { result in
            expect.fulfill()
            switch result {
            case .success:
                XCTAssertTrue(mockDelegate.willPresentCreatingNavigationControllerCalled)
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testOptionSelectingCanSelectOption() {
        let optionSelecting = OptionSelectingViewController.createViewController(
            data: [1,2,3], selected: 2
        )
        let tableViewController = optionSelecting.1

        var result: Int?
        tableViewController.onSelected.delegate(on: self) { (self, value) in
            result = value
        }
        tableViewController.tableView.delegate?.tableView?(
            tableViewController.tableView, didSelectRowAt: .init(row: 0, section: 0)
        )
        
        XCTAssertEqual(result, 1)
    }
}

// MARK: - Mock Classes

@MainActor
class MockOpenChatCreatingControllerDelegate: OpenChatCreatingControllerDelegate {
    var didCreateChatRoomCalled = false
    var didFailWithErrorCalled = false
    var shouldPreventUserTermAlert = false
    var shouldPreventUserTermAlertCalled = false
    var didCancelCreatingCalled = false
    var willPresentCreatingNavigationControllerCalled = false
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didCreateChatRoom room: OpenChatRoomInfo,
        withCreatingItem item: OpenChatRoomCreatingItem
    ) {
        didCreateChatRoomCalled = true
    }
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        didFailWithError error: LineSDKError,
        withCreatingItem item: OpenChatRoomCreatingItem,
        presentingViewController: UIViewController
    ) {
        didFailWithErrorCalled = true
    }
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        shouldPreventUserTermAlertFrom presentingViewController: UIViewController
    ) -> Bool {
        shouldPreventUserTermAlertCalled = true
        return shouldPreventUserTermAlert
    }
    
    func openChatCreatingControllerDidCancelCreating(_ controller: OpenChatCreatingController) {
        didCancelCreatingCalled = true
    }
    
    func openChatCreatingController(
        _ controller: OpenChatCreatingController,
        willPresentCreatingNavigationController navigationController: OpenChatCreatingNavigationController
    ) {
        willPresentCreatingNavigationControllerCalled = true
    }
}


struct MockOpenChatRoomInfo {
    static let successData = """
    {
        "openchatId": "test-openchat-id-12345",
        "url": "https://line.me/ti/g2/test-room-url"
    }
    """.data(using: .utf8)!
}
