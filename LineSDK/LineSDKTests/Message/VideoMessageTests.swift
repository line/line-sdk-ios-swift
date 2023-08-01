//
//  VideoMessageTests.swift
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

extension VideoMessage: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "video",
          "originalContentUrl": "https://example.com/example.mp4",
          "previewImageUrl": "https://example.com/preview.jpg"
        }
        """
        ]
    }
}

class VideoMessageTests: XCTestCase {
    
    func testVideoMessageEncoding() {
        let contentURL = URL(string: "https://example.com/original.mp4")!
        let previewImageURL = URL(string: "https://example.com/preview.jpg")!
        let videoMessage = try! VideoMessage(originalContentURL: contentURL, previewImageURL: previewImageURL)
        let message = Message.video(videoMessage)
        
        let dic = message.json
        assertEqual(in: dic, forKey: "type", value: "video")
        assertEqual(in: dic, forKey: "originalContentUrl", value: "https://example.com/original.mp4")
        assertEqual(in: dic, forKey: "previewImageUrl", value: "https://example.com/preview.jpg")
    }
 
    func testVideoMessageDecoding() {
        let decoder = JSONDecoder()
        let result = VideoMessage.samplesData
            .map { try! decoder.decode(Message.self, from: $0) }
            .map { $0.asVideoMessage! }
        XCTAssertEqual(result[0].type, .video)
        XCTAssertEqual(result[0].originalContentURL, URL(string: "https://example.com/example.mp4"))
        XCTAssertEqual(result[0].previewImageURL, URL(string: "https://example.com/preview.jpg"))
    }
    
    func testVideoMessageInitThrows() {
        let contentURL = URL(string: "http://example.com/original.png")!
        let previewImageURL = URL(string: "/example.com/preview.png")!
        XCTAssertThrowsError(
            try VideoMessage.init(
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
            try VideoMessage.init(
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
