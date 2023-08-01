//
//  OpenChatCreatingControllerTests.swift
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

import XCTest
@testable import LineSDK

class OpenChatCreatingControllerTests: XCTestCase, ViewControllerCompatibleTest {

    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        LoginManager.shared.setup(channelID: "123", universalLinkURL: nil)
    }

    override func tearDown() {
        LoginManager.shared.reset()
        resetViewController()
        super.tearDown()
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
        
        waitForExpectations(timeout: 5, handler: nil)
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
        
        waitForExpectations(timeout: 5, handler: nil)
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
