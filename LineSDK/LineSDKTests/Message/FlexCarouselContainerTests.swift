//
//  FlexCarouselContainerTests.swift
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

extension FlexCarouselContainer: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "carousel",
          "contents": [
            {
              "type": "bubble",
              "body": {
                "type": "box",
                "layout": "vertical",
                "contents": [
                  {
                    "type": "text",
                    "text": "First bubble"
                  }
                ]
              }
            },
            {
              "type": "bubble",
              "body": {
                "type": "box",
                "layout": "vertical",
                "contents": [
                  {
                    "type": "text",
                    "text": "Second bubble"
                  }
                ]
              }
            }
          ]
        }
        """
        ]
    }
}

class FlexCarouselContainerTests: XCTestCase {
    
    func testCarouselContainerEncode() {
        let container = FlexCarouselContainer()
        let dic = FlexMessageContainer.carousel(container).json
        XCTAssertEqual(dic.count, 2)
        assertEqual(in: dic, forKey: "type", value: "carousel")
        
        let contents = dic["contents"] as! [Any]
        XCTAssertTrue(contents.isEmpty)
    }
    
    func testCarouselContainerContentsEncode() {
        let bubble = FlexBubbleContainer()
        var container = FlexCarouselContainer()
        container.addBubble(bubble)
        
        let dic = FlexMessageContainer.carousel(container).json
        XCTAssertEqual(dic.count, 2)
        assertEqual(in: dic, forKey: "type", value: "carousel")
        
        let contents = dic["contents"] as! [Any]
        XCTAssertEqual(contents.count, 1)
    }
    
    func testCarouselContainerDecode() {
        let decoder = JSONDecoder()
        let result = FlexCarouselContainer.samplesData
            .map { try! decoder.decode(FlexMessageContainer.self, from: $0) }
            .map { $0.asCarouselContainer! }
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].type, .carousel)
        XCTAssertEqual(result[0].contents.count, 2)
        XCTAssertEqual(result[0].contents[0].body?.contents[0].asTextComponent?.text, "First bubble")
        XCTAssertEqual(result[0].contents[1].body?.contents[0].asTextComponent?.text, "Second bubble")
    }
}
