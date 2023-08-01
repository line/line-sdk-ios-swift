//
//  FlexButtonComponentTests.swift
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

extension FlexButtonComponent: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "button",
          "action": {
            "type": "uri",
            "label": "Tap me",
            "uri": "https://example.com"
          },
          "style": "primary",
          "color": "#0000ff"
        }
        """
        ]
    }
}

class FlexButtonComponentTests: XCTestCase {
    
    func testButtonComponentEncode() {
        let action = MessageURIAction(label: "action", uri: URL(string: "https://example.com")!)
        let component = FlexButtonComponent(action: action)
        let dic = FlexMessageComponent.button(component).json
        
        assertEqual(in: dic, forKey: "type", value: "button")
        
        let actionDic = dic["action"] as! [String: Any]
        assertEqual(in: actionDic, forKey: "label", value: "action")
        assertEqual(in: actionDic, forKey: "uri", value: "https://example.com")
        
        XCTAssertNil(dic["flex"])
        XCTAssertNil(dic["margin"])
        XCTAssertNil(dic["height"])
        XCTAssertNil(dic["style"])
        XCTAssertNil(dic["color"])
        XCTAssertNil(dic["gravity"])
    }
    
    func testButtonComponentFullEncode() {
        let action = MessageURIAction(label: "action", uri: URL(string: "https://example.com")!)
        var component = FlexButtonComponent(action: action)
        component.flex = 1
        component.margin = .lg
        component.height = .sm
        component.style = .primary
        component.color = HexColor(.red)
        component.gravity = .bottom
        
        let dic = FlexMessageComponent.button(component).json
        assertEqual(in: dic, forKey: "type", value: "button")
        assertEqual(in: dic, forKey: "flex", value: 1)
        assertEqual(in: dic, forKey: "margin", value: "lg")
        assertEqual(in: dic, forKey: "height", value: "sm")
        assertEqual(in: dic, forKey: "style", value: "primary")
        assertEqual(in: dic, forKey: "color", value: "#FF0000")
        assertEqual(in: dic, forKey: "gravity", value: "bottom")
        XCTAssertNotNil(dic["action"])
    }
    
    func testButtonComponentDecode() {
        let decoder = JSONDecoder()
        let result = FlexButtonComponent.samplesData
            .map { try! decoder.decode(FlexMessageComponent.self, from: $0) }
            .map { $0.asButtonComponent! }
        
        XCTAssertEqual(result[0].type, .button)
        XCTAssertEqual(result[0].action.asURIAction!.label, "Tap me")
        XCTAssertEqual(result[0].action.asURIAction!.uri.absoluteString, "https://example.com")
        XCTAssertEqual(result[0].style, .primary)
        XCTAssertEqual(result[0].color?.color, .blue)
        XCTAssertNil(result[0].flex)
        XCTAssertNil(result[0].margin)
        XCTAssertNil(result[0].gravity)
    }

}
