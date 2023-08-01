//
//  ColumnDataStoreTests.swift
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

class ColumnDataStoreTests: XCTestCase {

    var store: ColumnDataStore<Int>!
    var token: NotificationToken!

    override func setUp() {
        super.setUp()
        store = ColumnDataStore(columnCount: 3)
    }

    override func tearDown() {
        store = nil
        token = nil
        super.tearDown()
    }

    func testAppendData() {
        store.append(data: [1,2,3], to: 0)
        store.append(data: [4,5,6], to: 1)
        store.append(data: [7,8,9], to: 2)

        XCTAssertEqual(store.data(atColumn: 0), [1, 2, 3])
        XCTAssertEqual(store.data(atColumn: 1), [4, 5, 6])
        XCTAssertEqual(store.data(atColumn: 2), [7, 8, 9])

        store.append(data: [3,2,1], to: 0)
        XCTAssertEqual(store.data(atColumn: 0), [1, 2, 3, 3, 2, 1])
    }

    func testGetData() {
        store.append(data: [1,2,3], to: 0)
        XCTAssertEqual(store.data(atColumn: 0), [1, 2, 3])
        XCTAssertEqual(store.data(atColumn: 1), [])

        XCTAssertEqual(store.data(atColumn: 0, row: 1), 2)

        let index = ColumnDataStore<Int>.ColumnIndex(column: 0, row: 1)
        XCTAssertEqual(store.data(at: index), 2)
    }

    func testSelectData() {
        store.append(data: [1,2,3], to: 0)
        XCTAssertTrue(store.selectedIndexes.isEmpty)

        let performed = store.toggleSelect(atColumn: 0, row: 1)
        XCTAssertTrue(performed)

        XCTAssertEqual(store.selectedIndexes.count, 1)
        XCTAssertTrue(store.isSelected(at: .init(column: 0, row: 1)))

        let deselectPerformed = store.toggleSelect(atColumn: 0, row: 1)
        XCTAssertTrue(deselectPerformed)
        XCTAssertEqual(store.selectedIndexes.count, 0)
        XCTAssertFalse(store.isSelected(at: .init(column: 0, row: 1)))
    }

    func testMaximumSelection() {
        store.maximumSelectedCount = 2
        store.append(data: [1,2,3], to: 0)

        // Select two elements.
        XCTAssertTrue(store.toggleSelect(atColumn: 0, row: 0))
        XCTAssertTrue(store.toggleSelect(atColumn: 0, row: 1))

        // `maximumSelectedCount` count reached.
        XCTAssertFalse(store.toggleSelect(atColumn: 0, row: 2))

        // Unselect one.
        XCTAssertTrue(store.toggleSelect(atColumn: 0, row: 1))
        // Select the one failed again.
        XCTAssertTrue(store.toggleSelect(atColumn: 0, row: 2))

        // `maximumSelectedCount` count reached.
        XCTAssertFalse(store.toggleSelect(atColumn: 0, row: 1))

        XCTAssertTrue(store.isSelected(at: .init(column: 0, row: 0)))
        XCTAssertFalse(store.isSelected(at: .init(column: 0, row: 1)))
        XCTAssertTrue(store.isSelected(at: .init(column: 0, row: 2)))
    }

    func testFilterValues() {
        store.append(data: [1,2,3], to: 0)
        store.append(data: [4,5,6], to: 1)
        store.append(data: [7,8,9], to: 2)

        let result = store.indexes { $0 % 2 == 0 }
        let values = result.map { indexes in indexes.map { store.data(at: $0) } }
        XCTAssertEqual(values, [[2], [4, 6], [8]])
    }

    func testAppendingDataNotification() {
        let expect = expectation(description: "\(#file)_\(#line)")

        token = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidAppendData,
            object: nil,
            queue: .main)
        {
            noti in
            let range = noti.userInfo?[LineSDKNotificationKey.appendDataIndexRange]
                as? ColumnDataStore<Int>.AppendingIndexRange
            XCTAssertNotNil(range)
            XCTAssertEqual(range!.column, 0)
            XCTAssertEqual(range!.startIndex, 0)
            XCTAssertEqual(range!.endIndex, 3)
            expect.fulfill()
        }

        store.append(data: [1,2,3], to: 0)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSelectingDataNotification() {
        let expect = expectation(description: "\(#file)_\(#line)")

        token = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidSelect,
            object: nil,
            queue: .main)
        {
            noti in
            let index = noti.userInfo?[LineSDKNotificationKey.selectingIndex]
                as? ColumnDataStore<Int>.ColumnIndex
            XCTAssertNotNil(index)
            XCTAssertEqual(index!.column, 0)
            XCTAssertEqual(index!.row, 2)
            expect.fulfill()
        }

        store.append(data: [1,2,3], to: 0)
        store.toggleSelect(atColumn: 0, row: 2)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testDeselectingDataNotification() {
        let expect = expectation(description: "\(#file)_\(#line)")

        token = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidDeselect,
            object: nil,
            queue: .main)
        {
            noti in
            let index = noti.userInfo?[LineSDKNotificationKey.selectingIndex]
                as? ColumnDataStore<Int>.ColumnIndex
            XCTAssertNotNil(index)
            XCTAssertEqual(index!.column, 0)
            XCTAssertEqual(index!.row, 2)
            expect.fulfill()
        }

        store.append(data: [1,2,3], to: 0)
        store.toggleSelect(atColumn: 0, row: 2)
        store.toggleSelect(atColumn: 0, row: 2)
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAllSelectedData() {
        store.append(data: [1,2,3], to: 0)
        store.append(data: [4,5,6], to: 1)
        store.append(data: [7,8,9], to: 2)

        store.toggleSelect(atColumn: 0, row: 0)
        store.toggleSelect(atColumn: 1, row: 1)
        store.toggleSelect(atColumn: 2, row: 2)

        let allSelected = store.selectedData
        XCTAssertEqual(allSelected, [1, 5, 9])
    }
}
