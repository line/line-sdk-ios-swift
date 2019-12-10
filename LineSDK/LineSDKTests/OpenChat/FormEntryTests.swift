//
//  FormEntryTests.swift
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

class FormEntryTests: XCTestCase, ViewControllerCompatibleTest {
    
    var window: UIWindow!
    
    override func tearDown() {
        resetViewController()
        super.tearDown()
    }
    
    func testRoomNameTextCanUpdate() {
        let text = RoomNameText()
        var result = ""
        text.onTextUpdated.delegate(on: self) { (self, value) in
            result = value
        }
        
        let cell = text.cell as! OpenChatRoomNameTableViewCell
        XCTAssertEqual(cell.textView.maximumCount, 50)
        cell.textView.text = "LINE SDK"
        XCTAssertEqual(result, "LINE SDK")
    }
    
    func testRoomDescriptionTextCanUpdate() {
        let text = RoomDescriptionText()
        var result = ""
        text.onTextUpdated.delegate(on: self) { (self, value) in
            result = value
        }
        
        let cell = text.cell as! OpenChatRoomDescriptionTableViewCell
        XCTAssertEqual(cell.textView.maximumCount, 200)
        cell.textView.text = "LINE SDK Description"
        XCTAssertEqual(result, "LINE SDK Description")
    }
    
    func testOptionCanSelect() {
        let option = Option(title: "test", options: [1,2,3])
        var result: Int?
        option.onValueChange.delegate(on: self) { (self, value) in
            result = value
        }
        XCTAssertEqual(option.selectedOption, 1)
        option.selectedOption = 3
        XCTAssertEqual(result, 3)
    }
    
    func testOptionCanPresentOptionSelecting() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let option = Option(title: "test", options: [1,2,3])
        let viewController = setupViewController()
        option.onPresenting.delegate(on: self) { (self, _) -> UIViewController in
            return viewController
        }
        
        option.tapCell()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertNotNil(viewController.presentedViewController)
            XCTAssertViewController(
                viewController.presentedViewController!,
                isKindOf: OptionSelectingViewController<Int>.self
            )
            expect.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testToggleCanUpdateValue() throws {
        let toggle = Toggle(title: "test", initialValue: true)
        
        var result: Bool?
        toggle.onValueChange.delegate(on: self) { (self, value) in
            result = value
        }
        
        let toggleView = toggle.cell.accessoryView as! UISwitch
        XCTAssertTrue(toggleView.isOn)
        toggleView.isOn = false
        toggle.switchValueDidChange(toggleView)
        XCTAssertFalse(result!)
    }
}
