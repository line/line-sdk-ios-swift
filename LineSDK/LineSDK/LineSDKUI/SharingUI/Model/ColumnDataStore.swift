//
//  ColumnDataStore.swift
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

import Foundation

extension Notification.Name {
    static let columnDataStoreDidAppendData = Notification.Name("com.linecorp.linesdk.columnDataStoreDidAppendData")
    static let columnDataStoreDidSelect = Notification.Name("com.linecorp.linesdk.columnDataStoreDidSelect")
    static let columnDataStoreDidDeselect = Notification.Name("com.linecorp.linesdk.columnDataStoreDidDeselect")
}

extension LineSDKNotificationKey {
    static let appendDataIndexRange = "appendDataIndexRange"
    static let selectingIndex = "selectingIndex"
    static let positionInSelected = "positionInSelected"
}

// A column-based data structure. It makes it easier to store and interact with data in a 2D array.
class ColumnDataStore<T> {

    struct ColumnIndex: Equatable {
        let column: Int
        let row: Int
    }

    struct AppendingIndexRange {
        let startIndex: Int
        let endIndex: Int
        let column: Int
    }

    var selectedData: [T] {
        return selectedIndexes.map { data(at: $0) }
    }

    var maximumSelectedCount = 10

    private var data: [[T]]
    private(set) var selectedIndexes: [ColumnIndex] = []
    private var columnCount: Int { return data.count }

    init(columnCount: Int) {
        data = .init(repeating: [], count: columnCount)
    }

    func append(data appendingData: [T], to columnIndex: Int) {
        var column = data(atColumn: columnIndex)

        let startIndex = column.count

        column.append(contentsOf: appendingData)
        data[columnIndex] = column

        let endIndex = column.count
        let indexRange = AppendingIndexRange(startIndex: startIndex, endIndex: endIndex, column: columnIndex)

        // Make sure the notification is delivered on the main thread, because it's often used to update the UI.
        CallbackQueue.currentMainOrAsync.execute {
            NotificationCenter.default.post(
                name: .columnDataStoreDidAppendData,
                object: self,
                userInfo: [LineSDKNotificationKey.appendDataIndexRange: indexRange]
            )
        }
    }

    func data(atColumn column: Int) -> [T] {
        precondition(column < columnCount, "Input index `column` is out of range. Data range: 0..<\(data.count)")
        return data[column]
    }

    func data(atColumn column: Int, row: Int) -> T {
        return data[column][row]
    }

    func data(at index: ColumnIndex) -> T {
        return data(atColumn: index.column, row: index.row)
    }

    func isSelected(at index: ColumnIndex) -> Bool {
        return selectedIndexes.contains(index)
    }

    // Return `false` if the toggle failed due to reaching `maximumSelectedCount`.
    @discardableResult
    func toggleSelect(atColumn columnIndex: Int, row rowIndex: Int) -> Bool {

        func notifySelectingChange(selected: Bool, targetIndex: ColumnIndex, positionInSelected: Int) {
            NotificationCenter.default.post(
                name: selected ? .columnDataStoreDidSelect : .columnDataStoreDidDeselect,
                object: self,
                userInfo: [LineSDKNotificationKey.selectingIndex: targetIndex,
                           LineSDKNotificationKey.positionInSelected: positionInSelected]
            )
        }

        let targetIndex = ColumnIndex(column: columnIndex, row: rowIndex)
        if let index = selectedIndexes.firstIndex(of: targetIndex) {
            selectedIndexes.remove(at: index)
            notifySelectingChange(selected: false, targetIndex: targetIndex, positionInSelected: index)
        } else {
            guard selectedIndexes.count < maximumSelectedCount else {
                return false
            }
            selectedIndexes.append(targetIndex)
            notifySelectingChange(selected: true, targetIndex: targetIndex, positionInSelected: selectedIndexes.count - 1)
        }

        return true
    }

    func indexes(atColumn column: Int, where filtered: ((T) -> Bool)) -> [ColumnIndex] {
        return data(atColumn: column)
            .enumerated()
            .filter { _, elem in filtered(elem) }
            .map { ColumnIndex(column: column, row: $0.offset) }
    }

    func indexes(where filtered: ((T) -> Bool)) -> [[ColumnIndex]] {
        return (0 ..< data.count).map { indexes(atColumn: $0, where: filtered) }
    }
}
