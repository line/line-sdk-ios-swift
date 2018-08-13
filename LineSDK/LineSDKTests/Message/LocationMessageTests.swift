//
//  LocationMessageTests.swift
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

extension LocationMessage: MessageSample {
    static var samples: [String] {
        return [
        """
        {
          "type": "location",
          "title": "My Location",
          "address": "My Address",
          "latitude": 35.65910807942215,
          "longitude": 139.70372892916203
        }
        """
        ]
    }
}

class LocationMessageTests: XCTestCase {
    
    func testLocationMessageEncoding() {
        let locationMessage = LocationMessage(title: "abc", address: "123", latitude: 100.0, longitude: 200.0)
        let message = Message.location(locationMessage)
        
        let dic = message.json
        assertEqual(in: dic, forKey: "type", value: "location")
        assertEqual(in: dic, forKey: "title", value: "abc")
        assertEqual(in: dic, forKey: "address", value: "123")
        assertEqual(in: dic, forKey: "latitude", value: 100.0)
        assertEqual(in: dic, forKey: "longitude", value: 200.0)
    }
    
    func testLocationMessageDecoding() {
        let decoder = JSONDecoder()
        let result = LocationMessage.samplesData
            .map { try! decoder.decode(Message.self, from: $0) }
            .map { $0.asLocationMessage! }
        XCTAssertEqual(result[0].type, .location)
        XCTAssertEqual(result[0].title, "My Location")
        XCTAssertEqual(result[0].address, "My Address")
        XCTAssertEqual(result[0].latitude, 35.65910807942215, accuracy: 0.01)
        XCTAssertEqual(result[0].longitude, 139.70372892916203, accuracy: 0.01)
    }
}
