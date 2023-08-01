//
//  FlexIconComponentTests.swift
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

extension FlexIconComponent: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "icon",
          "url": "https://example.com/icon/png/caution.png",
          "size": "lg"
        }
        """
        ]
    }
}

class FlexIconComponentTests: XCTestCase {
    
    func testIconComponentEncode() {
        let url = URL(string: "https://example.com")!
        let component = try! FlexIconComponent(url: url)
        let dic = FlexMessageComponent.icon(component).json
        assertEqual(in: dic, forKey: "type", value: "icon")
        assertEqual(in: dic, forKey: "url", value: "https://example.com")
        XCTAssertNil(dic["flex"])
    }
    
    func testIconComponentFullEncode() {
        let url = URL(string: "https://example.com")!
        var component = try! FlexIconComponent(url: url)
        component.margin = .lg
        component.size = .full
        component.aspectRatio = .ratio_3x1
        
        let dic = FlexMessageComponent.icon(component).json
        assertEqual(in: dic, forKey: "type", value: "icon")
        assertEqual(in: dic, forKey: "url", value: "https://example.com")
        assertEqual(in: dic, forKey: "margin", value: "lg")
        assertEqual(in: dic, forKey: "size", value: "full")
        assertEqual(in: dic, forKey: "aspectRatio", value: "3:1")
    }
    
    func testIconComponentDecode() {
        let decoder = JSONDecoder()
        let result = FlexIconComponent.samplesData
            .map { try! decoder.decode(FlexMessageComponent.self, from: $0) }
            .map { $0.asIconComponent! }
        
        XCTAssertEqual(result[0].type, .icon)
        XCTAssertEqual(result[0].url, URL(string: "https://example.com/icon/png/caution.png")!)
        XCTAssertEqual(result[0].size, .lg)
    }
}
