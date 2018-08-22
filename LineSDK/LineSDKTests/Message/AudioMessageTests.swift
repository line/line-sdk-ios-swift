//
//  AudioMessageTests.swift
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

extension AudioMessage: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "audio",
          "originalContentUrl": "https://example.com/example.mp3",
          "duration": 15000
        }
        """,
        """
        {
          "type": "audio",
          "originalContentUrl": "https://example.com/example.mp3"
        }
        """
        ]
    }
}

class AudioMessageTests: XCTestCase {
    
    func testAudioMessageEncoding() {
        let contentURL = URL(string: "https://example.com/example.mp3")!
        let audioMessage = try! AudioMessage(originalContentURL: contentURL, duration: 3.0)
        let message = Message.audio(audioMessage)
        
        let dic = message.json
        assertEqual(in: dic, forKey: "type", value: "audio")
        assertEqual(in: dic, forKey: "originalContentUrl", value: "https://example.com/example.mp3")
        assertEqual(in: dic, forKey: "duration", value: 3000)
    }
    
    func testAudioMessageWithoutDurationEncoding() {
        let contentURL = URL(string: "https://example.com/example.mp3")!
        let audioMessage = try! AudioMessage(originalContentURL: contentURL, duration: nil)
        let message = Message.audio(audioMessage)
        
        XCTAssertNil(audioMessage.duration)
        
        let dic = message.json
        assertEqual(in: dic, forKey: "type", value: "audio")
        assertEqual(in: dic, forKey: "originalContentUrl", value: "https://example.com/example.mp3")
        XCTAssertNil(dic["duration"])
    }
    
    func testAudioMessageDecoding() {
        let decoder = JSONDecoder()
        let result = AudioMessage.samplesData
            .map { try! decoder.decode(Message.self, from: $0) }
            .map { $0.asAudioMessage! }
        XCTAssertEqual(result[0].type, .audio)
        XCTAssertEqual(result[0].originalContentURL, URL(string: "https://example.com/example.mp3"))
        XCTAssertEqual(result[0].duration, 15)
        
        XCTAssertNil(result[1].duration)
    }
    
    func testVideoMessageInitThrows() {
        let contentURL = URL(string: "http://example.com/example.mp3")!
        XCTAssertThrowsError(try AudioMessage(originalContentURL: contentURL, duration: nil)) {
            error in
            guard case .generalError(.parameterError(let name, _))? = error as? LineSDKError else {
                XCTFail("The error should be a `.parameterError`")
                return
            }
            XCTAssertEqual(name, "originalContentURL")
        }
    }
    
    
    func testDurationChange() {
        let contentURL = URL(string: "https://example.com/example.mp3")!
        var audioMessage = try! AudioMessage(originalContentURL: contentURL, duration: 3.0)
        XCTAssertEqual(audioMessage.durationInMilliseconds, 3000)
        XCTAssertEqual(audioMessage.duration, 3.0)
        
        audioMessage.duration = 1.5
        XCTAssertEqual(audioMessage.duration, 1.5)
        XCTAssertEqual(audioMessage.durationInMilliseconds, 1500)
    }
}
