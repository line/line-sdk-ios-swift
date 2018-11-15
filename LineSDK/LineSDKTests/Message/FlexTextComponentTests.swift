//
//  FlexTextComponentTests.swift
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

extension FlexTextComponent: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "text",
          "text": "Hello, World!",
          "size": "xl",
          "weight": "bold",
          "color": "#0000ff"
        }
        """,
        """
        {
          "type": "text",
          "text": "HIHI",
          "flex": 2,
          "gravity": "center",
          "maxLines": 3,
          "wrap": false
        }
        """
        ]
    }
}

class FlexTextComponentTests: XCTestCase {
    
    func testTextComponentEncode() {
        let component = FlexTextComponent(text: "hello")
        let dic = FlexMessageComponent.text(component).json
        
        assertEqual(in: dic, forKey: "text", value: "hello")
        XCTAssertNil(dic["flex"])
    }
    
    func testTextComponentFullEncode() {
        var component = FlexTextComponent(text: "hello")
        component.text = "world"
        component.flex = 0
        component.margin = .xl
        component.size = .xl5
        component.alignment = .center
        component.gravity = .bottom
        component.wrapping = true
        component.maxLines = 5
        component.weight = .bold
        component.color = HexColor(.red)
        component.setAction(MessageURIAction(label: "action", uri: URL(string: "https://example.com")!))
        
        let dic = FlexMessageComponent.text(component).json
        assertEqual(in: dic, forKey: "text", value: "world")
        assertEqual(in: dic, forKey: "flex", value: 0)
        assertEqual(in: dic, forKey: "margin", value: "xl")
        assertEqual(in: dic, forKey: "size", value: "5xl")
        assertEqual(in: dic, forKey: "align", value: "center")
        assertEqual(in: dic, forKey: "gravity", value: "bottom")
        assertEqual(in: dic, forKey: "wrap", value: true)
        assertEqual(in: dic, forKey: "maxLines", value: 5)
        assertEqual(in: dic, forKey: "weight", value: "bold")
        assertEqual(in: dic, forKey: "color", value: "#FF0000")
        XCTAssertNotNil(dic["action"])
    }
    
    func testTextComponentDecode() {
        let decoder = JSONDecoder()
        let result = FlexTextComponent.samplesData
            .map { try! decoder.decode(FlexMessageComponent.self, from: $0) }
            .map { $0.asTextComponent! }
        
        XCTAssertEqual(result[0].type, .text)
        XCTAssertEqual(result[0].text, "Hello, World!")
        XCTAssertEqual(result[0].size, .xl)
        XCTAssertEqual(result[0].weight, .bold)
        XCTAssertEqual(result[0].color, HexColor(.blue))
        XCTAssertNil(result[0].alignment)
        XCTAssertNil(result[0].gravity)
        XCTAssertNil(result[0].wrapping)
        
        XCTAssertEqual(result[1].type, .text)
        XCTAssertEqual(result[1].text, "HIHI")
        XCTAssertEqual(result[1].flex, 2)
        XCTAssertEqual(result[1].gravity, .center)
        XCTAssertEqual(result[1].maxLines, 3)
        XCTAssertEqual(result[1].wrapping, false)
        XCTAssertNil(result[1].color)
    }
}
