//
//  PageTabViewTests.swift
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
class PageTabViewTests: XCTestCase {

    func testUnderlineWidth() {
        let titleWidths: [CGFloat] = [20,40,60]

        // test leftmost
        XCTAssertEqual(20, PageTabView.Underline.preferredWidth(progress: -0.1, titleWidths: titleWidths))

        // test rightmost
        XCTAssertEqual(60, PageTabView.Underline.preferredWidth(progress: 2.1, titleWidths: titleWidths))

        // test middle
        XCTAssertEqual(40, PageTabView.Underline.preferredWidth(progress: 1, titleWidths: titleWidths))

        // test left half
        var w: CGFloat = 0.9 * 20 + 0.1 * 40
        XCTAssertEqual(w, PageTabView.Underline.preferredWidth(progress: 0.1, titleWidths: titleWidths))

        // test right half
        w = 0.8 * 40 + 0.2 * 60
        XCTAssertEqual(w, PageTabView.Underline.preferredWidth(progress: 1.2, titleWidths: titleWidths))
    }
}
