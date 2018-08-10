//
//  APIResultEntryTests.swift
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
@testable import LineSDKSample

class APIResultEntryTests: XCTestCase {
    
    func testSimpleStruct() {
        let p = Person(name: "Tom", age: 20)
        let entries = Mirror.toEntries(p)
        
        XCTAssertEqual(entries.count, 2)
        
        XCTAssertEqual(entries[0], .pair("age", "20"))
        XCTAssertEqual(entries[1], .pair("name", "Tom"))
    }
    
    func testOptionalStruct() {
        let p = Pet(name: "Meow", nickName: nil, dog: false)
        
        let entries = Mirror.toEntries(p)
        
        XCTAssertEqual(entries.count, 3)
        
        XCTAssertEqual(entries[0], .pair("dog", "false"))
        XCTAssertEqual(entries[1], .pair("name", "Meow"))
        XCTAssertEqual(entries[2], .pair("nickName", "nil"))
    }
    
    func testArrayValues() {
        let s = Street(numbers: [1, 2, 3, 4, 5])
        let entries = Mirror.toEntries(s)
        
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries[0],
                       .array("numbers", [
                        .pair("numbers[0]", "1"),
                        .pair("numbers[1]", "2"),
                        .pair("numbers[2]", "3"),
                        .pair("numbers[3]", "4"),
                        .pair("numbers[4]", "5"),
                        ]))
    }
    
    func testNestedValues() {
        let john = Person(name: "John", age: 34)
        let lily = Person(name: "Lily", age: 24)
        let tom = Person(name: "Tom", age: 20)
        let o = Office(name: "Office", leader: john, persons: [lily, tom])
        
        let entries = Mirror.toEntries(o)
        
        XCTAssertEqual(entries.count, 3)
        
        if case APIResultEntry.nested(let key, let leader) = entries[0] {
            XCTAssertEqual(key, "leader")
            XCTAssertEqual(leader, Mirror.toEntries(john))
        } else {
            XCTFail()
        }
        
        XCTAssertEqual(entries[1], .pair("name", "Office"))
        
        if case APIResultEntry.array(let key, let persons) = entries[2] {
            XCTAssertEqual(key, "persons")
            XCTAssertEqual(persons.count, 2)
            XCTAssertEqual(persons[0], .nested("persons[0]", Mirror.toEntries(lily)))
            XCTAssertEqual(persons[1], .nested("persons[1]", Mirror.toEntries(tom)))
        } else {
            XCTFail()
        }
    }
}

struct Person {
    let name: String
    let age: Int
}

struct Pet {
    let name: String
    let nickName: String?
    let dog: Bool
}

struct Street {
    let numbers: [Int]
}

struct Office {
    let name: String
    let leader: Person
    let persons: [Person]
}
