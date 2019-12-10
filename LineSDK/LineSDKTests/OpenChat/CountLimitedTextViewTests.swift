//
//  CountLimitedTextViewTests.swift
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

class CountLimitedTextViewTests: XCTestCase {

    var textView: CountLimitedTextView!
    
    override func setUp() {
        super.setUp()
        let style = OpenChatRoomNameTableViewCell.TextViewStyle()
        textView = CountLimitedTextView(style: style)
    }

    override func tearDown() {
        textView = nil
        super.tearDown()
    }

    func testTextViewCanUpdate() {
        var result = ""
        textView.onTextUpdated.delegate(on: self) { (self, value) in
            result = value
        }
        textView.text = "LINE SDK"
        XCTAssertEqual(result, "LINE SDK")
    }
    
    func testTextViewCanSetMaximumCount() {
        XCTAssertNil(textView.maximumCount)
        textView.maximumCount = 4
        XCTAssertEqual(textView.maximumCount, 4)
        
        var result = ""
        textView.onTextUpdated.delegate(on: self) { (self, value) in
            result = value
        }
        textView.text = "LINE SDK"
        XCTAssertEqual(textView.text, "LINE")
        XCTAssertEqual(result, "LINE")
    }
    
    func testTextViewCanTruncateExistingTextOnSetMaximumCount() {
        var result = ""
        textView.onTextUpdated.delegate(on: self) { (self, value) in
            result = value
        }
        
        textView.text = "LINE SDK"
        XCTAssertEqual(textView.text, "LINE SDK")
        
        textView.maximumCount = 4
        XCTAssertEqual(textView.text, "LINE")
        XCTAssertEqual(result, "LINE")
    }
    
    func testTextViewNotAcceptingLeadingSpaces() {
        textView.maximumCount = 20
        var result = ""
        textView.onTextUpdated.delegate(on: self) { (self, value) in
            result = value
        }
        
        textView.text = "   LINE SDK   "
        XCTAssertEqual(textView.text, "LINE SDK   ")
        XCTAssertEqual(result, "LINE SDK   ")
    }
}
