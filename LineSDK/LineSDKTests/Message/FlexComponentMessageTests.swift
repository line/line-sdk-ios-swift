//
//  FlexComponentMessageTests.swift
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

fileprivate enum Enum: String, DefaultEnumCodable {
    case a
    case b
    case hello = "c"
    static let defaultCase: Enum = .a
}

class FlexComponentMessageTests: XCTestCase {
    
    func testDefaultEnumCodable() {
        let values = ["\"a\"", "\"b\"", "\"c\"", "\"hello\""]
        let string = "[\(values.joined(separator: ","))]"
        let decoder = JSONDecoder()
        let results = try! decoder.decode([Enum].self, from: string.data(using: .utf8)!)
        XCTAssertEqual(results, [.a, .b, .hello, .a])
    }
    
    func testMarginDecode() {
        
        typealias Property = FlexMessageComponent.Margin
        
        let margins = ["\"none\"", "\"xs\"", "\"sm\"", "\"md\"", "\"lg\"", "\"xl\"", "\"xxl\"", "\"abc\""]
        let string = "[\(margins.joined(separator: ","))]"
        
        let decoder = JSONDecoder()
        let results = try! decoder.decode([Property].self, from: string.data(using: .utf8)!)
        XCTAssertEqual(results, [.none, .xs, .sm, .md, .lg, .xl, .xxl, .none])
    }
    
    func testSizeDecode() {
        
        typealias Property = FlexMessageComponent.Size
        
        let margins = ["\"xxs\"", "\"xs\"", "\"sm\"", "\"md\"", "\"lg\"", "\"xl\"",
                       "\"xxl\"", "\"3xl\"", "\"4xl\"", "\"5xl\"", "\"full\"", "\"6xl\""]
        let string = "[\(margins.joined(separator: ","))]"
        
        let decoder = JSONDecoder()
        let results = try! decoder.decode([Property].self, from: string.data(using: .utf8)!)
        XCTAssertEqual(results, [.xxs, .xs, .sm, .md, .lg, .xl, .xxl, .xl3, .xl4, .xl5, .full, .md])
    }
    
    func testAlignDecode() {
        
        typealias Property = FlexMessageComponent.Alignment
        
        let margins = ["\"start\"", "\"end\"", "\"center\"", "\"none\""]
        let string = "[\(margins.joined(separator: ","))]"
        
        let decoder = JSONDecoder()
        let results = try! decoder.decode([Property].self, from: string.data(using: .utf8)!)
        XCTAssertEqual(results, [.start, .end, .center, .start])
    }
    
    func testGravityDecode() {
        
        typealias Property = FlexMessageComponent.Gravity
        
        let margins = ["\"top\"", "\"bottom\"", "\"center\"", "\"none\""]
        let string = "[\(margins.joined(separator: ","))]"
        
        let decoder = JSONDecoder()
        let results = try! decoder.decode([Property].self, from: string.data(using: .utf8)!)
        XCTAssertEqual(results, [.top, .bottom, .center, .top])
    }
    
    func testWeightDecode() {
        
        typealias Property = FlexMessageComponent.Weight
        
        let margins = ["\"regular\"", "\"bold\"", "\"light\""]
        let string = "[\(margins.joined(separator: ","))]"
        
        let decoder = JSONDecoder()
        let results = try! decoder.decode([Property].self, from: string.data(using: .utf8)!)
        XCTAssertEqual(results, [.regular, .bold, .regular])
    }
}
