//
//  ParameterEncoderTests.swift
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

class ParameterEncoderTests: XCTestCase {
    
    var request: URLRequest!
    
    override func setUp() {
        super.setUp()
        request = URLRequest(url: URL(string: "linesdktest://sampleurl")!)
    }
    
    func testURLQueryEncoderEncodeQuery() {
        let encoder = URLQueryEncoder(parameters: ["foo": "bar", "num": 123, "switch": true])
        let url = URL(string: "linesdktest://sampleurl")!
        let result = encoder.encoded(for: url)
        
        let components = URLComponents(url: result, resolvingAgainstBaseURL: false)
        XCTAssertNotNil(components?.queryItems)
        XCTAssertEqual(components?.queryItems?.count, 3)
        
        let info = extractQueryItems(from: components)
        
        XCTAssertEqual(info["foo"], "bar")
        XCTAssertEqual(info["num"], "123")
        XCTAssertEqual(info["switch"], "true")
    }
    
    func testURLQueryEncoderEncodeQueryEscaping() {
        let encoder = URLQueryEncoder(parameters: ["name": "Wei Wang", "mail": "foo@bar.com", "state": "😂"])
        let url = URL(string: "linesdktest://sampleurl")!
        let result = encoder.encoded(for: url)
        
        let components = URLComponents(url: result, resolvingAgainstBaseURL: false)!
        XCTAssertTrue(result.absoluteString.contains(components.percentEncodedQuery!))
        XCTAssertTrue(result.absoluteString.contains("%F0%9F%98%82"))
        
        let info = extractQueryItems(from: components)
        XCTAssertEqual(info["name"], "Wei Wang")
        XCTAssertEqual(info["mail"], "foo@bar.com")
        XCTAssertEqual(info["state"], "😂")
        XCTAssertEqual(info["state"]!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), "%F0%9F%98%82")
    }
    
    func testURLQueryEncoderAdaptingRequest() {
        let encoder = URLQueryEncoder(parameters: ["foo": "bar", "num": 123, "switch": true])
        let result = try! encoder.adapted(request)
        
        XCTAssertNotNil(result.url)
        XCTAssertNotEqual(result.url, request.url)
        
        let components = URLComponents(url: result.url!, resolvingAgainstBaseURL: false)!
        let info = extractQueryItems(from: components)

        XCTAssertEqual(info["foo"], "bar")
        XCTAssertEqual(info["num"], "123")
        XCTAssertEqual(info["switch"], "true")
    }
    
    func testJSONParameterEncoder() {
        let encoder = JSONParameterEncoder(parameters: ["foo": "bar", "num": 123, "switch": true, "state": "😂"])
        let result = try! encoder.adapted(request)
        let data = result.httpBody!
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        
        XCTAssertEqual(json["foo"] as? String, "bar")
        XCTAssertEqual((json["num"] as? NSNumber)?.intValue, 123)
        XCTAssertEqual((json["switch"] as? NSNumber)?.boolValue, true)
        XCTAssertEqual(json["state"] as? String, "😂")
    }
    
    func testFormUrlEncodedParameterEncoder() {
        let encoder = FormUrlEncodedParameterEncoder(parameters: ["foo": "bar", "num": 123, "switch": true, "state": "😂"])
        let result = try! encoder.adapted(request)
        let data = result.httpBody!
        let string = String(data: data, encoding: .utf8)!
        
        let queries = string.split(separator: "&")
        var info: [String: String] = [:]
        queries.forEach { query in
            let pair = query.split(separator: "=")
            info[String(pair[0])] = String(pair[1])
        }
        
        XCTAssertEqual(info["foo"], "bar")
        XCTAssertEqual(info["num"], "123")
        XCTAssertEqual(info["switch"], "true")
        XCTAssertEqual(info["state"], "😂".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
    }
    
    private func extractQueryItems(from components: URLComponents?) -> [String: String] {
        guard let components = components, let items = components.queryItems else {
            return [:]
        }
        let sequence = zip(items.map { $0.name }, items.map { $0.value! })
        return Dictionary(uniqueKeysWithValues: sequence)
    }
}
