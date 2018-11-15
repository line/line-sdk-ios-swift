//
//  ImageMessageTests.swift
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

extension ImageMessage: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "image",
          "originalContentUrl": "https://example.com/animation.gif",
          "previewImageUrl": "https://example.com/preview.jpg",
          "animated": true,
          "extension": "gif"
        }
        """,
        """
        {
          "type": "image",
          "originalContentUrl": "https://example.com/animation.gif",
          "previewImageUrl": "https://example.com/preview.jpg",
          "sentBy": {
            "label": "onevcat",
            "iconUrl": "https://example.com"
          }
        }
        """
        ]
    }
}

class ImageMessageTests: XCTestCase {
    
    func testImageMessageEncoding() {
        let contentURL = URL(string: "https://example.com/original.png")!
        let previewImageURL = URL(string: "https://example.com/preview.png")!
        let imageMessage = try! ImageMessage(
            originalContentURL: contentURL,
            previewImageURL: previewImageURL,
            animated: false,
            fileExtension: "png",
            sender: nil)
        let message = Message.image(imageMessage)
        
        let dic = message.json
        assertEqual(in: dic, forKey: "type", value: "image")
        assertEqual(in: dic, forKey: "originalContentUrl", value: "https://example.com/original.png")
        assertEqual(in: dic, forKey: "previewImageUrl", value: "https://example.com/preview.png")
        assertEqual(in: dic, forKey: "animated", value: false)
        assertEqual(in: dic, forKey: "extension", value: "png")
        XCTAssertNil(dic["sentBy"])
    }
    
    func testImageMessageWithSenderEncoding() {
        
        let contentURL = URL(string: "https://example.com/original.png")!
        let previewImageURL = URL(string: "https://example.com/preview.png")!
        let sender = MessageSender(label: "user", iconURL: URL(string: "https://example.com")!, linkURL: nil)
        
        let imageMessageWithSender = try! ImageMessage(
            originalContentURL: contentURL,
            previewImageURL: previewImageURL,
            sender: sender)
        let message = Message.image(imageMessageWithSender)
        
        let dic = message.json
        assertEqual(in: dic, forKey: "type", value: "image")
        assertEqual(in: dic, forKey: "originalContentUrl", value: "https://example.com/original.png")
        assertEqual(in: dic, forKey: "previewImageUrl", value: "https://example.com/preview.png")
        XCTAssertNil(dic["animated"])
        XCTAssertNil(dic["extension"])
        XCTAssertNotNil(dic["sentBy"])
        
        let sentBy = dic["sentBy"] as! [String: Any]
        assertEqual(in: sentBy, forKey: "iconUrl", value: "https://example.com")
        XCTAssertNil(sentBy["linkUrl"])
    }
    
    func testImageMessageDecoding() {
        let decoder = JSONDecoder()
        let result = ImageMessage.samplesData
            .map { try! decoder.decode(Message.self, from: $0) }
            .map { $0.asImageMessage! }
        
        let contentURL = URL(string: "https://example.com/animation.gif")!
        let previewImageURL = URL(string: "https://example.com/preview.jpg")!
        
        XCTAssertEqual(result[0].type, .image)
        XCTAssertEqual(result[0].originalContentURL, contentURL)
        XCTAssertEqual(result[0].previewImageURL, previewImageURL)
        XCTAssertEqual(result[0].animated, true)
        XCTAssertEqual(result[0].fileExtension, "gif")
        XCTAssertNil(result[0].sender)
        
        XCTAssertNil(result[1].animated)
        XCTAssertNil(result[1].fileExtension)
        XCTAssertNotNil(result[1].sender)
        XCTAssertEqual(result[1].sender!.label, "onevcat")
        XCTAssertEqual(result[1].sender!.iconURL, URL(string: "https://example.com")!)
        XCTAssertNil(result[1].sender!.linkURL)
    }
    
    func testImageMessageInitThrows() {
        let contentURL = URL(string: "http://example.com/original.png")!
        let previewImageURL = URL(string: "/example.com/preview.png")!
        XCTAssertThrowsError(
            try ImageMessage.init(
                originalContentURL: contentURL,
                previewImageURL: previewImageURL))
        {
            error in
            guard case .generalError(.parameterError(let name, _))? = error as? LineSDKError else {
                XCTFail("The error should be a `.parameterError`")
                return
            }
            XCTAssertEqual(name, "originalContentURL")
        }
        
        let correctContentURL = URL(string: "https://example.com/original.png")!
        XCTAssertThrowsError(
            try ImageMessage.init(
                originalContentURL: correctContentURL,
                previewImageURL: previewImageURL))
        {
            error in
            guard case .generalError(.parameterError(let name, _))? = error as? LineSDKError else {
                XCTFail("The error should be a `.parameterError`")
                return
            }
            XCTAssertEqual(name, "previewImageURL")
        }
    }
}
