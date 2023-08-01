//
//  TemplateImageCarouselPayloadTests.swift
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

extension TemplateImageCarouselPayload: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "image_carousel",
          "columns": [
            {
              "imageUrl": "https://image-1.com/",
              "action": {
                "type": "uri",
                "label": "action 1",
                "uri": "https://example.com"
              }
            },
            {
              "imageUrl": "https://image-2.com/",
              "action": {
                "type": "uri",
                "label": "action 2",
                "uri": "https://example.com"
              }
            }
          ]
        }
        """
        ]
    }
}

class TemplateImageCarouselPayloadTests: XCTestCase {
    func testTemplateImageCarouselMessageEncoding() {
        let uriAction = MessageURIAction(label: "Cancel", uri: URL(string: "scheme://action")!)
        let action = MessageAction.URI(uriAction)
        
        let column = try! TemplateImageCarouselPayload.Column(
            imageURL: URL(string: "https://example.com")!,
            action: action
        )
        var message = TemplateImageCarouselPayload(columns: [column])
        
        var anotherColumn = try! TemplateImageCarouselPayload.Column(
            imageURL: URL(string: "https://example.com/another")!,
            action: action
        )
        let anotherAction = MessageURIAction(label: "OK", uri: URL(string: "scheme://action-2")!)
        anotherColumn.action = .URI(anotherAction)
        message.addColumn(anotherColumn)
        
        let dic = TemplateMessagePayload.imageCarousel(message).json
        assertEqual(in: dic, forKey: "type", value: "image_carousel")
        
        let columns = dic["columns"] as! [[String: Any]]
        XCTAssertEqual(columns.count, 2)
        
        let column1 = columns[0]
        assertEqual(in: column1, forKey: "imageUrl", value: "https://example.com")
        let actionInColumn1 = column1["action"] as! [String: Any]
        assertEqual(in: actionInColumn1, forKey: "label", value: "Cancel")
        assertEqual(in: actionInColumn1, forKey: "uri", value: "scheme://action")

        
        let column2 = columns[1]
        assertEqual(in: column2, forKey: "imageUrl", value: "https://example.com/another")
        let actionInColumn2 = column2["action"] as! [String: Any]
        assertEqual(in: actionInColumn2, forKey: "label", value: "OK")
        assertEqual(in: actionInColumn2, forKey: "uri", value: "scheme://action-2")
    }
    
    func testTemplateImageCarouselPayloadDecoding() {
        let decoder = JSONDecoder()
        let result = TemplateImageCarouselPayload.samplesData
            .map { try! decoder.decode(TemplateMessagePayload.self, from: $0) }
            .map { $0.asImageCarouselPayload! }
        XCTAssertEqual(result[0].type, .imageCarousel)
        XCTAssertEqual(result[0].columns.count, 2)
        
        XCTAssertEqual(result[0].columns[0].imageURL, URL(string: "https://image-1.com/"))
        XCTAssertEqual(result[0].columns[0].action?.asURIAction?.label, "action 1")
        
        XCTAssertEqual(result[0].columns[1].imageURL, URL(string: "https://image-2.com/"))
        XCTAssertEqual(result[0].columns[1].action?.asURIAction?.label, "action 2")
    }
}
