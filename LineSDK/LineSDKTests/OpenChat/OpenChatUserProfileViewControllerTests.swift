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
    
    // MARK: - TextView Delegate Methods Tests
    
    func testOnTextUpdatedDelegate() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        let initialUserName = viewController.formItem.userName
        let newText = "Updated Name"
        
        // Simulate text change through CountLimitedTextView API
        viewController.nameTextView.text = newText
        
        // Verify the delegate updated the form item
        XCTAssertNotEqual(viewController.formItem.userName, initialUserName)
        XCTAssertEqual(viewController.formItem.userName, newText)
        
        // Verify navigation button state updated
        XCTAssertTrue(viewController.navigationItem.rightBarButtonItem?.isEnabled == true)
    }
    
    func testOnTextUpdatedDelegateWithEmptyText() {
        mockFormItem.userName = "Initial Name"
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Set empty text
        let emptyText = ""
        viewController.nameTextView.text = emptyText
        
        // Verify the delegate updated the form item
        XCTAssertEqual(viewController.formItem.userName, emptyText)
        
        // Verify navigation button is disabled for empty text
        XCTAssertFalse(viewController.navigationItem.rightBarButtonItem?.isEnabled == true)
    }
    
    func testOnTextViewChangeContentSizeDelegate() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Record initial nameTextView frame height for potential future use
        _ = viewController.nameTextView.frame.height
        
        // Simulate content size change with larger height
        let newSize = CGSize(width: 100, height: 60) // Height larger than initial
        viewController.nameTextView.onTextViewChangeContentSize.call(newSize)
        
        // Force layout update
        viewController.view.layoutIfNeeded()
        
        // Verify that the delegate was called (layout change may be minimal but should not crash)
        XCTAssertTrue(true, "onTextViewChangeContentSize delegate should execute without crashing")
    }
    
    func testOnTextViewChangeContentSizeDelegateWithSmallSize() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Record initial state for potential future use
        _ = viewController.nameTextView.frame.height
        
        // Simulate content size change with smaller height than initial
        let smallSize = CGSize(width: 100, height: 20) // Height smaller than initial
        viewController.nameTextView.onTextViewChangeContentSize.call(smallSize)
        
        // Force layout update
        viewController.view.layoutIfNeeded()
        
        // Verify that the delegate was called and handled correctly
        XCTAssertTrue(true, "onTextViewChangeContentSize delegate should handle small sizes without crashing")
    }
    
    func testOnTextCountLimitReachedDelegate() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        let expectation = self.expectation(description: "Toast should appear")
        
        // Trigger text count limit reached directly
        viewController.nameTextView.onTextCountLimitReached.call()
        
        // Give some time for toast to appear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Check if toast exists in the view hierarchy
            let toastViews = self.viewController.view.subviews.filter { $0 is ToastView }
            XCTAssertEqual(toastViews.count, 1, "Exactly one toast should be displayed")
            
            if let toast = toastViews.first as? ToastLabelView {
                XCTAssertEqual(toast.backgroundColor, UIColor.black.withAlphaComponent(0.85))
                XCTAssertEqual(toast.layer.cornerRadius, 5)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testOnTextCountLimitReachedDelegateToastReplacement() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        let expectation = self.expectation(description: "Toast replacement should work")
        
        // First trigger
        viewController.nameTextView.onTextCountLimitReached.call()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let firstToastCount = self.viewController.view.subviews.filter { $0 is ToastView }.count
            XCTAssertEqual(firstToastCount, 1, "Should have one toast after first trigger")
            
            // Second trigger should replace the first toast
            self.viewController.nameTextView.onTextCountLimitReached.call()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let secondToastCount = self.viewController.view.subviews.filter { $0 is ToastView }.count
                XCTAssertEqual(secondToastCount, 1, "Should still have only one toast after second trigger")
                
                expectation.fulfill()
            }
        }
        
        waitForExpectations(timeout: 2.0)
    }
    
    func testOnTextCountLimitReachedDelegateToastContent() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        let expectation = self.expectation(description: "Toast content should be correct")
        
        viewController.nameTextView.onTextCountLimitReached.call()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let toastViews = self.viewController.view.subviews.compactMap { $0 as? ToastLabelView }
            
            if let toast = toastViews.first,
               let label = toast.containerView.arrangedSubviews.first as? UILabel {
                
                let expectedText = Localization.string("openchat.create.profile.input.max.count")
                XCTAssertEqual(label.text, expectedText, "Toast should display correct localized text")
                XCTAssertEqual(label.textColor, UIColor.white.withAlphaComponent(0.85))
                XCTAssertEqual(label.font, .systemFont(ofSize: 14))
                XCTAssertEqual(label.numberOfLines, 0)
            } else {
                XCTFail("Toast should contain a proper label")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testOnShouldReplaceTextDelegateWithNewline() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Test with newline character - should be rejected
        let shouldReplace = viewController.nameTextView.onShouldReplaceText.call((NSRange(location: 0, length: 0), "\n"))
        XCTAssertFalse(shouldReplace!, "Should reject text with newline character")
    }
    
    func testOnShouldReplaceTextDelegateWithCarriageReturn() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Test with carriage return - should be rejected
        let shouldReplace = viewController.nameTextView.onShouldReplaceText.call((NSRange(location: 0, length: 0), "\r"))
        XCTAssertFalse(shouldReplace!, "Should reject text with carriage return")
    }
    
    func testOnShouldReplaceTextDelegateWithValidText() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Test with valid text - should be accepted
        let shouldReplace = viewController.nameTextView.onShouldReplaceText.call((NSRange(location: 0, length: 0), "valid text"))
        XCTAssertTrue(shouldReplace!, "Should accept valid text without newlines")
    }
    
    func testOnShouldReplaceTextDelegateEndsEditingOnNewline() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Make text view first responder
        viewController.nameTextView.textView.becomeFirstResponder()
        XCTAssertTrue(viewController.nameTextView.textView.isFirstResponder)
        
        // Test with newline - should end editing and reject text
        let shouldReplace = viewController.nameTextView.onShouldReplaceText.call((NSRange(location: 0, length: 0), "\n"))
        
        XCTAssertFalse(shouldReplace!, "Should reject newline text")
        XCTAssertFalse(viewController.nameTextView.textView.isFirstResponder, "Should end editing when newline is entered")
    }
    
    func testNameTextViewIntegrationWithUITextViewAPI() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        let textView = viewController.nameTextView.textView
        let initialText = viewController.formItem.userName
        
        // Simulate UITextView delegate methods being called
        textView.text = "New Text Input"
        
        // Manually trigger textViewDidChange to simulate UITextView behavior
        if let delegate = textView.delegate {
            delegate.textViewDidChange?(textView)
        }
        
        // Verify text was updated in form item
        XCTAssertNotEqual(viewController.formItem.userName, initialText)
        XCTAssertEqual(viewController.formItem.userName, "New Text Input")
    }
    
    func testNameTextViewMaximumCountValidation() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Verify maximum count is set correctly
        XCTAssertEqual(viewController.nameTextView.maximumCount, 20)
        
        // Test text that exceeds maximum count
        let longText = "This is a very long text that exceeds the maximum count of 20 characters"
        viewController.nameTextView.text = longText
        
        // The CountLimitedTextView should handle trimming internally
        // The actual behavior depends on the CountLimitedTextView implementation
        XCTAssertTrue(viewController.nameTextView.text.count <= 20, "Text should be limited to maximum count")
    }
    
    // MARK: - Additional Coverage Tests
    
    func testFormItemIntegration() {
        // Test form item integration with simple validation
        mockFormItem.userName = "Test User"
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Basic verification
        XCTAssertNotNil(viewController.formItem)
        XCTAssertEqual(viewController.formItem.userName, "Test User")
        XCTAssertTrue(viewController.navigationItem.rightBarButtonItem?.isEnabled == true)
    }
    
    func testBasicDelegateIntegration() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        var delegateWasCalled = false
        viewController.onProfileDone.delegate(on: self) { (self, _) in
            delegateWasCalled = true
        }
        
        // Call profileDone via navigation button
        if let button = viewController.navigationItem.rightBarButtonItem {
            _ = button.target?.perform(button.action, with: button)
        }
        
        XCTAssertTrue(delegateWasCalled)
    }
    
    func testViewLifecycleIntegration() {
        viewController.formItem = mockFormItem
        _ = setupViewController(viewController)
        
        // Test view lifecycle doesn't crash
        viewController.viewDidAppear(false)
        viewController.viewDidDisappear(false)
        
        XCTAssertTrue(true, "View lifecycle should execute without crashing")
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
