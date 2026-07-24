//
//  AccessTokenStoreTests.swift
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
import Security
@testable import LineSDK

@MainActor
class AccessTokenStoreTests: XCTestCase, Sendable {

    override func setUp() async throws {
        LoginManager.shared.setup(channelID: "123", universalLinkURL: nil)
        try? AccessTokenStore.shared.removeCurrentAccessToken()
    }

    override func tearDown() async throws {
        restoreKeychainFunctions()
        try? AccessTokenStore.shared.removeCurrentAccessToken()
        LoginManager.shared.resetForTesting()
    }

    private func makeToken(value: String) -> AccessToken {
        let data = """
        {
        "scope":"profile openid",
        "access_token":"\(value)",
        "token_type":"Bearer",
        "refresh_token":"refresh_\(value)",
        "expires_in":259200
        }
        """.data(using: .utf8)!
        return try! JSONDecoder().decode(AccessToken.self, from: data)
    }

    private func breakKeychainWriting() {
        KeychainStore.secItemUpdate = { _, _ in errSecNotAvailable }
        KeychainStore.secItemAdd = { _, _ in errSecNotAvailable }
    }

    private func restoreKeychainFunctions() {
        KeychainStore.secItemUpdate = SecItemUpdate
        KeychainStore.secItemAdd = SecItemAdd
    }

    private func tokenInKeychain() -> AccessToken? {
        let store = AccessTokenStore.shared
        return try? store.keychainStore.token(for: store.configuration, version: store.storeVersion)
    }

    private func waitUntil(
        timeout: TimeInterval = 3,
        _ condition: () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let start = Date()
        while !condition() && Date().timeIntervalSince(start) < timeout {
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        XCTAssertTrue(condition(), file: file, line: line)
    }

    func testSetCurrentTokenStoresToKeychain() {
        let token = makeToken(value: "token1")
        AccessTokenStore.shared.setCurrentToken(token)

        XCTAssertEqual(AccessTokenStore.shared.current, token)
        XCTAssertEqual(tokenInKeychain(), token)
        XCTAssertFalse(AccessTokenStore.shared.isTokenPersistencePending)
    }

    func testKeychainFailureKeepsTokenInMemory() {
        let token = makeToken(value: "token1")

        expectation(forNotification: .LineSDKAccessTokenDidUpdate, object: nil) { notification in
            let newToken = notification.userInfo?[LineSDKNotificationKey.newAccessToken] as? AccessToken
            return newToken == token
        }

        breakKeychainWriting()
        AccessTokenStore.shared.setCurrentToken(token)

        XCTAssertEqual(AccessTokenStore.shared.current, token)
        XCTAssertNil(tokenInKeychain())
        XCTAssertTrue(AccessTokenStore.shared.isTokenPersistencePending)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testPendingTokenIsStoredOnRetry() {
        let token = makeToken(value: "token1")

        breakKeychainWriting()
        AccessTokenStore.shared.setCurrentToken(token)
        XCTAssertTrue(AccessTokenStore.shared.isTokenPersistencePending)

        // Keychain is still broken. Retry keeps the pending state.
        AccessTokenStore.shared.retryPendingTokenPersistence()
        XCTAssertTrue(AccessTokenStore.shared.isTokenPersistencePending)
        XCTAssertNil(tokenInKeychain())

        restoreKeychainFunctions()
        AccessTokenStore.shared.retryPendingTokenPersistence()
        XCTAssertFalse(AccessTokenStore.shared.isTokenPersistencePending)
        XCTAssertEqual(tokenInKeychain(), token)
    }

    func testPendingTokenIsStoredWhenAppBecomesActive() {
        let token = makeToken(value: "token1")

        breakKeychainWriting()
        AccessTokenStore.shared.setCurrentToken(token)
        XCTAssertTrue(AccessTokenStore.shared.isTokenPersistencePending)

        restoreKeychainFunctions()
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        waitUntil { !AccessTokenStore.shared.isTokenPersistencePending }
        XCTAssertEqual(tokenInKeychain(), token)
    }

    func testPendingTokenIsStoredWhenProtectedDataBecomesAvailable() {
        let token = makeToken(value: "token1")

        breakKeychainWriting()
        AccessTokenStore.shared.setCurrentToken(token)
        XCTAssertTrue(AccessTokenStore.shared.isTokenPersistencePending)

        restoreKeychainFunctions()
        NotificationCenter.default.post(
            name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil
        )

        waitUntil { !AccessTokenStore.shared.isTokenPersistencePending }
        XCTAssertEqual(tokenInKeychain(), token)
    }

    func testNewTokenOverridesPendingState() {
        let token1 = makeToken(value: "token1")
        let token2 = makeToken(value: "token2")

        breakKeychainWriting()
        AccessTokenStore.shared.setCurrentToken(token1)
        XCTAssertTrue(AccessTokenStore.shared.isTokenPersistencePending)

        restoreKeychainFunctions()
        AccessTokenStore.shared.setCurrentToken(token2)
        XCTAssertFalse(AccessTokenStore.shared.isTokenPersistencePending)
        XCTAssertEqual(AccessTokenStore.shared.current, token2)
        XCTAssertEqual(tokenInKeychain(), token2)
    }

    func testRemoveTokenClearsPendingState() {
        let token = makeToken(value: "token1")

        breakKeychainWriting()
        AccessTokenStore.shared.setCurrentToken(token)
        XCTAssertTrue(AccessTokenStore.shared.isTokenPersistencePending)

        restoreKeychainFunctions()
        try! AccessTokenStore.shared.removeCurrentAccessToken()

        XCTAssertNil(AccessTokenStore.shared.current)
        XCTAssertFalse(AccessTokenStore.shared.isTokenPersistencePending)

        // A lifecycle event must not resurrect the removed token.
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        RunLoop.current.run(until: Date().addingTimeInterval(0.2))
        XCTAssertNil(tokenInKeychain())
    }

    func testRemovePendingTokenPostsDidRemoveNotification() {
        let token = makeToken(value: "token1")

        breakKeychainWriting()
        AccessTokenStore.shared.setCurrentToken(token)
        XCTAssertNil(tokenInKeychain())

        expectation(forNotification: .LineSDKAccessTokenDidRemove, object: nil, handler: nil)

        restoreKeychainFunctions()
        try! AccessTokenStore.shared.removeCurrentAccessToken()
        XCTAssertNil(AccessTokenStore.shared.current)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testRefreshFlowSucceedsWhenKeychainIsUnavailable() {
        let expect = expectation(description: "\(#file)_\(#line)")

        let delegate = SessionDelegateStub(stub: .init(string: PostRefreshTokenRequest.success, responseCode: 200))
        Session._shared = Session(configuration: LoginConfiguration.shared, delegate: delegate)

        let oldToken = makeToken(value: "old")
        AccessTokenStore.shared.setCurrentToken(oldToken)
        XCTAssertEqual(tokenInKeychain(), oldToken)

        breakKeychainWriting()

        let pipeline = RefreshTokenRedirector()
        let request = StubRequestSimple()
        let response = HTTPURLResponse.responseFromCode(401)

        try! pipeline.redirect(request: request, data: Data(), response: response) { action in
            switch action {
            case .restartWithout:
                MainActor.assumeIsolated {
                    // The refresh succeeds with the new token in memory, even though it cannot be persisted.
                    XCTAssertEqual(
                        AccessTokenStore.shared.current?.value, PostRefreshTokenRequest.successToken
                    )
                    XCTAssertTrue(AccessTokenStore.shared.isTokenPersistencePending)
                    // The keychain still holds the old token.
                    XCTAssertEqual(self.tokenInKeychain(), oldToken)
                }
            default:
                XCTFail("The request should be restarted even if the keychain writing fails.")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
