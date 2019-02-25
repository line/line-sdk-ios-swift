//
//  ResultUtilsTests.swift
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

class ResultUtilsTests: XCTestCase {

    enum E: Error {
        case foo
        case bar
    }

    enum AnotherE: Error {
        case baz
    }

    let success = Result<Int, E>.success(1)
    let failure = Result<Int, E>.failure(.foo)

    func testResultGet() {

        let value = try! success.get()
        XCTAssertEqual(value, 1)

        do {
            _ = try failure.get()
            XCTFail("Cannot failure value.")
        } catch {
            XCTAssertEqual(error as! E, E.foo)
        }
    }

    func testResultMap() {
        let value = success.map { $0 + 1 }
        XCTAssertEqual(value, .success(2))

        let fValue = failure.map { $0 + 1 }
        XCTAssertEqual(fValue, .failure(.foo))
    }

    func testResultMapError() {
        let value = success.mapError { _ in return E.bar }
        XCTAssertEqual(value, .success(1))

        let fValue = failure.mapError { _ in return E.bar }
        XCTAssertEqual(fValue, .failure(.bar))
    }

    func testResultFlatMap() {
        let value = success.flatMap { .success(String($0)) }
        XCTAssertEqual(value, .success("1"))

        let fValue = failure.flatMap { .success(String($0)) }
        XCTAssertEqual(fValue, .failure(.foo))
    }

    func testResultFlatMapError() {
        let value = success.flatMapError { _ in return .failure(AnotherE.baz) }
        XCTAssertEqual(value, .success(1))

        let fValue = failure.flatMapError { _ in return .failure(AnotherE.baz) }
        XCTAssertEqual(fValue, .failure(.baz))
    }

    func testResultMatchSuccess() {
        let value = success.match(
            onSuccess: { (num: Int) -> Int in
                XCTAssertEqual(num, 1)
                return num + 1
            },
            onFailure: { _ in
                XCTFail()
                return -1
            }
        )
        XCTAssertEqual(value, 2)
    }

    func testResultMatchFailure() {
        let value = failure.match(
            onSuccess: { _ -> Int in
                XCTFail()
                return -1
            },
            onFailure: { error in
                XCTAssertEqual(error, .foo)
                return 0
            }
        )
        XCTAssertEqual(value, 0)
    }

    func testResultMatchWithFolder() {
        let folder: (Int?, Error?) -> Bool = {num, err in
            if let _ = num {
                return true
            } else {
                return false
            }
        }
        let value1 = success.match(with: folder)
        XCTAssertEqual(value1, true)

        let value2 = failure.match(with: folder)
        XCTAssertEqual(value2, false)
    }

    func testResultMatchSuccessWithFolder() {
        let folder: (Int?) -> Bool = {num in
            if let _ = num {
                return true
            } else {
                return false
            }
        }
        let value1 = success.matchSuccess(with: folder)
        XCTAssertEqual(value1, true)

        let value2 = failure.matchSuccess(with: folder)
        XCTAssertEqual(value2, false)
    }

    func testResultMatchFailureWithFolder() {
        let folder: (Error?) -> Bool = {error in
            if let _ = error {
                return false
            } else {
                return true
            }
        }
        let value1 = success.matchFailure(with: folder)
        XCTAssertEqual(value1, true)

        let value2 = failure.matchFailure(with: folder)
        XCTAssertEqual(value2, false)
    }
}
