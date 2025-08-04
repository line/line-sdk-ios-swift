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

    func testLocalAuthorizationStatus() {
        let status1 = OpenChatCreatingController
            .localAuthorizationStatusForOpenChat(permissions: [])
        guard case .lackOfPermissions(let p1) = status1 else {
            XCTFail()
            return
        }
        XCTAssertEqual(p1, [.openChatTermStatus, .openChatRoomCreateAndJoin])

        let status2 = OpenChatCreatingController
            .localAuthorizationStatusForOpenChat(
                permissions: [.openChatTermStatus, .openChatRoomCreateAndJoin])
        guard case .authorized = status2 else {
            XCTFail()
            return
        }
        
        let status3 = OpenChatCreatingController
            .localAuthorizationStatusForOpenChat(permissions: [.openChatTermStatus])
        guard case .lackOfPermissions(let p2) = status3 else {
            XCTFail()
            return
        }
        XCTAssertEqual(p2, [.openChatRoomCreateAndJoin])
    }
    
    func testCanPresentTermAgreementAlertControllerWhenNotAgreed() {
        
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
        controller.loadAndPresent(in: viewController) { result in
            expect.fulfill()
            switch result {
            case .success(let resultVC):
                XCTAssertNotNil(viewController.presentedViewController)
                XCTAssertEqual(resultVC, viewController.presentedViewController)
                XCTAssertViewController(
                    resultVC,
                    isKindOf: UIAlertController.self
                )
            case .failure(let error):
                XCTFail("\(error)")
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
        controller.loadAndPresent(in: viewController) { result in
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
    
    func testLocalAuthorizationStatusForCreatingOpenChatWithNoToken() {
        // Clear the current token by setting up empty test environment
        LoginManager.shared.reset()
        LoginManager.shared.setup(channelID: "123", universalLinkURL: nil)
        
        let status = OpenChatCreatingController.localAuthorizationStatusForCreatingOpenChat()
        
        guard case .lackOfToken = status else {
            XCTFail("Expected .lackOfToken but got \(status)")
            return
        }
    }
    
    func testLocalAuthorizationStatusForCreatingOpenChatWithValidToken() {
        // Create a token with the required OpenChat permissions
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
        
        let status = OpenChatCreatingController.localAuthorizationStatusForCreatingOpenChat()
        
        guard case .authorized = status else {
            XCTFail("Expected .authorized but got \(status)")
            return
        }
    }
    
    func testPresentTermAgreementAlert() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        controller.presentTermAgreementAlert(in: viewController) { result in
            expect.fulfill()
            switch result {
            case .success(let alertVC):
                XCTAssertNotNil(viewController.presentedViewController)
                XCTAssertEqual(alertVC, viewController.presentedViewController)
                
                guard let alert = alertVC as? UIAlertController else {
                    XCTFail("Expected UIAlertController")
                    return
                }
                
                // Alert should have at least 1 action
                XCTAssertGreaterThan(alert.actions.count, 0)
                
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testPresentCreatingViewControllerOnCloseDelegate() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        controller.delegate = mockDelegate
        
        controller.presentCreatingViewController(in: viewController, navigationDismissAnimating: false) { result in
            switch result {
            case .success(let navigationVC):
                XCTAssertNotNil(viewController.presentedViewController)
                XCTAssertEqual(navigationVC, viewController.presentedViewController)
                
                guard let navigation = navigationVC as? UINavigationController,
                      let roomInfoVC = navigation.viewControllers.first as? OpenChatRoomInfoViewController else {
                    XCTFail("Expected OpenChatRoomInfoViewController in navigation")
                    return
                }
                
                // Trigger onClose delegate
                roomInfoVC.onClose.call(roomInfoVC)
                
                // Wait a bit for animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    XCTAssertTrue(mockDelegate.didCancelCreatingCalled)
                    expect.fulfill()
                }
                
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testPresentCreatingViewControllerOnNextDelegate() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        controller.presentCreatingViewController(in: viewController, navigationDismissAnimating: false) { result in
            switch result {
            case .success(let navigationVC):
                guard let navigation = navigationVC as? UINavigationController,
                      let roomInfoVC = navigation.viewControllers.first as? OpenChatRoomInfoViewController else {
                    XCTFail("Expected OpenChatRoomInfoViewController in navigation")
                    expect.fulfill()
                    return
                }
                
                // Create test form item
                var formItem = OpenChatCreatingFormItem()
                formItem.roomName = "Test Room"
                formItem.category = .study
                
                // Trigger onNext delegate
                roomInfoVC.onNext.call(formItem)
                
                // Wait for navigation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    // Verify navigation pushed the user profile view controller
                    XCTAssertEqual(navigation.viewControllers.count, 2)
                    XCTAssertTrue(navigation.viewControllers[1] is OpenChatUserProfileViewController)

                    expect.fulfill()
                }
                
            case .failure(let error):
                XCTFail("Unexpected error: \(error)")
                expect.fulfill()
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testOnProfileDoneTriggersRoomCreation() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        // Mock successful room creation response with proper JSON structure
        let successResponseData = """
        {
            "openchatId": "success-openchat-id-12345",
            "url": "https://line.me/ti/g2/success-room-url"
        }
        """.data(using: .utf8)!
        
        let delegateStub = SessionDelegateStub(stubs: [
            .init(data: successResponseData, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )
        setupTestToken()
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        controller.delegate = mockDelegate
        
        controller.presentCreatingViewController(in: viewController, navigationDismissAnimating: false) { result in
            switch result {
            case .success(let navigationVC):
                guard let navigation = navigationVC as? UINavigationController,
                      let roomInfoVC = navigation.viewControllers.first as? OpenChatRoomInfoViewController else {
                    XCTFail("Expected OpenChatRoomInfoViewController in navigation")
                    expect.fulfill()
                    return
                }
                
                // Create and trigger the onNext delegate to navigate to user profile
                var formItem = OpenChatCreatingFormItem()
                formItem.roomName = "Test Room"
                formItem.roomDescription = "Test Description"
                formItem.category = .study
                formItem.allowSearch = true
                
                roomInfoVC.onNext.call(formItem)
                
                // Wait for navigation to user profile screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    XCTAssertEqual(navigation.viewControllers.count, 2)
                    guard let userProfileVC = navigation.viewControllers[1] as? OpenChatUserProfileViewController else {
                        XCTFail("Expected OpenChatUserProfileViewController")
                        expect.fulfill()
                        return
                    }
                    
                    // Create form item with user profile data
                    var profileFormItem = formItem
                    profileFormItem.userName = "Test User"
                    
                    // Trigger onProfileDone delegate - this will test the room creation logic from line 168+
                    userProfileVC.onProfileDone.call(profileFormItem)
                    
                    // Wait for async room creation to complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // Verify successful room creation delegate was called
                        XCTAssertTrue(mockDelegate.didCreateChatRoomCalled, "didCreateChatRoom delegate should be called on success")
                        XCTAssertFalse(mockDelegate.didFailWithErrorCalled, "didFailWithError delegate should not be called on success")

                        expect.fulfill()
                    }
                }
                
            case .failure(let error):
                expect.fulfill()
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testOnProfileDoneFailedRoomCreation() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        // Mock failed room creation response
        let networkError = LineSDKError.responseFailed(reason: .URLSessionError(URLError(.badServerResponse)))
        let delegateStub = SessionDelegateStub(stub: .error(networkError))
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )
        setupTestToken()
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        controller.delegate = mockDelegate
        
        controller.presentCreatingViewController(in: viewController, navigationDismissAnimating: false) { result in
            switch result {
            case .success(let navigationVC):
                guard let navigation = navigationVC as? UINavigationController,
                      let roomInfoVC = navigation.viewControllers.first as? OpenChatRoomInfoViewController else {
                    XCTFail("Expected OpenChatRoomInfoViewController in navigation")
                    expect.fulfill()
                    return
                }
                
                // Create and trigger the onNext delegate
                var formItem = OpenChatCreatingFormItem()
                formItem.roomName = "Test Room"
                formItem.category = .study
                
                roomInfoVC.onNext.call(formItem)
                
                // Wait for navigation to user profile screen
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    guard let userProfileVC = navigation.viewControllers[1] as? OpenChatUserProfileViewController else {
                        XCTFail("Expected OpenChatUserProfileViewController")
                        expect.fulfill()
                        return
                    }
                    
                    // Create form item with user profile data
                    var profileFormItem = formItem
                    profileFormItem.userName = "Test User"
                    
                    // Trigger onProfileDone delegate - this will test the error handling logic
                    userProfileVC.onProfileDone.call(profileFormItem)
                    
                    // Wait for async room creation failure and delegate call
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        XCTAssertFalse(mockDelegate.didCreateChatRoomCalled, "didCreateChatRoom delegate should not be called")
                        XCTAssertTrue(mockDelegate.didFailWithErrorCalled, "didFailWithError delegate should be called")
                        expect.fulfill()
                    }
                }
                
            case .failure(let error):
                expect.fulfill()
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 3, handler: nil)
    }
    
    func testOnProfileDoneCachesUserName() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        // Mock successful room creation response
        let delegateStub = SessionDelegateStub(stubs: [
            .init(data: MockOpenChatRoomInfo.successData, responseCode: 200),
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )
        setupTestToken()
        
        let viewController = setupViewController()
        let controller = OpenChatCreatingController()
        
        let mockDelegate = MockOpenChatCreatingControllerDelegate()
        controller.delegate = mockDelegate
        
        // Clear any existing cached name
        UserDefaultsValue.cachedOpenChatUserProfileName = nil
        
        controller.presentCreatingViewController(in: viewController, navigationDismissAnimating: false) { result in
            switch result {
            case .success(let navigationVC):
                guard let navigation = navigationVC as? UINavigationController,
                      let roomInfoVC = navigation.viewControllers.first as? OpenChatRoomInfoViewController else {
                    XCTFail("Expected OpenChatRoomInfoViewController in navigation")
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
                    profileFormItem.userName = "Cached Test User"
                    
                    userProfileVC.onProfileDone.call(profileFormItem)
                    
                    // Wait for async room creation and name caching
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        XCTAssertTrue(mockDelegate.didCreateChatRoomCalled, "didCreateChatRoom delegate should be called")
                        // Verify that the user name was cached
                        XCTAssertEqual(UserDefaultsValue.cachedOpenChatUserProfileName, "Cached Test User")
                        expect.fulfill()
                    }
                }
                
            case .failure(let error):
                expect.fulfill()
                XCTFail("Unexpected error: \(error)")
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
        controller.loadAndPresent(in: viewController) { result in
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
        
        controller.loadAndPresent(in: viewController) { result in
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
        
        controller.presentCreatingViewController(in: viewController, navigationDismissAnimating: false) { result in
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
