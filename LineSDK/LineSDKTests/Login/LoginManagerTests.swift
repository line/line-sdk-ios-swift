//
//  LoginManagerTests.swift
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

class LoginManagerTests: XCTestCase, ViewControllerCompatibleTest {
    
    var window: UIWindow!
    
    override func setUp() {
        super.setUp()
        let url = URL(string: "https://sample.com/auth")
        LoginManager.shared.setup(channelID: "123", universalLinkURL: url)
    }
    
    override func tearDown() {
        super.tearDown()
        LoginManager.shared.reset()
        resetViewController()
    }
    
    func testSetupLoginManager() {
        XCTAssertNotNil(Session.shared)
        XCTAssertNotNil(AccessTokenStore.shared)
        XCTAssertNotNil(LoginManager.shared.configuration)
    }
    
    class LoginActionDelegate: NSObject, LoginManagerDelegate {
        
        let expect: XCTestExpectation
        
        init(expect: XCTestExpectation) {
            self.expect = expect
            super.init()
        }
        
        func loginManager(
            _ manager: LoginManager,
            didSucceed loginProcess: LoginProcess,
            withResult result: LoginResult)
        {
            XCTAssertEqual(result.accessToken.value, PostTokenExchangeRequest.successToken)
            expect.fulfill()
        }
        
        func loginManager(
            _ manager: LoginManager,
            didFail loginProcess: LoginProcess,
            withError error: Error)
        {
            XCTFail("The login process should not fail.")
        }
    }
    
    var loginActionDelegate: LoginActionDelegate!
    func testLoginAction() {
        let expect = expectation(description: "\(#file)_\(#line)")
        
        loginActionDelegate = LoginActionDelegate(expect: expect)
        LoginManager.shared.delegate = loginActionDelegate
        
        let delegateStub = SessionDelegateStub(stubs: [
            .init(data: PostOTPRequest.successData, responseCode: 200),
            .init(data: PostTokenExchangeRequest.successData, responseCode: 200),
            .init(data: GetUserProfileRequest.successData, responseCode: 200)
        ])
        Session._shared = Session(
            configuration: LoginManager.shared.configuration!,
            delegate: delegateStub
        )
        
        let process = LoginManager.shared.login(permissions: [.profile], in: setupViewController())!
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let urlString = "\(Constant.thirdPartyAppRetrurnURL)?code=123&state=\(process.processID)"
            let handled = process.resumeOpenURL(url: URL(string: urlString)!, sourceApplication: "com.apple.safari")
            XCTAssertTrue(handled)
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}

