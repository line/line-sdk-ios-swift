//
//  UIColorExtensionTests.swift
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

class UIColorExtensionTests: XCTestCase {

    func testHex6() {
        let white = UIColor(rgb: "#FFFFFF")
        XCTAssertEqual(white.rgbComponents, UIColor.white.rgbComponents)

        let black = UIColor(rgb: "#000000")
        XCTAssertEqual(black.rgbComponents, UIColor.black.rgbComponents)

        let red = UIColor(rgb: "#FF0000")
        XCTAssertEqual(red.rgbComponents, UIColor.red.rgbComponents)
    }

    func testHex8() {
        let white = UIColor(rgb: "#FFFFFFFF")
        XCTAssertEqual(white.rgbComponents, UIColor.white.rgbComponents)

        let black = UIColor(rgb: "#000000FF")
        XCTAssertEqual(black.rgbComponents, UIColor.black.rgbComponents)

        let red = UIColor(rgb: "#FF0000FF")
        XCTAssertEqual(red.rgbComponents, UIColor.red.rgbComponents)
    }
}

extension UIColor {
    var rgbComponents: [CGFloat]? {
        cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)?.components
    }
}
