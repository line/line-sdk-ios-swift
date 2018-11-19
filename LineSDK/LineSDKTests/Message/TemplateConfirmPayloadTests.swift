//
//  TemplateConfirmPayloadTests.swift
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

extension TemplateConfirmPayload: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type":"confirm",
          "text":"some question",
          "actions":[
            {
              "type": "uri",
              "label": "Yes",
              "uri": "tel:12345678"
            },
            {
              "type": "uri",
              "label": "No",
              "uri": "mailto://hello"
            }
          ]
        }
        """
        ]
    }
}

class TemplateConfirmPayloadTests: XCTestCase {

    func testTemplateConfirmPayloadEncoding() {
        let message = TemplateConfirmPayload(
            text: "123",
            confirmAction: MessageURIAction(label: "OK", uri: URL(string: "https://example.com")!),
            cancelAction: MessageURIAction(label: "Cancel", uri: URL(string: "https://example.com/cancel")!))
        let dic = TemplateMessagePayload.confirm(message).json
        assertEqual(in: dic, forKey: "type", value: "confirm")
        assertEqual(in: dic, forKey: "text", value: "123")
        
        let actions = dic["actions"] as! [[String: Any]]
        XCTAssertEqual(actions.count, 2)
        
        let action1 = actions[0]
        assertEqual(in: action1, forKey: "label", value: "OK")
        assertEqual(in: action1, forKey: "uri", value: "https://example.com")
        
        let action2 = actions[1]
        assertEqual(in: action2, forKey: "label", value: "Cancel")
        assertEqual(in: action2, forKey: "uri", value: "https://example.com/cancel")
    }
    
    func testTemplateConfirmPayloadDecoding() {
        let decoder = JSONDecoder()
        let result = TemplateConfirmPayload.samplesData
            .map { try! decoder.decode(TemplateMessagePayload.self, from: $0) }
            .map { $0.asConfirmPayload! }
        XCTAssertEqual(result[0].type, .confirm)
        XCTAssertEqual(result[0].text, "some question")
        XCTAssertEqual(result[0].actions.count, 2)
        XCTAssertEqual(result[0].actions[0].asURIAction!.label, "Yes")
        XCTAssertEqual(result[0].actions[1].asURIAction!.label, "No")
    }
}
