//
//  ChainedPaginatedRequestsTests.swift
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

class ChainedPaginatedRequestsTests: XCTestCase {

    private var request: ChainedPaginatedRequest<PaginatedRequest>!
    let config = LoginConfiguration(channelID: "1", universalLinkURL: nil)

    override func setUp() {
        super.setUp()
        let r = PaginatedRequest()
        request = ChainedPaginatedRequest(originalRequest: r)
    }

    override func tearDown() {
        request = nil
        super.tearDown()
    }

    func testChainedRequestSuccessOneRequest() {
        let delegate = SessionDelegateStub(stubItems: [
            paginatedResponseStub(values: "[1,2,3]")
        ])
        let session = Session(configuration: config, delegate: delegate)
        session.send(request) { result in
            XCTAssertEqual(result.value, [1,2,3])
        }
    }

    func testChainedRequestSuccessMultipleRequests() {
        let delegate = SessionDelegateStub(stubItems: [
            paginatedResponseStub(values: "[1,2,3]", token: "hello") {
                XCTAssertFalse($0.containsPageToken("hello"))
            },
            paginatedResponseStub(values: "[4,5,6]") {
                XCTAssertTrue($0.containsPageToken("hello"))
            }
        ])
        let session = Session(configuration: config, delegate: delegate)
        session.send(request) { result in
            XCTAssertEqual(result.value, [1,2,3,4,5,6])
        }
    }

    func testChainedRequestFailsAtBeginning() {
        let delegate = SessionDelegateStub(stubItems: [
            paginatedResponseStub(values: "[1,2,3]", code: 500)
            ])
        let session = Session(configuration: config, delegate: delegate)
        session.send(request) { result in
            XCTAssertNotNil(result.error)
            XCTAssertTrue(result.error!.isResponseError(statusCode: 500))
        }
    }

    func testChainedRequestFailsDuringRequest() {
        let delegate = SessionDelegateStub(stubItems: [
            paginatedResponseStub(values: "[1,2,3]", token: "hello"),
            paginatedResponseStub(values: "[4,5,6]", code: 500)
            ])
        let session = Session(configuration: config, delegate: delegate)
        session.send(request) { result in
            XCTAssertNotNil(result.error)
            XCTAssertTrue(result.error!.isResponseError(statusCode: 500))
        }
    }

    func testChainedRequestCallsPageLoadedOnEachParsing() {
        let delegate = SessionDelegateStub(stubItems: [
            paginatedResponseStub(values: "[1,2,3]", token: "hello") {
                XCTAssertFalse($0.containsPageToken("hello"))
            },
            paginatedResponseStub(values: "[4,5,6]") {
                XCTAssertTrue($0.containsPageToken("hello"))
            }
        ])
        let session = Session(configuration: config, delegate: delegate)
        var count = 0
        var values: [[Int]] = []
        request.onPageLoaded.delegate(on: self) { (self, response) in
            count += 1
            values.append(response.values)
        }
        session.send(request) { result in
            XCTAssertEqual(result.value, [1,2,3,4,5,6])
            XCTAssertEqual(count, 2)
            XCTAssertEqual(values, [[1,2,3], [4,5,6]])
        }
    }
}

extension SessionTask {
    func containsPageToken(_ value: String) -> Bool {
        return self.request.url?.absoluteString.contains("pageToken=\(value)") ?? false
    }
}

private func paginatedResponseStub(values: String, code: Int = 200, verifier: ((SessionTask) throws -> Void)? = nil) -> SessionDelegateStub.StubItem {
    let payload = """
    {
        "values": \(values)
    }
    """
    return paginatedResponseStub(payload: payload, code: code, verifier: verifier)
}

private func paginatedResponseStub(
    values: String,
    token: String,
    code: Int = 200,
    verifier: ((SessionTask) throws -> Void)? = nil) -> SessionDelegateStub.StubItem
{
    let payload = """
    {
        "values": \(values),
        "pageToken": "\(token)"
    }
    """
    return paginatedResponseStub(payload: payload, code: code, verifier: verifier)
}

private func paginatedResponseStub(
    payload: String,
    code: Int = 200,
    verifier: ((SessionTask) throws -> Void)? = nil) -> SessionDelegateStub.StubItem
{
    let requestVerifier: SessionDelegateStub.RequestTaskVerifier
    if let v = verifier {
        requestVerifier = .init(block: v)
    } else {
        requestVerifier = .empty
    }
    return SessionDelegateStub.StubItem(
        action: .init(string: payload, responseCode: code),
        verifier: requestVerifier)
}

private struct PaginatedRequest: Request {

    let method: HTTPMethod = .get
    let path: String = "/"
    let authentication: AuthenticateMethod = .none

    struct Response: Decodable, PaginatedResponse {
        let values: [Int]
        let pageToken: String?

        var paginatedValues: [Int] { return values }
    }
}
