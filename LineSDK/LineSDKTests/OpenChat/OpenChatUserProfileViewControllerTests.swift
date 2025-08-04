//
//  OpenChatUserProfileViewControllerTests.swift
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
class OpenChatUserProfileViewControllerTests: XCTestCase, ViewControllerCompatibleTest {
    
    var window: UIWindow!
    var viewController: OpenChatUserProfileViewController!
    var mockFormItem: OpenChatCreatingFormItem!
    
    override func setUp() async throws {
        viewController = OpenChatUserProfileViewController()
        mockFormItem = OpenChatCreatingFormItem(
            roomName: "Test Room",
            roomDescription: "Test Description",
            category: .notSelected,
            allowSearch: true,
            userName: ""
        )
    }
    
    override func tearDown() async throws {
        resetViewController()
        viewController = nil
        mockFormItem = nil
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(viewController)
        XCTAssertNil(viewController.formItem)
    }
    
    func testViewDidLoadSetup() {
        // Set up form item first to avoid nil reference in viewDidLoad
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        XCTAssertEqual(viewController.title, Localization.string("openchat.create.profile.title"))
        XCTAssertEqual(viewController.view.backgroundColor, OpenChatUserProfileViewController.Design.backgroundColor)
        XCTAssertNotNil(viewController.navigationItem.rightBarButtonItem)
    }
    
    // MARK: - Form Item Setup Tests
    
    func testFormItemDidSet() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        XCTAssertNotNil(viewController.formItem)
        XCTAssertEqual(viewController.formItem.roomName, "Test Room")
        XCTAssertEqual(viewController.formItem.userName, "")
    }
    
    // MARK: - Delegate Tests
    
    func testProfileDoneDelegateSetup() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        var delegateCalled = false
        var receivedFormItem: OpenChatCreatingFormItem?
        
        viewController.onProfileDone.delegate(on: self) { (self, formItem) in
            delegateCalled = true
            receivedFormItem = formItem
        }
        
        // Simulate delegate call
        viewController.onProfileDone.call(mockFormItem)
        
        XCTAssertTrue(delegateCalled)
        XCTAssertNotNil(receivedFormItem)
        XCTAssertEqual(receivedFormItem?.roomName, "Test Room")
    }
    
    // MARK: - Design Tests
    
    func testDesignProperties() {
        XCTAssertEqual(OpenChatUserProfileViewController.Design.backgroundColor, .systemGroupedBackground)
        
        let textStyle = OpenChatUserProfileViewController.TextViewStyle()
        XCTAssertEqual(textStyle.font, .systemFont(ofSize: 22, weight: .semibold))
        XCTAssertEqual(textStyle.textColor, .label)
        XCTAssertEqual(textStyle.placeholderFont, .systemFont(ofSize: 22, weight: .semibold))
        XCTAssertEqual(textStyle.showCountLimitLabel, false)
        XCTAssertEqual(textStyle.showUnderBorderLine, true)
    }
    
    // MARK: - Mock Data Factory
    
    enum TestDataFactory {
        static func createMockFormItem(
            roomName: String = "Test Room",
            roomDescription: String = "Test Description",
            category: OpenChatCategory = .notSelected,
            allowSearch: Bool = true,
            userName: String = ""
        ) -> OpenChatCreatingFormItem {
            return OpenChatCreatingFormItem(
                roomName: roomName,
                roomDescription: roomDescription,
                category: category,
                allowSearch: allowSearch,
                userName: userName
            )
        }
    }
}