//
//  FlexImageComponentTests.swift
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

extension FlexImageComponent: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "image",
          "url": "https://example.com/flex/images/image.jpg",
          "size": "full"
        }
        """,
        """
        {
          "type": "image",
          "url": "https://example.com/flex/images/image.jpg",
          "flex": 1,
          "margin": "lg",
          "align": "center",
          "backgroundColor": "#123321",
          "aspectRatio": "1.51:1",
          "aspectMode": "cover"
        }
        """
        ]
    }
}

class FlexImageComponentTests: XCTestCase {

    func testImageComponentEncode() {
        let url = URL(string: "https://example.com")!
        let component = try! FlexImageComponent(url: url)
        let dic = FlexMessageComponent.image(component).json
        assertEqual(in: dic, forKey: "type", value: "image")
        assertEqual(in: dic, forKey: "url", value: "https://example.com")
        XCTAssertNil(dic["flex"])
    }
    
    func testImageComponentFullEncode() {
        let url = URL(string: "https://example.com")!
        var component = try! FlexImageComponent(url: url)
        component.flex = 1
        component.margin = .lg
        component.alignment = .center
        component.gravity = .bottom
        component.size = .full
        component.aspectRatio = .ratio_3x1
        component.aspectMode = .fill
        component.backgroundColor = HexColor(.red)
        component.setAction(MessageURIAction(label: "hello", uri: url))
        
        let dic = FlexMessageComponent.image(component).json
        assertEqual(in: dic, forKey: "type", value: "image")
        assertEqual(in: dic, forKey: "url", value: "https://example.com")
        assertEqual(in: dic, forKey: "flex", value: 1)
        assertEqual(in: dic, forKey: "margin", value: "lg")
        assertEqual(in: dic, forKey: "gravity", value: "bottom")
        assertEqual(in: dic, forKey: "size", value: "full")
        assertEqual(in: dic, forKey: "aspectRatio", value: "3:1")
        assertEqual(in: dic, forKey: "aspectMode", value: "cover")
        assertEqual(in: dic, forKey: "backgroundColor", value: "#FF0000")
        XCTAssertNotNil(dic["action"])
    }
    
    func testImageComponentDecode() {
        let decoder = JSONDecoder()
        let result = FlexImageComponent.samplesData
            .map { try! decoder.decode(FlexMessageComponent.self, from: $0) }
            .map { $0.asImageComponent! }
        
        XCTAssertEqual(result[0].type, .image)
        XCTAssertEqual(result[0].url, URL(string: "https://example.com/flex/images/image.jpg")!)
        XCTAssertEqual(result[0].size, .full)
        XCTAssertNil(result[0].flex)
        XCTAssertNil(result[0].aspectMode)
        XCTAssertNil(result[0].aspectRatio)
        
        XCTAssertEqual(result[1].flex, 1)
        XCTAssertEqual(result[1].margin, .lg)
        XCTAssertEqual(result[1].aspectMode, .fill)
        XCTAssertEqual(result[1].aspectRatio, .ratio_1_51x1)
        XCTAssertEqual(result[1].backgroundColor?.rawValue, "#123321")
    }
}
