//
//  KeychainStoreTests.swift
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

class KeychainStoreTests: XCTestCase {
    
    var keychianStore: KeychainStore!
    
    override func setUp() {
        super.setUp()
        keychianStore = KeychainStore(service: "test")
        try! keychianStore.removeAll()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testString() {
        do {
            // Adding
            try keychianStore.set("123", for: "user")
            try keychianStore.set("abc", for: "pass")
            
            let user = try keychianStore.string(for: "user")
            XCTAssertEqual(user, "123")
            let pass = try keychianStore.string(for: "pass")
            XCTAssertEqual(pass, "abc")
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        do {
            // Updating
            try keychianStore.set("321", for: "user")
            try keychianStore.set("xyz", for: "pass")
            
            let user = try keychianStore.string(for: "user")
            XCTAssertEqual(user, "321")
            let pass = try keychianStore.string(for: "pass")
            XCTAssertEqual(pass, "xyz")
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        do {
            // Removing
            try keychianStore.remove("user")
            try keychianStore.remove("pass")
            
            let user = try keychianStore.string(for: "user")
            XCTAssertNil(user)
            let pass = try keychianStore.string(for: "pass")
            XCTAssertNil(pass)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testCodable() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        do {
            // Adding
            let value = Value(foo: "hello", bar: 100)
            try keychianStore.set(value, for: "key1", using: encoder)
            let obj: Value? = try keychianStore.value(for: "key1", using: decoder)
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj?.foo, "hello")
            XCTAssertEqual(obj?.bar, 100)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        do {
            // Updating
            let value = Value(foo: "world", bar: 999)
            try keychianStore.set(value, for: "key1", using: encoder)
            let obj: Value? = try keychianStore.value(for: "key1", using: decoder)
            XCTAssertNotNil(obj)
            XCTAssertEqual(obj?.foo, "world")
            XCTAssertEqual(obj?.bar, 999)
        } catch {
            XCTFail(error.localizedDescription)
        }
        
        do {
            // Removing
            try keychianStore.remove("key1")
            let obj: Value? = try keychianStore.value(for: "key1", using: decoder)
            XCTAssertNil(obj)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testEmptyCase() {
        do {
            let user = try keychianStore.string(for: "user")
            XCTAssertNil(user)
            // No throw to remove an empty entry
            try keychianStore.remove("user")
        } catch {
            XCTFail(error.localizedDescription)
        }
        
    }
}

struct Value: Codable {
    let foo: String
    let bar: Int
}
