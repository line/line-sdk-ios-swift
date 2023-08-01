//
//  FlexBoxComponentTests.swift
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

class FlexBoxComponentTests: XCTestCase {
    
    func testBoxComponentEncode() {
        let component = FlexBoxComponent(layout: .horizontal)
        let dic = FlexMessageComponent.box(component).json
        assertEqual(in: dic, forKey: "type", value: "box")
        assertEqual(in: dic, forKey: "layout", value: "horizontal")
    }
    
    func testBoxComponentContentEncode() {
        let url = URL(string: "https://example.com")!
        var imageComponent = try! FlexImageComponent(url: url)
        imageComponent.gravity = .top
        
        let component = FlexBoxComponent(layout: .horizontal, contents: [imageComponent.component])
        let dic = FlexMessageComponent.box(component).json
        assertEqual(in: dic, forKey: "type", value: "box")
        assertEqual(in: dic, forKey: "layout", value: "horizontal")
        
        let contents = dic["contents"] as! [[String: Any]]
        XCTAssertEqual(contents.count, 1)
        let contentDic = contents[0]
        assertEqual(in: contentDic, forKey: "type", value: "image")
        assertEqual(in: contentDic, forKey: "url", value: "https://example.com")
        assertEqual(in: contentDic, forKey: "gravity", value: "top")
    }
    
    func testBoxComponentMultipleContentsEncode() {
        let url = URL(string: "https://example.com")!
        var imageComponent = try! FlexImageComponent(url: url)
        imageComponent.gravity = .top
        
        let textComponent = FlexTextComponent(text: "hello")
        
        let component = FlexBoxComponent(
            layout: .horizontal,
            contents: [textComponent.component, imageComponent.component])
        
        let dic = FlexMessageComponent.box(component).json
        assertEqual(in: dic, forKey: "type", value: "box")
        assertEqual(in: dic, forKey: "layout", value: "horizontal")
        
        let contents = dic["contents"] as! [[String: Any]]
        XCTAssertEqual(contents.count, 2)
        
        let textDic = contents[0]
        assertEqual(in: textDic, forKey: "type", value: "text")
        assertEqual(in: textDic, forKey: "text", value: "hello")
        
        let imageDic = contents[1]
        assertEqual(in: imageDic, forKey: "type", value: "image")
        assertEqual(in: imageDic, forKey: "url", value: "https://example.com")
        assertEqual(in: imageDic, forKey: "gravity", value: "top")
    }
    
    func testBoxComponentNestedContentEncode() {
        let url = URL(string: "https://example.com")!
        var imageComponent = try! FlexImageComponent(url: url)
        imageComponent.gravity = .top
        
        let nested = FlexBoxComponent(layout: .horizontal, contents: [imageComponent.component])
        let component = FlexBoxComponent(layout: .vertical, contents: [nested.component])
        
        let dic = FlexMessageComponent.box(component).json
        assertEqual(in: dic, forKey: "type", value: "box")
        assertEqual(in: dic, forKey: "layout", value: "vertical")
        
        let contents = dic["contents"] as! [[String: Any]]
        XCTAssertEqual(contents.count, 1)
        let nestedDic = contents[0]
        assertEqual(in: nestedDic, forKey: "type", value: "box")
        assertEqual(in: nestedDic, forKey: "layout", value: "horizontal")
        
        let nestedContent = nestedDic["contents"] as! [[String: Any]]
        XCTAssertEqual(nestedContent.count, 1)
        let contentDic = nestedContent[0]
        assertEqual(in: contentDic, forKey: "type", value: "image")
        assertEqual(in: contentDic, forKey: "url", value: "https://example.com")
        assertEqual(in: contentDic, forKey: "gravity", value: "top")
    }
}
