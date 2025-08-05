//
//  ShareTargetSearchResultTableViewControllerTests.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

@MainActor
class ShareTargetSearchResultTableViewControllerTests: XCTestCase {
    
    // MARK: - Properties
    
    private var store: ColumnDataStore<ShareTarget>!
    private var controller: ShareTargetSearchResultTableViewController!
    private let testIndex = ColumnDataStore<ShareTarget>.ColumnIndex(column: MessageShareTargetType.friends.rawValue, row: 0)
    
    // MARK: - Setup & Teardown
    
    override func setUp() async throws {
        store = ColumnDataStore<ShareTarget>(columnCount: MessageShareTargetType.allCases.count)
        controller = ShareTargetSearchResultTableViewController(store: store)
    }
    
    override func tearDown() async throws {
        controller?.stopObserving()
        controller = nil
        store = nil
    }
    
    // MARK: - Core Functionality Tests

    func testInitialState() {
        XCTAssertEqual(controller.searchText, "")
        XCTAssertTrue(controller.hasSearchResult)
        XCTAssertEqual(controller.sectionOrder, [.friends, .groups])
        XCTAssertEqual(controller.filteredIndexes.count, MessageShareTargetType.allCases.count)
    }

    func testSearchFiltering() {
        // Setup test data
        store.append(data: TestData.friends, to: MessageShareTargetType.friends.rawValue)
        
        // Test specific search
        controller.searchText = "Alice"
        XCTAssertEqual(controller.filteredIndexes[MessageShareTargetType.friends.rawValue].count, 1)
        XCTAssertEqual(controller.filteredIndexes[MessageShareTargetType.groups.rawValue].count, 0)
        XCTAssertTrue(controller.hasSearchResult)
        
        // Test no results
        controller.searchText = "NonExistent"
        XCTAssertFalse(controller.hasSearchResult)
        
        // Test empty search (show all)
        controller.searchText = "temp"  // Trigger change
        controller.searchText = ""
        XCTAssertTrue(controller.hasSearchResult)
    }

    func testObserverLifecycle() {
        // Test setup
        controller.startObserving()
        XCTAssertNotNil(controller.selectingObserver)
        XCTAssertNotNil(controller.deselectingObserver)
        
        // Test cleanup
        controller.stopObserving()
        XCTAssertNil(controller.selectingObserver)
        XCTAssertNil(controller.deselectingObserver)
        XCTAssertEqual(controller.searchText, "")
    }

    func testSectionMapping() {
        XCTAssertEqual(controller.actualSection(0), MessageShareTargetType.friends.rawValue)
        XCTAssertEqual(controller.actualSection(1), MessageShareTargetType.groups.rawValue)
        XCTAssertEqual(controller.numberOfSections(in: UITableView()), MessageShareTargetType.allCases.count)
    }
    
    // MARK: - Observer Tests

    func testObserverNotifications() {
        setupControllerForObserverTests()
        
        // Test select notification
        sendNotification(.columnDataStoreDidSelect)
        
        // Test deselect notification  
        sendNotification(.columnDataStoreDidDeselect)
        
        // Verify handleSelectingChange logic components
        let foundRow = controller.filteredIndexes[testIndex.column].firstIndex(of: testIndex)
        XCTAssertNotNil(foundRow)
        XCTAssertEqual(controller.actualSection(testIndex.column), MessageShareTargetType.friends.rawValue)
        XCTAssertEqual(store.data(at: testIndex).displayName, "Alice")
    }
    
    // MARK: - TableView Tests

    func testTableViewDataSource() {
        setupControllerForTableViewTests()
        
        let tableView = controller.tableView!
        
        // Test sections
        XCTAssertEqual(controller.numberOfSections(in: tableView), MessageShareTargetType.allCases.count)
        
        // Test empty state
        testEmptyTableViewState(tableView)
        
        // Test with data
        populateFilteredIndexes()
        testPopulatedTableViewState(tableView)
        
        // Test filtered state
        testFilteredTableViewState(tableView)
    }
    
    // MARK: - Helper Methods

    private func setupControllerForObserverTests() {
        controller.loadViewIfNeeded()
        controller.viewDidLoad()
        store.append(data: TestData.friends, to: MessageShareTargetType.friends.rawValue)
        controller.filteredIndexes[MessageShareTargetType.friends.rawValue] = [testIndex]
        controller.tableView.register(ShareTargetSelectingTableCell.self, forCellReuseIdentifier: ShareTargetSelectingTableCell.reuseIdentifier)
        controller.startObserving()
    }

    private func setupControllerForTableViewTests() {
        controller.loadViewIfNeeded()
        controller.viewDidLoad()
        store.append(data: TestData.friends, to: MessageShareTargetType.friends.rawValue)
        store.append(data: TestData.groups, to: MessageShareTargetType.groups.rawValue)
    }

    private func sendNotification(_ name: Notification.Name) {
        NotificationCenter.default.post(
            name: name,
            object: store,
            userInfo: [
                LineSDKNotificationKey.selectingIndex: testIndex,
                LineSDKNotificationKey.positionInSelected: 0
            ]
        )
    }

    private func testEmptyTableViewState(_ tableView: UITableView) {
        XCTAssertEqual(controller.tableView(tableView, numberOfRowsInSection: 0), 0)
        XCTAssertEqual(controller.tableView(tableView, numberOfRowsInSection: 1), 0)
        XCTAssertEqual(controller.tableView(tableView, heightForHeaderInSection: 0), 0)
        XCTAssertEqual(controller.tableView(tableView, heightForHeaderInSection: 1), 0)
        XCTAssertNil(controller.tableView(tableView, viewForHeaderInSection: 0))
        XCTAssertNil(controller.tableView(tableView, viewForHeaderInSection: 1))
    }

    private func populateFilteredIndexes() {
        controller.filteredIndexes[MessageShareTargetType.friends.rawValue] = TestData.friendsIndexes
        controller.filteredIndexes[MessageShareTargetType.groups.rawValue] = TestData.groupsIndexes
    }

    private func testPopulatedTableViewState(_ tableView: UITableView) {
        // Test row counts
        XCTAssertEqual(controller.tableView(tableView, numberOfRowsInSection: 0), TestData.friends.count)
        XCTAssertEqual(controller.tableView(tableView, numberOfRowsInSection: 1), TestData.groups.count)
        
        // Test header heights
        let expectedHeight = ShareTargetSelectingSectionHeaderView.Design.height
        XCTAssertEqual(controller.tableView(tableView, heightForHeaderInSection: 0), expectedHeight)
        XCTAssertEqual(controller.tableView(tableView, heightForHeaderInSection: 1), expectedHeight)
        
        // Test header views
        let headerView0 = controller.tableView(tableView, viewForHeaderInSection: 0)
        let headerView1 = controller.tableView(tableView, viewForHeaderInSection: 1)
        XCTAssertTrue(headerView0 is ShareTargetSelectingSectionHeaderView)
        XCTAssertTrue(headerView1 is ShareTargetSelectingSectionHeaderView)
        
        // Test cell creation
        let cell = controller.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertTrue(cell is ShareTargetSelectingTableCell)
    }

    private func testFilteredTableViewState(_ tableView: UITableView) {
        // Simulate filtered state (only Alice)
        controller.filteredIndexes[MessageShareTargetType.friends.rawValue] = [testIndex]
        controller.filteredIndexes[MessageShareTargetType.groups.rawValue] = []
        
        XCTAssertEqual(controller.tableView(tableView, numberOfRowsInSection: 0), 1)
        XCTAssertEqual(controller.tableView(tableView, numberOfRowsInSection: 1), 0)
        XCTAssertEqual(controller.tableView(tableView, heightForHeaderInSection: 0), ShareTargetSelectingSectionHeaderView.Design.height)
        XCTAssertEqual(controller.tableView(tableView, heightForHeaderInSection: 1), 0)
        XCTAssertNotNil(controller.tableView(tableView, viewForHeaderInSection: 0))
        XCTAssertNil(controller.tableView(tableView, viewForHeaderInSection: 1))
    }
}

// MARK: - Test Data

private enum TestData {
    static let friends: [ShareTarget] = [
        DummyUser(userID: "friend1", displayName: "Alice", pictureURL: nil),
        DummyUser(userID: "friend2", displayName: "Bob", pictureURL: nil),
        DummyUser(userID: "friend3", displayName: "Charlie", pictureURL: nil)
    ]
    
    static let groups: [ShareTarget] = [
        DummyGroup(groupID: "group1", groupName: "Development Team", pictureURL: nil),
        DummyGroup(groupID: "group2", groupName: "Design Team", pictureURL: nil)
    ]
    
    static let friendsIndexes = [
        ColumnDataStore<ShareTarget>.ColumnIndex(column: MessageShareTargetType.friends.rawValue, row: 0),
        ColumnDataStore<ShareTarget>.ColumnIndex(column: MessageShareTargetType.friends.rawValue, row: 1),
        ColumnDataStore<ShareTarget>.ColumnIndex(column: MessageShareTargetType.friends.rawValue, row: 2)
    ]
    
    static let groupsIndexes = [
        ColumnDataStore<ShareTarget>.ColumnIndex(column: MessageShareTargetType.groups.rawValue, row: 0),
        ColumnDataStore<ShareTarget>.ColumnIndex(column: MessageShareTargetType.groups.rawValue, row: 1)
    ]
}

// MARK: - Mock Objects

private struct DummyUser: ShareTarget, Sendable {
    let userID: String
    let displayName: String
    let pictureURL: URL?
    
    var targetID: String { return userID }
    var avatarURL: URL? { return pictureURL }
}

private struct DummyGroup: ShareTarget, Sendable {
    let groupID: String
    let groupName: String  
    let pictureURL: URL?
    
    var targetID: String { return groupID }
    var displayName: String { return groupName }
    var avatarURL: URL? { return pictureURL }
}
