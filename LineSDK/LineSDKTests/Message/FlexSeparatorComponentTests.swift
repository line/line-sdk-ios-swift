//
//  FlexSeparatorComponentTests.swift
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

extension FlexSeparatorComponent: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "separator",
          "color": "#000000",
          "margin": "xxl"
        }
        """
        ]
    }
}

class FlexSeparatorComponentTests: XCTestCase {

    func testSeparatorComponentEncode() {
        let component = FlexSeparatorComponent(margin: .lg, color: HexColor(.red))
        let dic = FlexMessageComponent.separator(component).json
        assertEqual(in: dic, forKey: "type", value: "separator")
        assertEqual(in: dic, forKey: "margin", value: "lg")
        assertEqual(in: dic, forKey: "color", value: "#FF0000")
    }
    
    func testSeparatorComponentDecode() {
        let decoder = JSONDecoder()
        let result = FlexSeparatorComponent.samplesData
            .map { try! decoder.decode(FlexMessageComponent.self, from: $0) }
            .map { $0.asSeparatorComponent! }
        
        XCTAssertEqual(result[0].type, .separator)
        XCTAssertEqual(result[0].color?.rawValue, "#000000")
        XCTAssertEqual(result[0].margin, .xxl)
    }
    
}
