//
//  LoginManagerTests.swift
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

let sampleFlowParameters = LoginProcess.FlowParameters(
        channelID: "",
        universalLinkURL: nil,
        scopes: [],
        pkce: .init(),
        processID: "",
        nonce: nil,
        loginParameter: .init()
)

@MainActor
class LoginManagerTests: XCTestCase, ViewControllerCompatibleTest {
    
    var window: UIWindow!
    
    override func setUp() {
        let url = URL(string: "https://example.com/auth")
        LoginManager.shared.setup(channelID: "123", universalLinkURL: url)
    }
    
    override func tearDown() async throws {
        LoginManager.shared.reset()
        resetViewController()
    }
    
    func testSetupLoginManager() {
        XCTAssertNotNil(Session.shared)
        XCTAssertNotNil(AccessTokenStore.shared)
        XCTAssertNotNil(LoginConfiguration.shared)
        
        XCTAssertTrue(LoginManager.shared.isSetupFinished)
    }
    
    func testLoginAction() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        XCTAssertFalse(LoginManager.shared.isAuthorized)
        XCTAssertFalse(LoginManager.shared.isAuthorizing)
        
        let delegateStub = SessionDelegateStub(stubs: [
            .init(data: PostExchangeTokenRequest.successData, responseCode: 200),
            .init(data: GetUserProfileRequest.successData, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )

        var process: LoginProcess!
        process = LoginManager.shared.login(permissions: [.profile], in: setupViewController()) {
            loginResult in
            XCTAssertNotNil(loginResult.value)
            
            let result = loginResult.value!
            XCTAssertEqual(result.accessToken.value, PostExchangeTokenRequest.successToken)
            XCTAssertEqual(AccessTokenStore.shared.current, result.accessToken)
            
            XCTAssertTrue(LoginManager.shared.isAuthorized)
            XCTAssertFalse(LoginManager.shared.isAuthorizing)

            // IDTokenNonce should be `nil` when `.openID` not required.
            XCTAssertNil(result.IDTokenNonce)

            XCTAssertEqual(process.loginRoute, .appUniversalLink)

            try! AccessTokenStore.shared.removeCurrentAccessToken()
            expect.fulfill()
        }!

        // Set a sample value for checking `loginRoute` in the result.
        process.appUniversalLinkFlow = AppUniversalLinkFlow(parameter: sampleFlowParameters)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            
            XCTAssertFalse(LoginManager.shared.isAuthorized)
            XCTAssertTrue(LoginManager.shared.isAuthorizing)

            // Simulate auth result
            let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=\(process.processID)"
            let handled = process.resumeOpenURL(url: URL(string: urlString)!)
            XCTAssertTrue(handled)
        }
        
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testLoginActionWithOpenID() {
        let expect = expectation(description: "\(#file)_\(#line)")

        XCTAssertFalse(LoginManager.shared.isAuthorized)
        XCTAssertFalse(LoginManager.shared.isAuthorizing)

        let delegateStub = SessionDelegateStub(stubs: [
            .init(data: PostExchangeTokenRequest.successData, responseCode: 200),
            .init(data: GetUserProfileRequest.successData, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )

        var process: LoginProcess!
        process = LoginManager.shared.login(permissions: [.profile, .openID], in: setupViewController()) {
            loginResult in
            XCTAssertNotNil(loginResult.value)

            let result = loginResult.value!

            // IDTokenNonce should be `nil` when `.openID` not required.
            XCTAssertNotNil(result.IDTokenNonce)
            XCTAssertEqual(result.IDTokenNonce, process!.IDTokenNonce)

            try! AccessTokenStore.shared.removeCurrentAccessToken()
            expect.fulfill()
        }!

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

            XCTAssertFalse(LoginManager.shared.isAuthorized)
            XCTAssertTrue(LoginManager.shared.isAuthorizing)

            let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=\(process.processID)"
            let handled = process.resumeOpenURL(url: URL(string: urlString)!)
            XCTAssertTrue(handled)
        }

        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testLogout() {
        let expect = expectation(description: "\(#file)_\(#line)")

        setupTestToken()
        XCTAssertTrue(LoginManager.shared.isAuthorized)
        
        Session._shared = Session.stub(configuration: LoginConfiguration.shared, string: "")
        LoginManager.shared.logout { result in
            XCTAssertFalse(LoginManager.shared.isAuthorized)
            XCTAssertNotNil(result.value)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testRefreshNotOverwriteStoredIDToken() {

        let expect = expectation(description: "\(#file)_\(#line)")

        setupTestToken()
        XCTAssertTrue(LoginManager.shared.isAuthorized)
        XCTAssertNotNil(AccessTokenStore.shared.current?.IDToken)

        let delegateStub = SessionDelegateStub(
            stubs: [.init(data: PostRefreshTokenRequest.successData, responseCode: 200)])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )

        API.Auth.refreshAccessToken { result in
            XCTAssertNotNil(AccessTokenStore.shared.current?.IDToken)
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }

    func testLoginProcessRouteSetting() {
        XCTContext.runActivity(named: "app universal link") { _ in
            let process = LoginProcess(
                configuration: .shared, scopes: [], parameters: .init(), viewController: setupViewController()
            )
            XCTAssertNil(process.loginRoute)
            process.appUniversalLinkFlow = AppUniversalLinkFlow(parameter: sampleFlowParameters)
            XCTAssertEqual(process.loginRoute, .appUniversalLink)
        }

        XCTContext.runActivity(named: "app auth") { _ in
            let process = LoginProcess(
                configuration: .shared, scopes: [], parameters: .init(), viewController: setupViewController()
            )
            XCTAssertNil(process.loginRoute)
            process.appAuthSchemeFlow = AppAuthSchemeFlow(parameter: sampleFlowParameters)
            XCTAssertEqual(process.loginRoute, .appAuthScheme)
        }

        XCTContext.runActivity(named: "web login") { _ in
            let process = LoginProcess(
                configuration: .shared, scopes: [], parameters: .init(), viewController: setupViewController()
            )
            XCTAssertNil(process.loginRoute)
            process.webLoginFlow = WebLoginFlow(parameter: sampleFlowParameters)
            XCTAssertEqual(process.loginRoute, .webLogin)
        }
    }
    
    // MARK: - Token Exchange Error Tests
    
    func testExchangeTokenWithNonNetworkError() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        // Use a simple NSError that's not a network connection lost error
        let customError = NSError(domain: "TestDomain", code: 999, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        let delegateStub = SessionDelegateStub(stub: .error(customError))
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )
        
        var process: LoginProcess!
        process = LoginManager.shared.login(permissions: [.profile], in: setupViewController()) {
            loginResult in
            XCTAssertNotNil(loginResult.error)
            XCTAssertNil(loginResult.value)
            
            if let error = loginResult.error {
                // Should receive the error wrapped in URLSessionError but not be a network connection lost error
                XCTAssertFalse(error.isURLSessionErrorCode(sessionErrorCode: NSURLErrorNetworkConnectionLost))
            } else {
                XCTFail("Should receive LineSDKError, but got: \(String(describing: loginResult.error))")
            }
            
            expect.fulfill()
        }!
        
        process.appUniversalLinkFlow = AppUniversalLinkFlow(parameter: sampleFlowParameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=\(process.processID)"
            let handled = process.resumeOpenURL(url: URL(string: urlString)!)
            XCTAssertTrue(handled)
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testExchangeTokenWithNetworkErrorRetrySuccess() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost, userInfo: nil)
        
        // For retry scenario: 
        // 1. First PostExchangeTokenRequest -> network error
        // 2. Second PostExchangeTokenRequest (retry) -> success
        // 3. GetUserProfileRequest -> success
        let delegateStub = SessionDelegateStub(stubs: [
            .error(networkError),
            .init(data: PostExchangeTokenRequest.successData, responseCode: 200),
            .init(data: GetUserProfileRequest.successData, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )
        
        var process: LoginProcess!
        process = LoginManager.shared.login(permissions: [.profile], in: setupViewController()) {
            loginResult in
            if let error = loginResult.error {
                XCTFail("Should succeed after retry, but got error: \(error)")
            } else if let result = loginResult.value {
                XCTAssertEqual(result.accessToken.value, PostExchangeTokenRequest.successToken)
                try! AccessTokenStore.shared.removeCurrentAccessToken()
            } else {
                XCTFail("No result received")
            }
            expect.fulfill()
        }!
        
        process.appUniversalLinkFlow = AppUniversalLinkFlow(parameter: sampleFlowParameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=\(process.processID)"
            let handled = process.resumeOpenURL(url: URL(string: urlString)!)
            XCTAssertTrue(handled)
        }
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testExchangeTokenWithNetworkErrorRetryFail() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost, userInfo: nil)
        
        let delegateStub = SessionDelegateStub(stubs: [
            .error(networkError),
            .error(networkError)
        ])
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: delegateStub
        )
        
        var process: LoginProcess!
        process = LoginManager.shared.login(permissions: [.profile], in: setupViewController()) {
            loginResult in
            XCTAssertNotNil(loginResult.error)
            XCTAssertNil(loginResult.value)
            
            if let error = loginResult.error {
                XCTAssertTrue(error.isURLSessionErrorCode(sessionErrorCode: NSURLErrorNetworkConnectionLost))
            } else {
                XCTFail("Should receive network connection lost error")
            }
            
            expect.fulfill()
        }!
        
        process.appUniversalLinkFlow = AppUniversalLinkFlow(parameter: sampleFlowParameters)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let urlString = "\(Constant.thirdPartyAppReturnURL)?code=123&state=\(process.processID)"
            let handled = process.resumeOpenURL(url: URL(string: urlString)!)
            XCTAssertTrue(handled)
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    // MARK: - ID Token Tests
    
    func testGetProviderMetadataSuccess() async {
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: PostExchangeTokenRequest.successData)
        
        // Create JWK from test RSA public key that matches the test JWT token
        let testRSAPublicKeyPEM = """
        -----BEGIN PUBLIC KEY-----
        MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdlatRjRjogo3WojgGHFHYLugd
        UWAY9iR3fy4arWNA1KoS8kVw33cJibXr8bvwUAUparCwlvdbH6dvEOfou0/gCFQs
        HUfQrSDv+MuSUMAe8jzKE4qW+jK+xQU9a03GUnKHkkle+Q0pX/g6jXZ7r1/xAK5D
        o2kQ+X5xK9cipRgEKwIDAQAB
        -----END PUBLIC KEY-----
        """
        
        // Create JWK set with the test RSA key having keyID "12345"
        let customJWKSetJSON = """
        {"keys":[{"kty":"RSA","alg":"RS256","use":"sig","kid":"12345","n":"3ZWrUY0Y6IKN1qI4BhxR2C7oHVFgGPYkd38uGq1jQNSqEvJFcN93CYm16_G78FAFKWqwsJb3Wx-nbxDn6LtP4AhULB1H0K0g7_jLklDAHvI8yhOKlvoyvsUFPWtNxlJyh5JJXvkNKV_4Oo12e69f8QCuQ6NpEPl-cSvXIqUYBCs","e":"AQAB"}]}
        """
        let customJWKSetData = customJWKSetJSON.data(using: .utf8)!
        
        let discoveryDocumentStub = SessionDelegateStub(stubs: [
            .init(data: GetDiscoveryDocumentRequest.successData, responseCode: 200),
            .init(data: customJWKSetData, responseCode: 200)
        ])
        
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: discoveryDocumentStub
        )
        
        do {
            let metadata = try await LoginManager.shared.getProviderMetadata(for: mockAccessToken)
            XCTAssertEqual(metadata.issuer, "https://access.line.me")
            XCTAssertNotNil(metadata.jwk)
        } catch {
            XCTFail("getProviderMetadata should succeed, but got error: \(error)")
        }
    }
    
    func testGetProviderMetadataFailureWithoutIDToken() async {
        var mockTokenData = try! JSONSerialization.jsonObject(with: PostExchangeTokenRequest.successData) as! [String: Any]
        mockTokenData.removeValue(forKey: "id_token")
        let tokenDataWithoutIDToken = try! JSONSerialization.data(withJSONObject: mockTokenData)
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: tokenDataWithoutIDToken)
        
        do {
            _ = try await LoginManager.shared.getProviderMetadata(for: mockAccessToken)
            XCTFail("getProviderMetadata should fail without ID token")
        } catch let error as LineSDKError {
            if case .authorizeFailed(let reason) = error {
                if case .lackOfIDToken = reason {
                    // Expected error
                } else {
                    XCTFail("Expected lackOfIDToken error, got: \(reason)")
                }
            } else {
                XCTFail("Expected authorizeFailed error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testGetProviderMetadataFailureWithUnsupportedAlgorithm() async {
        // Create a valid JWT token with unsupported algorithm HS256
        let mockIDTokenWithUnsupportedAlg = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjEyMzQ1In0.eyJpc3MiOiJodHRwczovL2FjY2Vzcy5saW5lLm1lIiwic3ViIjoiVTEyMzQ1Njc4OTBhYmNkZWYxMjM0NTY3ODkwYWJjZGVmIiwiYXVkIjoiMTIzNDUiLCJleHAiOjE1MzU5NTk4NzAsImlhdCI6MTUzNTk1OTc3MCwibm9uY2UiOiJBQkNBQkMiLCJuYW1lIjoib25ldmNhdCIsInBpY3R1cmUiOiJodHRwczovL29icy1iZXRhLmxpbmUtYXBwcy5jb20veHh4eCIsImVtYWlsIjoiYWJjQGRlZi5jb20ifQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        
        var mockTokenData = try! JSONSerialization.jsonObject(with: PostExchangeTokenRequest.successData) as! [String: Any]
        mockTokenData["id_token"] = mockIDTokenWithUnsupportedAlg
        let tokenDataWithUnsupportedAlg = try! JSONSerialization.data(withJSONObject: mockTokenData)
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: tokenDataWithUnsupportedAlg)
        
        do {
            _ = try await LoginManager.shared.getProviderMetadata(for: mockAccessToken)
            XCTFail("getProviderMetadata should fail with unsupported algorithm")
        } catch let error as LineSDKError {
            if case .authorizeFailed(let reason) = error {
                if case .cryptoError(let cryptoError) = reason {
                    if case .JWTFailed(let jwtReason) = cryptoError {
                        if case .unsupportedHeaderAlgorithm = jwtReason {
                            // Expected error
                        } else {
                            XCTFail("Expected unsupportedHeaderAlgorithm error, got: \(jwtReason)")
                        }
                    } else {
                        XCTFail("Expected JWTFailed crypto error, got: \(cryptoError)")
                    }
                } else {
                    XCTFail("Expected cryptoError reason, got: \(reason)")
                }
            } else {
                XCTFail("Expected authorizeFailed error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testGetProviderMetadataFailureWithMissingKeyID() async {
        // Create JWT token without kid (key ID) but with valid signature structure 
        let mockIDTokenWithoutKid = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FjY2Vzcy5saW5lLm1lIiwic3ViIjoiVTEyMzQ1Njc4OTBhYmNkZWYxMjM0NTY3ODkwYWJjZGVmIiwiYXVkIjoiMTIzNDUiLCJleHAiOjE1MzU5NTk4NzAsImlhdCI6MTUzNTk1OTc3MCwibm9uY2UiOiJBQkNBQkMiLCJuYW1lIjoib25ldmNhdCIsInBpY3R1cmUiOiJodHRwczovL29icy1iZXRhLmxpbmUtYXBwcy5jb20veHh4eCIsImVtYWlsIjoiYWJjQGRlZi5jb20ifQ.z8XL3SKiQvuooPVGvWtsd515SxnhgKWoqC6yBY-9LYQNPiKO71mK_ETiPh418aBz5WtayidlZY5AlhMBkCw2ky3nHiVxirE9kXo58yiUqfGaVDQMtrtW-TS-JZqgaeR8v_Mh04W2qK4mjMc5txIfdfImiajguzFh6ZZ0OHUFsdo"
        
        var mockTokenData = try! JSONSerialization.jsonObject(with: PostExchangeTokenRequest.successData) as! [String: Any]
        mockTokenData["id_token"] = mockIDTokenWithoutKid
        let tokenDataWithoutKid = try! JSONSerialization.data(withJSONObject: mockTokenData)
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: tokenDataWithoutKid)
        
        let discoveryDocumentStub = SessionDelegateStub(stubs: [
            .init(data: GetDiscoveryDocumentRequest.successData, responseCode: 200),
            .init(data: GetJWKSetRequest.successData, responseCode: 200)
        ])
        
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: discoveryDocumentStub
        )
        
        do {
            _ = try await LoginManager.shared.getProviderMetadata(for: mockAccessToken)
            XCTFail("getProviderMetadata should fail with missing key ID")
        } catch let error as LineSDKError {
            if case .authorizeFailed(let reason) = error {
                if case .JWTPublicKeyNotFound = reason {
                    // Expected error
                } else {
                    XCTFail("Expected JWTPublicKeyNotFound error, got: \(reason)")
                }
            } else {
                XCTFail("Expected authorizeFailed error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testGetProviderMetadataFailureWithNetworkError() async {
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: PostExchangeTokenRequest.successData)
        
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost, userInfo: nil)
        let networkErrorStub = SessionDelegateStub(stubs: [
            .error(networkError)
        ])
        
        Session._shared = Session(
            configuration: LoginConfiguration.shared,
            delegate: networkErrorStub
        )
        
        do {
            _ = try await LoginManager.shared.getProviderMetadata(for: mockAccessToken)
            XCTFail("getProviderMetadata should fail with network error")
        } catch let error as LineSDKError {
            if case .responseFailed(let reason) = error {
                if case .URLSessionError = reason {
                    // Expected error
                } else {
                    XCTFail("Expected URLSessionError, got: \(reason)")
                }
            } else {
                XCTFail("Expected responseFailed error, got: \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func testVerifyIDTokenSuccess() {
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: PostExchangeTokenRequest.successData)
        let mockIDToken = mockAccessToken.IDToken!
        
        // Create JWK from test RSA public key that matches the test JWT token
        let customJWKJSON = """
        {"kty":"RSA","alg":"RS256","use":"sig","kid":"12345","n":"3ZWrUY0Y6IKN1qI4BhxR2C7oHVFgGPYkd38uGq1jQNSqEvJFcN93CYm16_G78FAFKWqwsJb3Wx-nbxDn6LtP4AhULB1H0K0g7_jLklDAHvI8yhOKlvoyvsUFPWtNxlJyh5JJXvkNKV_4Oo12e69f8QCuQ6NpEPl-cSvXIqUYBCs","e":"AQAB"}
        """
        let customJWKData = customJWKJSON.data(using: .utf8)!
        let mockJWK = try! JSONDecoder().decode(JWK.self, from: customJWKData)
        
        let mockProviderMetadata = DiscoveryDocument.ResolvedProviderMetadata(
            issuer: "https://access.line.me",
            jwk: mockJWK
        )
        
        // Create mock process with correct channelID that matches JWT audience
        var parameters = LoginManager.Parameters()
        parameters.IDTokenNonce = "ABCABC"
        let correctConfig = LoginConfiguration(channelID: "12345", universalLinkURL: nil) // Match JWT audience
        let mockProcess = LoginProcess(
            configuration: correctConfig,
            scopes: [.openID],
            parameters: parameters,
            viewController: nil
        )
        
        // Use a date from 2018 when the test JWT token was valid
        // exp: 1535959870 (2018-09-03 14:31:10 UTC)
        // iat: 1535959770 (2018-09-03 14:29:30 UTC)
        // Using: 1535959800 (2018-09-03 14:30:00 UTC) - within valid time range
        let testDate = Date(timeIntervalSince1970: 1535959800)
        
        XCTAssertNoThrow(
            try LoginManager.shared.verifyIDToken(
                mockIDToken,
                providerMetadata: mockProviderMetadata,
                process: mockProcess,
                userID: "U1234567890abcdef1234567890abcdef",
                currentDate: testDate
            )
        )
    }
    
    func testVerifyIDTokenFailureWithExpiredToken() {
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: PostExchangeTokenRequest.successData)
        let mockIDToken = mockAccessToken.IDToken!
        
        // Create JWK from test RSA public key that matches the test JWT token
        let customJWKJSON = """
        {"kty":"RSA","alg":"RS256","use":"sig","kid":"12345","n":"3ZWrUY0Y6IKN1qI4BhxR2C7oHVFgGPYkd38uGq1jQNSqEvJFcN93CYm16_G78FAFKWqwsJb3Wx-nbxDn6LtP4AhULB1H0K0g7_jLklDAHvI8yhOKlvoyvsUFPWtNxlJyh5JJXvkNKV_4Oo12e69f8QCuQ6NpEPl-cSvXIqUYBCs","e":"AQAB"}
        """
        let customJWKData = customJWKJSON.data(using: .utf8)!
        let mockJWK = try! JSONDecoder().decode(JWK.self, from: customJWKData)
        
        let mockProviderMetadata = DiscoveryDocument.ResolvedProviderMetadata(
            issuer: "https://access.line.me",
            jwk: mockJWK
        )
        
        // Create mock process with correct channelID that matches JWT audience
        var parameters = LoginManager.Parameters()
        parameters.IDTokenNonce = "ABCABC"
        let correctConfig = LoginConfiguration(channelID: "12345", universalLinkURL: nil) // Match JWT audience
        let mockProcess = LoginProcess(
            configuration: correctConfig,
            scopes: [.openID],
            parameters: parameters,
            viewController: nil
        )
        
        // Use a date from the future (after token expiration)
        // JWT token exp: 1535959870 (2018-09-03 14:31:10 UTC)
        // Using: 1735959870 (2024-01-03 14:31:10 UTC) - token is expired
        let futureDate = Date(timeIntervalSince1970: 1735959870)
        
        XCTAssertThrowsError(
            try LoginManager.shared.verifyIDToken(
                mockIDToken,
                providerMetadata: mockProviderMetadata,
                process: mockProcess,
                userID: "U1234567890abcdef1234567890abcdef",
                currentDate: futureDate
            )
        ) { error in
            if let cryptoError = error as? CryptoError {
                if case .JWTFailed(let reason) = cryptoError {
                    if case .claimVerifyingFailed(let key, _, _) = reason {
                        XCTAssertEqual(key, "\\Payload.expiration") // The actual key format includes the payload prefix
                    } else {
                        XCTFail("Expected claimVerifyingFailed error for expiration, got: \(reason)")
                    }
                } else {
                    XCTFail("Expected JWTFailed crypto error, got: \(cryptoError)")
                }
            } else {
                XCTFail("Expected CryptoError, got: \(error)")
            }
        }
    }
    
    func testVerifyIDTokenFailureWithTokenUsedTooEarly() {
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: PostExchangeTokenRequest.successData)
        let mockIDToken = mockAccessToken.IDToken!
        
        // Create JWK from test RSA public key that matches the test JWT token
        let customJWKJSON = """
        {"kty":"RSA","alg":"RS256","use":"sig","kid":"12345","n":"3ZWrUY0Y6IKN1qI4BhxR2C7oHVFgGPYkd38uGq1jQNSqEvJFcN93CYm16_G78FAFKWqwsJb3Wx-nbxDn6LtP4AhULB1H0K0g7_jLklDAHvI8yhOKlvoyvsUFPWtNxlJyh5JJXvkNKV_4Oo12e69f8QCuQ6NpEPl-cSvXIqUYBCs","e":"AQAB"}
        """
        let customJWKData = customJWKJSON.data(using: .utf8)!
        let mockJWK = try! JSONDecoder().decode(JWK.self, from: customJWKData)
        
        let mockProviderMetadata = DiscoveryDocument.ResolvedProviderMetadata(
            issuer: "https://access.line.me",
            jwk: mockJWK
        )
        
        // Create mock process with correct channelID that matches JWT audience
        var parameters = LoginManager.Parameters()
        parameters.IDTokenNonce = "ABCABC"
        let correctConfig = LoginConfiguration(channelID: "12345", universalLinkURL: nil) // Match JWT audience
        let mockProcess = LoginProcess(
            configuration: correctConfig,
            scopes: [.openID],
            parameters: parameters,
            viewController: nil
        )
        
        // Use a date from the past (before token was issued)
        // JWT token iat: 1535959770 (2018-09-03 14:29:30 UTC)
        // Using: 1535959000 (2018-09-03 14:16:40 UTC) - token not yet valid (issued in future)
        let pastDate = Date(timeIntervalSince1970: 1535959000)
        
        XCTAssertThrowsError(
            try LoginManager.shared.verifyIDToken(
                mockIDToken,
                providerMetadata: mockProviderMetadata,
                process: mockProcess,
                userID: "U1234567890abcdef1234567890abcdef",
                currentDate: pastDate
            )
        ) { error in
            if let cryptoError = error as? CryptoError {
                if case .JWTFailed(let reason) = cryptoError {
                    if case .claimVerifyingFailed(let key, _, _) = reason {
                        XCTAssertEqual(key, "\\Payload.issueAt") // The actual key format includes the payload prefix
                    } else {
                        XCTFail("Expected claimVerifyingFailed error for issueAt, got: \(reason)")
                    }
                } else {
                    XCTFail("Expected JWTFailed crypto error, got: \(cryptoError)")
                }
            } else {
                XCTFail("Expected CryptoError, got: \(error)")
            }
        }
    }
    
    func testVerifyIDTokenFailureWithInvalidIssuer() {
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: PostExchangeTokenRequest.successData)
        let mockIDToken = mockAccessToken.IDToken!
        
        // Create JWK from test RSA public key that matches the test JWT token
        let customJWKJSON = """
        {"kty":"RSA","alg":"RS256","use":"sig","kid":"12345","n":"3ZWrUY0Y6IKN1qI4BhxR2C7oHVFgGPYkd38uGq1jQNSqEvJFcN93CYm16_G78FAFKWqwsJb3Wx-nbxDn6LtP4AhULB1H0K0g7_jLklDAHvI8yhOKlvoyvsUFPWtNxlJyh5JJXvkNKV_4Oo12e69f8QCuQ6NpEPl-cSvXIqUYBCs","e":"AQAB"}
        """
        let customJWKData = customJWKJSON.data(using: .utf8)!
        let mockJWK = try! JSONDecoder().decode(JWK.self, from: customJWKData)
        
        let mockProviderMetadata = DiscoveryDocument.ResolvedProviderMetadata(
            issuer: "https://wrong.issuer.com", // Wrong issuer
            jwk: mockJWK
        )
        
        // Create mock process with correct channelID that matches JWT audience
        var parameters = LoginManager.Parameters()
        parameters.IDTokenNonce = "ABCABC"
        let correctConfig = LoginConfiguration(channelID: "12345", universalLinkURL: nil) // Match JWT audience
        let mockProcess = LoginProcess(
            configuration: correctConfig,
            scopes: [.openID],
            parameters: parameters,
            viewController: nil
        )
        
        XCTAssertThrowsError(
            try LoginManager.shared.verifyIDToken(
                mockIDToken,
                providerMetadata: mockProviderMetadata,
                process: mockProcess,
                userID: "U1234567890abcdef1234567890abcdef",
                currentDate: Date()
            )
        ) { error in
            if let cryptoError = error as? CryptoError {
                if case .JWTFailed(let reason) = cryptoError {
                    if case .claimVerifyingFailed(let key, _, _) = reason {
                        XCTAssertEqual(key, "\\Payload.issuer") // The actual key format includes the payload prefix
                    } else {
                        XCTFail("Expected claimVerifyingFailed error for issuer, got: \(reason)")
                    }
                } else {
                    XCTFail("Expected JWTFailed crypto error, got: \(cryptoError)")
                }
            } else {
                XCTFail("Expected CryptoError, got: \(error)")
            }
        }
    }
    
    func testVerifyIDTokenFailureWithWrongUserID() {
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: PostExchangeTokenRequest.successData)
        let mockIDToken = mockAccessToken.IDToken!
        
        // Create JWK from test RSA public key that matches the test JWT token
        let customJWKJSON = """
        {"kty":"RSA","alg":"RS256","use":"sig","kid":"12345","n":"3ZWrUY0Y6IKN1qI4BhxR2C7oHVFgGPYkd38uGq1jQNSqEvJFcN93CYm16_G78FAFKWqwsJb3Wx-nbxDn6LtP4AhULB1H0K0g7_jLklDAHvI8yhOKlvoyvsUFPWtNxlJyh5JJXvkNKV_4Oo12e69f8QCuQ6NpEPl-cSvXIqUYBCs","e":"AQAB"}
        """
        let customJWKData = customJWKJSON.data(using: .utf8)!
        let mockJWK = try! JSONDecoder().decode(JWK.self, from: customJWKData)
        
        let mockProviderMetadata = DiscoveryDocument.ResolvedProviderMetadata(
            issuer: "https://access.line.me",
            jwk: mockJWK
        )
        
        // Create mock process with correct channelID that matches JWT audience
        var parameters = LoginManager.Parameters()
        parameters.IDTokenNonce = "ABCABC"
        let correctConfig = LoginConfiguration(channelID: "12345", universalLinkURL: nil) // Match JWT audience
        let mockProcess = LoginProcess(
            configuration: correctConfig,
            scopes: [.openID],
            parameters: parameters,
            viewController: nil
        )
        
        XCTAssertThrowsError(
            try LoginManager.shared.verifyIDToken(
                mockIDToken,
                providerMetadata: mockProviderMetadata,
                process: mockProcess,
                userID: "WrongUserID", // Wrong user ID
                currentDate: Date()
            )
        ) { error in
            if let cryptoError = error as? CryptoError {
                if case .JWTFailed(let reason) = cryptoError {
                    if case .claimVerifyingFailed(let key, _, _) = reason {
                        XCTAssertEqual(key, "\\Payload.subject") // The actual key format includes the payload prefix
                    } else {
                        XCTFail("Expected claimVerifyingFailed error for subject, got: \(reason)")
                    }
                } else {
                    XCTFail("Expected JWTFailed crypto error, got: \(cryptoError)")
                }
            } else {
                XCTFail("Expected CryptoError, got: \(error)")
            }
        }
    }
    
    func testVerifyIDTokenFailureWithWrongAudience() {
        let mockAccessToken = try! JSONDecoder().decode(AccessToken.self, from: PostExchangeTokenRequest.successData)
        let mockIDToken = mockAccessToken.IDToken!
        
        // Create JWK from test RSA public key that matches the test JWT token
        let customJWKJSON = """
        {"kty":"RSA","alg":"RS256","use":"sig","kid":"12345","n":"3ZWrUY0Y6IKN1qI4BhxR2C7oHVFgGPYkd38uGq1jQNSqEvJFcN93CYm16_G78FAFKWqwsJb3Wx-nbxDn6LtP4AhULB1H0K0g7_jLklDAHvI8yhOKlvoyvsUFPWtNxlJyh5JJXvkNKV_4Oo12e69f8QCuQ6NpEPl-cSvXIqUYBCs","e":"AQAB"}
        """
        let customJWKData = customJWKJSON.data(using: .utf8)!
        let mockJWK = try! JSONDecoder().decode(JWK.self, from: customJWKData)
        
        let mockProviderMetadata = DiscoveryDocument.ResolvedProviderMetadata(
            issuer: "https://access.line.me",
            jwk: mockJWK
        )
        
        // Use wrong configuration with different channel ID
        let wrongConfig = LoginConfiguration(channelID: "WrongChannelID", universalLinkURL: nil)
        let mockProcess = LoginProcess(
            configuration: wrongConfig,
            scopes: [.openID],
            parameters: { var p = LoginManager.Parameters(); p.IDTokenNonce = "ABCABC"; return p }(),
            viewController: nil
        )
        
        XCTAssertThrowsError(
            try LoginManager.shared.verifyIDToken(
                mockIDToken,
                providerMetadata: mockProviderMetadata,
                process: mockProcess,
                userID: "U1234567890abcdef1234567890abcdef",
                currentDate: Date()
            )
        ) { error in
            if let cryptoError = error as? CryptoError {
                if case .JWTFailed(let reason) = cryptoError {
                    if case .claimVerifyingFailed(let key, _, _) = reason {
                        XCTAssertEqual(key, "\\Payload.audience") // The actual key format includes the payload prefix
                    } else {
                        XCTFail("Expected claimVerifyingFailed error for audience, got: \(reason)")
                    }
                } else {
                    XCTFail("Expected JWTFailed crypto error, got: \(cryptoError)")
                }
            } else {
                XCTFail("Expected CryptoError, got: \(error)")
            }
        }
    }

}

