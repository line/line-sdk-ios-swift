//
//  AdapterTests.swift
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

class AdapterTests: XCTestCase {
    
    var request: URLRequest!
    
    override func setUp() {
        super.setUp()
        request = URLRequest(url: URL(string: "linesdktest://sampleurl")!)
    }
    
    func testTokenAdapter() {
        let adapter = TokenAdapter(token: "123")
        let result = try! adapter.adapted(request)
        
        XCTAssertEqual(result.value(forHTTPHeaderField: "Authorization"), "Bearer 123")
    }
    
    func testHeaderAdapter() {
        let adapter = HeaderAdapter()
        guard let bundleID = Bundle.main.bundleIdentifier else {
            fatalError("Running LineSDK unit tests requires a host app.")
        }
        XCTAssertTrue(adapter.userAgent.hasPrefix(bundleID))
        XCTAssertTrue(adapter.userAgent.contains(Constant.SDKVersion))
        
        let result = try! adapter.adapted(request)
        XCTAssertEqual(result.value(forHTTPHeaderField: "User-Agent"), adapter.userAgent)
        XCTAssertEqual(result.value(forHTTPHeaderField: "Accept"), "application/json")
        XCTAssertEqual(
            result.value(forHTTPHeaderField: "Cache-Control"),
            "private, no-store, no-cache, must-revalidate")
    }
    
    func testAnyAdapter() {
        let adapter = AnyRequestAdapter { request in
            var request = request
            request.httpMethod = "FOO"
            return request
        }
        let result = try! adapter.adapted(request)
        XCTAssertEqual(result.httpMethod, "FOO")
    }
    
    func testHTTPMethodAdapter() {
        let methods: [HTTPMethod] = [.get, .post, .put, .delete]
        let requests: [URLRequest] = .init(
            repeating: URLRequest(url: URL(string: "linesdktest://sampleurl")!),
            count: methods.count
        )
        
        let s = zip(methods, requests)
        let result = try! s.map { (method, request) in
            return try method.adapter.adapted(request)
        }
        
        XCTAssertEqual(result[0].httpMethod, "GET")
        XCTAssertEqual(result[1].httpMethod, "POST")
        XCTAssertEqual(result[2].httpMethod, "PUT")
        XCTAssertEqual(result[3].httpMethod, "DELETE")
    }
    
    func testContentTypeAdapter() {
        let types: [ContentType] = [.none, .formUrlEncoded, .json]
        let requests: [URLRequest] = .init(
            repeating: URLRequest(url: URL(string: "linesdktest://sampleurl")!),
            count: types.count
        )
        let s = zip(types, requests)
        let result = try! s.map { (t, request) in
            return try t.adapter?.adapted(request)
        }
        
        let contentTypeHeader = "Content-Type"
        XCTAssertNil(result[0])
        XCTAssertEqual(
            result[1]?.value(forHTTPHeaderField: contentTypeHeader),
            "application/x-www-form-urlencoded; charset=utf-8")
        XCTAssertEqual(
            result[2]?.value(forHTTPHeaderField: contentTypeHeader),
            "application/json")
    }
}
