//
//  HexColorTests.swift
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
import LineSDK

class HexColorTests: XCTestCase {
    
    func testCreateHexColor() {
        let color = HexColor(.red)
        XCTAssertEqual(color.color, .red)
        XCTAssertEqual(color.rawValue, "#FF0000")
    }
    
    func testCreateHexColorValidRaw() {
        let color = HexColor(rawValue: "#00ff00", default: .white)
        XCTAssertEqual(color.color, .green)
        XCTAssertEqual(color.rawValue, "#00FF00")
    }
    
    func testCreateHexColorInvalidRaw() {
        let color = HexColor(rawValue: "123123", default: .blue)
        XCTAssertEqual(color.color, .blue)
        XCTAssertEqual(color.rawValue, "#0000FF")
    }
    
    func testHexColorEncode() {
        let colors = [HexColor(.red), HexColor(.green), HexColor(.blue)]
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(colors)
        
        let array = try! JSONSerialization.jsonObject(with: data, options: []) as? [String]
        XCTAssertEqual(array, ["#FF0000", "#00FF00", "#0000FF"])
    }
    
    func testHexColorDecode() {
        let string =
        """
        ["#FF0000", "#00FF00", "#0000FF", "123123123"]
        """
        let decoder = JSONDecoder()
        let result = try! decoder.decode([HexColor].self, from: string.data(using: .utf8)!)
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result[0].color, .red)
        XCTAssertEqual(result[1].color, .green)
        XCTAssertEqual(result[2].color, .blue)
        XCTAssertEqual(result[3].color, .white)
    }
    
    func testHexColorGreySpace() {
        let c = UIColor.gray
        XCTAssertEqual(c.cgColor.colorSpace?.model, CGColorSpaceCreateDeviceGray().model)
        let hex = HexColor(c)
        XCTAssertEqual(hex.rawValue, "#7F7F7F")
    }
    
    func testHexColorStringLiteral() {
        let color: HexColor = "#ff0000"
        XCTAssertEqual(color, HexColor(.red))
        
        let invalidColor: HexColor = "hello"
        XCTAssertEqual(invalidColor, HexColor(.white))
    }
}
