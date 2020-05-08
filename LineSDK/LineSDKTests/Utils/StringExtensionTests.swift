//
//  StringExtensionTests.swift
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

class StringExtensionTests: XCTestCase {

    func testEntityIDValid() {
        
        XCTAssertFalse("".isValid)
        XCTAssertFalse("ABC_123".isValid)
        XCTAssertFalse("ABC 123".isValid)
        XCTAssertFalse("../abc".isValid)
        XCTAssertFalse("U88becdf05a8afd6_cf578703fd22f461e".isValid)
        
        XCTAssertTrue("U88becdf05a8afd6cf578703fd22f461e".isValid)
    }
    
    func testPrefixNormalized() {
        XCTAssertEqual("abc".prefixNormalized, "abc")
        XCTAssertEqual("  abc".prefixNormalized, "abc")
        XCTAssertEqual("abc  ".prefixNormalized, "abc  ")
        XCTAssertEqual("  abc  ".prefixNormalized, "abc  ")
    }
    
    func testNormalized() {
        XCTAssertEqual("abc".normalized, "abc")
        XCTAssertEqual("  abc".normalized, "abc")
        XCTAssertEqual("abc  ".normalized, "abc")
        XCTAssertEqual("  abc  ".normalized, "abc")
    }
    
    func testTrimmingUpperCount() {
        XCTAssertEqual("0123456".trimming(upper: 100), "0123456")
        XCTAssertEqual("0123456".trimming(upper: 3), "012")
        XCTAssertEqual("0123456".trimming(upper: 7), "0123456")
        XCTAssertEqual("0123456".trimming(upper: 0), "")
        
        XCTAssertEqual("一二三四五六".trimming(upper: 3), "一二三")
    }
}
