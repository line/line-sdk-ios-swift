//
//  FlexBubbleContainerTests.swift
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

extension FlexBubbleContainer: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "bubble",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "Header text"
              }
            ]
          },
          "hero": {
            "type": "image",
            "url": "https://example.com/flex/images/image.jpg"
          },
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "Body text"
              }
            ]
          },
          "footer": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "Footer text"
              }
            ]
          },
          "styles": {
            "header": {
              "backgroundColor": "#00ffff"
            },
            "hero": {
              "separator": true,
              "separatorColor": "#000000"
            },
            "footer": {
              "backgroundColor": "#00ffff",
              "separator": true,
              "separatorColor": "#000000"
            }
          }
        }
        """
        ]
    }
}

class FlexBubbleContainerTests: XCTestCase {
    
    func testBubbleContainerEncode() {
        let container = FlexBubbleContainer()
        let dic = FlexMessageContainer.bubble(container).json
        assertEqual(in: dic, forKey: "type", value: "bubble")
        XCTAssertNil(dic["header"])
        XCTAssertNil(dic["hero"])
        XCTAssertNil(dic["body"])
        XCTAssertNil(dic["footer"])
        XCTAssertNil(dic["styles"])
    }

    func testBubbleContainerFullEncode() {
        var container = FlexBubbleContainer()
        
        container.header = {
            var header = FlexBoxComponent(layout: .vertical)
            header.addComponent(FlexTextComponent(text: "Header text"))
            return header
        }()
        
        container.hero = {
            return try! FlexImageComponent(url: URL(string: "https://example.com")!)
        }()
        
        container.body = {
            var body = FlexBoxComponent(layout: .vertical)
            body.addComponent(FlexTextComponent(text: "Body text"))
            return body
        }()
        
        container.footer = {
            var footer = FlexBoxComponent(layout: .vertical)
            footer.addComponent(FlexTextComponent(text: "Footer text"))
            return footer
        }()
        
        container.styles = {
            var style = FlexBubbleContainer.Style()
            style.header = FlexBlockStyle(backgroundColor: "#00ffff")
            style.hero = FlexBlockStyle(separator: true, separatorColor: "#000000")
            style.footer = FlexBlockStyle(backgroundColor: "#00ffff", separator: true, separatorColor: "#000000")
            return style
        }()
        
        let dic = FlexMessageContainer.bubble(container).json
        XCTAssertEqual(dic.count, 6)
        assertEqual(in: dic, forKey: "type", value: "bubble")
        
        XCTAssertNotNil(dic["header"])
        XCTAssertNotNil(dic["hero"])
        XCTAssertNotNil(dic["body"])
        XCTAssertNotNil(dic["footer"])
        XCTAssertNotNil(dic["styles"])
    }
    
    func testBubbleContainerDecode() {
        let decoder = JSONDecoder()
        let result = FlexBubbleContainer.samplesData
            .map { try! decoder.decode(FlexMessageContainer.self, from: $0) }
            .map { $0.asBubbleContainer! }
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].type, .bubble)
        
        XCTAssertNotNil(result[0].header)
        XCTAssertEqual(result[0].header?.contents[0].asTextComponent?.text, "Header text")
        
        XCTAssertNotNil(result[0].hero)
        XCTAssertEqual(result[0].hero?.url.absoluteString, "https://example.com/flex/images/image.jpg")
        
        XCTAssertNotNil(result[0].body)
        XCTAssertEqual(result[0].body?.contents[0].asTextComponent?.text, "Body text")
        
        XCTAssertNotNil(result[0].footer)
        XCTAssertEqual(result[0].footer?.contents[0].asTextComponent?.text, "Footer text")
        
        XCTAssertNotNil(result[0].styles)
        XCTAssertNotNil(result[0].styles?.header)
        XCTAssertNotNil(result[0].styles?.hero)
        XCTAssertNotNil(result[0].styles?.footer)
        XCTAssertNil(result[0].styles?.body)
    }
}
