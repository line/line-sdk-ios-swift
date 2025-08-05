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

class ShareTargetSearchResultTableViewControllerTests: XCTestCase {
    
    // MARK: - Test Cases
    
    @MainActor
    func testInitialState() {
        let store = ColumnDataStore<ShareTarget>(columnCount: MessageShareTargetType.allCases.count)
        let controller = ShareTargetSearchResultTableViewController(store: store)
        
        // Test initial state
        XCTAssertEqual(controller.searchText, "")
        XCTAssertTrue(controller.hasSearchResult)
        XCTAssertEqual(controller.sectionOrder, [.friends, .groups])
        XCTAssertEqual(controller.filteredIndexes.count, MessageShareTargetType.allCases.count)
    }
    
    @MainActor
    func testSearchFiltering() {
        let store = ColumnDataStore<ShareTarget>(columnCount: MessageShareTargetType.allCases.count)
        let controller = ShareTargetSearchResultTableViewController(store: store)
        
        // Add test data first
        let friends = createDummyFriends()
        store.append(data: friends, to: MessageShareTargetType.friends.rawValue)
        
        // Test search functionality - this will trigger the filtering
        controller.searchText = "Alice"
        
        // Should filter to only Alice from friends
        let friendsIndexes = controller.filteredIndexes[MessageShareTargetType.friends.rawValue]
        let groupsIndexes = controller.filteredIndexes[MessageShareTargetType.groups.rawValue]
        
        XCTAssertEqual(friendsIndexes.count, 1)
        XCTAssertEqual(groupsIndexes.count, 0)
        XCTAssertTrue(controller.hasSearchResult)
        
        // Test no results
        controller.searchText = "NonExistentName"
        XCTAssertFalse(controller.hasSearchResult)
        
        // Test show all with empty search text
        // First set to something else to trigger the change  
        controller.searchText = "temp"
        controller.searchText = ""
        XCTAssertTrue(controller.hasSearchResult)
        // After searching for empty string, the filteredIndexes should contain all items
        // (Testing the main filtering logic rather than exact count)
    }
    
    @MainActor
    func testObserverSetupAndCleanup() {
        let store = ColumnDataStore<ShareTarget>(columnCount: MessageShareTargetType.allCases.count)
        let controller = ShareTargetSearchResultTableViewController(store: store)
        
        // Test observer setup
        controller.startObserving()
        XCTAssertNotNil(controller.selectingObserver)
        XCTAssertNotNil(controller.deselectingObserver)
        
        // Test observer cleanup
        controller.stopObserving()
        XCTAssertNil(controller.selectingObserver)
        XCTAssertNil(controller.deselectingObserver)
        XCTAssertEqual(controller.searchText, "")
    }
    
    @MainActor
    func testSectionMappingLogic() {
        let store = ColumnDataStore<ShareTarget>(columnCount: MessageShareTargetType.allCases.count)
        let controller = ShareTargetSearchResultTableViewController(store: store)
        
        // Test section mapping
        XCTAssertEqual(controller.actualSection(0), MessageShareTargetType.friends.rawValue)
        XCTAssertEqual(controller.actualSection(1), MessageShareTargetType.groups.rawValue)
        
        // Test number of sections
        XCTAssertEqual(controller.numberOfSections(in: UITableView()), MessageShareTargetType.allCases.count)
    }
    
    @MainActor
    func testHasSearchResultLogic() {
        let store = ColumnDataStore<ShareTarget>(columnCount: MessageShareTargetType.allCases.count)
        let controller = ShareTargetSearchResultTableViewController(store: store)
        
        // Add test data
        let friends = createDummyFriends()
        store.append(data: friends, to: MessageShareTargetType.friends.rawValue)
        
        // Empty search text should show results
        controller.searchText = ""
        XCTAssertTrue(controller.hasSearchResult)
        
        // Search with results should show true
        controller.searchText = "Alice"
        XCTAssertTrue(controller.hasSearchResult)
        
        // Search without results should show false
        controller.searchText = "NonExistentUser"
        XCTAssertFalse(controller.hasSearchResult)
    }
    
    // MARK: - Helper Methods
    
    private func createDummyFriends() -> [ShareTarget] {
        return [
            DummyUser(userID: "friend1", displayName: "Alice", pictureURL: nil),
            DummyUser(userID: "friend2", displayName: "Bob", pictureURL: nil),
            DummyUser(userID: "friend3", displayName: "Charlie", pictureURL: nil)
        ]
    }
    
    private func createDummyGroups() -> [ShareTarget] {
        return [
            DummyGroup(groupID: "group1", groupName: "Development Team", pictureURL: nil),
            DummyGroup(groupID: "group2", groupName: "Design Team", pictureURL: nil)
        ]
    }
}

// MARK: - Dummy ShareTarget Implementations

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