//
//  TextMessageTests.swift
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

extension TextMessage: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "text",
          "text": "Hello, world"
        }
        """,
        """
        {
          "type": "text",
          "text": "Hello, world",
          "sentBy": {
            "label": "onevcat",
            "iconUrl": "https://example.com"
          }
        }
        """,
        ]
    }
}

class TextMessageTests: XCTestCase {
    
    func testTextMessageEncoding() {
        
        let textMessage = TextMessage(text: "test")
        let message = Message.text(textMessage)
        
        let dic = message.json
        assertEqual(in: dic, forKey: "type", value: "text")
        assertEqual(in: dic, forKey: "text", value: "test")
        XCTAssertNil(dic["sentBy"])
    }
    
    func testTextMessageWithSenderEncoding() {
        let sender = MessageSender(label: "user", iconURL: URL(string: "https://example.com")!, linkURL: nil)
        let textMessageWithSender = TextMessage(text: "test", sender: sender)
        let message = Message.text(textMessageWithSender)
        
        let dic = message.json
        assertEqual(in: dic, forKey: "type", value: "text")
        assertEqual(in: dic, forKey: "text", value: "test")
        XCTAssertNotNil(dic["sentBy"])
        
        let sentBy = dic["sentBy"] as! [String: Any]
        assertEqual(in: sentBy, forKey: "iconUrl", value: "https://example.com")
        XCTAssertNil(sentBy["linkUrl"])
    }
    
    func testTextMessageDecoding() {
        let decoder = JSONDecoder()
        let result = TextMessage.samplesData
            .map { try! decoder.decode(Message.self, from: $0) }
            .map { $0.asTextMessage! }
        
        XCTAssertEqual(result[0].type, .text)
        XCTAssertEqual(result[0].text, "Hello, world")
        XCTAssertNil(result[0].sender)
        
        XCTAssertNotNil(result[1].sender)
        XCTAssertEqual(result[1].sender!.label, "onevcat")
        XCTAssertEqual(result[1].sender!.iconURL, URL(string: "https://example.com")!)
        XCTAssertNil(result[1].sender!.linkURL)
    }
}
