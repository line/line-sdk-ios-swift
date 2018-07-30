//
//  SessionTests.swift
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

enum ErrorStub: Error {
    case testError
}

struct SimpleStubRequest: Request {
    
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authenticate: AuthenticateMethod = .none
}

class SessionTests: XCTestCase {
    
    let configuration = LoginConfiguration(channelID: "1", universalLinkURL: nil)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSessionPlainError() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let session = Session.stub(configuration: configuration, error: ErrorStub.testError)
        session.send(SimpleStubRequest()) { result in
            guard let e = result.error as? LineSDKError,
                  case .responseFailed(reason: .URLSessionError(ErrorStub.testError)) = e
            else {
                XCTFail("Request should fail with .testError")
                return
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSessionPlainResponse() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let session = Session.stub(configuration: configuration, string: "{\"foo\": \"bar\"}")
        session.send(SimpleStubRequest()) { result in
            XCTAssertNotNil(result.value)
            XCTAssertEqual(result.value!.foo, "bar")
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
}

