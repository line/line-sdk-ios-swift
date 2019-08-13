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

class SessionTests: XCTestCase {
    
    let configuration = LoginConfiguration(channelID: "1", universalLinkURL: nil)

    func testSessionCreateRequest() {
        let request = StubRequestWithAdapters()
        let session = Session(configuration: configuration)
        let result = try! session.create(request)
        
        XCTAssertEqual(result.url?.absoluteString, "https://\(Constant.APIHost)/api/test")
        XCTAssertEqual(result.httpMethod, "POST")
        XCTAssertEqual(result.value(forHTTPHeaderField: "foo"), "bar")
    }
    
    func testSessionHandleSingleTerminatorPipeline() {
        let request = StubRequestWithSingleTerminatorPipeline()
        let session = Session(configuration: configuration)
        let pipelines = request.pipelines
        try! session.handle(
            request: request,
            data: StubRequestWithSingleTerminatorPipeline.successData,
            response: .responseFromCode(200),
            pipelines: pipelines,
            fullPipelines: pipelines)
        {
            result in
            switch result {
            case .value(let v):
                XCTAssertEqual(v.foo, "bar")
            default:
                XCTFail("Parser should give a correct result")
            }
        }
    }
    
    func testSessionHandleSingleTerminatorPipelineWithInvalidData() {
        let request = StubRequestWithSingleTerminatorPipeline()
        let session = Session(configuration: configuration)
        let pipelines = request.pipelines
        let text = "{\"strange\": \"data\"}"
        do {
            try session.handle(
                request: request,
                data: text.data(using: .utf8)!,
                response: .responseFromCode(200),
                pipelines: pipelines,
                fullPipelines: pipelines)
            {
                result in
                switch result {
                default:
                    XCTFail("Wrong data should throw an error")
                }
            }
        } catch {
            guard let sdkError = error as? LineSDKError,
                case LineSDKError.responseFailed(reason: .dataParsingFailed) = sdkError else
            {
                XCTFail(".dataParsingFailed should be thrown")
                return
            }
        }
    }
    
    func testSessionHandleContinuesRedirector() {
        let request = StubRequestWithContinuesPipeline()
        let session = Session(configuration: configuration)
        let pipelines = request.pipelines
        guard case .redirector(let redirector) = pipelines[0],
              let continuer = redirector as? StubRequestWithContinuesPipeline.ContinuesRedirector else
        {
            XCTFail("The first pipeline should be a ContinuesRedirector")
            return
        }
        
        XCTAssertFalse(continuer.invoked)
        try! session.handle(
            request: request,
            data: StubRequestWithContinuesPipeline.successData,
            response: .responseFromCode(200),
            pipelines: pipelines,
            fullPipelines: pipelines)
        {
            result in
            switch result {
            case .value(let v):
                XCTAssertTrue(continuer.invoked)
                XCTAssertEqual(v.foo, "bar")
            default:
                XCTFail("Parser should give a correct result")
            }
        }
    }
    
    func testSessionHandleContinueRedirectorWithDataResponse() {
        let request = StubRequestWithContinusDataResponsePipeline()
        let session = Session(configuration: configuration)
        let pipelines = request.pipelines
        guard case .redirector(let redirector) = pipelines[0],
            let continuer = redirector as? StubRequestWithContinusDataResponsePipeline.TransformRedirector else
        {
            XCTFail("The first pipeline should be a TransformRedirector")
            return
        }
        
        XCTAssertFalse(continuer.invoked)
        try! session.handle(
            request: request,
            data: StubRequestWithContinusDataResponsePipeline.successData,
            response: .responseFromCode(200),
            pipelines: pipelines,
            fullPipelines: pipelines)
        {
            result in
            switch result {
            case .value(let v):
                XCTAssertTrue(continuer.invoked)
                XCTAssertEqual(v.foo, "barbar")
            default:
                XCTFail("Parser should give a correct result")
            }
        }
    }
    
    func testSessionHandleStopRedirector() {
        let request = StubRequestWithStopPipeline()
        let session = Session(configuration: configuration)
        let pipelines = request.pipelines
        guard case .redirector(let redirector) = pipelines[0],
              let stopper = redirector as? StubRequestWithStopPipeline.StopRedirector else
        {
            XCTFail("The first pipeline should be a StopRedirector")
            return
        }
        XCTAssertFalse(stopper.invoked)
        
        try! session.handle(
            request: request,
            data: StubRequestWithStopPipeline.successData,
            response: .responseFromCode(200),
            pipelines: pipelines,
            fullPipelines: pipelines)
        {
            result in
            switch result {
            case .action(.stop(let error)):
                guard let testError = error as? ErrorStub else {
                    XCTFail("Should throw a test error")
                    return
                }
                XCTAssertEqual(testError, .testError)
                XCTAssertTrue(stopper.invoked)
            default:
                XCTFail("Parser should give a correct restart action")
            }
        }
    }
    
    func testSessionHandleRestartRedirector() {
        let request = StubRequestWithRestartPipeline()
        let session = Session(configuration: configuration)
        let pipelines = request.pipelines
        guard case .redirector(let redirector) = pipelines[0],
              let restarter = redirector as? StubRequestWithRestartPipeline.RestartRedirector else
        {
            XCTFail("The first pipeline should be a RestartRedirector")
            return
        }
        XCTAssertFalse(restarter.invoked)
        try! session.handle(
            request: request,
            data: StubRequestWithStopPipeline.successData,
            response: .responseFromCode(123), // A non-200 code will make `restarter` to work.
            pipelines: pipelines,
            fullPipelines: pipelines)
        {
            result in
            switch result {
            case .action(.restart):
                XCTAssertTrue(restarter.invoked)
            default:
                XCTFail("Parser should give a correct restart action")
            }
        }
    }
    
    func testSessionCouldRestartSendingRequest() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let request = StubRequestWithRestartPipeline()
        let delegate = SessionDelegateStub(stubs: [
            .response(Data(), .responseFromCode(123)),
            .response(StubRequestWithRestartPipeline.successData, .responseFromCode(200)),
        ])
        
        let pipelines = request.pipelines
        guard case .redirector(let redirector) = pipelines[0],
              let restarter = redirector as? StubRequestWithRestartPipeline.RestartRedirector else
        {
            XCTFail("The first pipeline should be a RestartRedirector")
            return
        }
        XCTAssertFalse(restarter.invoked)

        let session = Session(configuration: configuration, delegate: delegate)
        session.send(request) { result in
            expect.fulfill()
            guard let value = result.value else {
                XCTFail("Should parse to final result after restarting for once.")
                return
            }
            XCTAssertTrue(delegate.stubItems.isEmpty)
            XCTAssertEqual(value.foo, "bar")
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSessionHandleRestartAnotherPipelinesRedirector() {
        let request = StubRequestWithRestartAnotherPipeline()
        let session = Session(configuration: configuration)
        let pipelines = request.pipelines
        guard case .redirector(let redirector) = pipelines[0],
              let restarter = redirector as? StubRequestWithRestartAnotherPipeline.RestartAnotherPipeline else
        {
            XCTFail("The first pipeline should be a RestartAnotherPipeline")
            return
        }
        XCTAssertFalse(restarter.invoked)
        try! session.handle(
            request: request,
            data: StubRequestWithStopPipeline.successData,
            response: .responseFromCode(200),
            pipelines: pipelines,
            fullPipelines: pipelines)
        {
            result in
            switch result {
            case .action(.restartWith(let other)):
                XCTAssertTrue(restarter.invoked)
                XCTAssertEqual(other.count, 1)
                XCTAssertEqual(other[0], pipelines[1])
            default:
                XCTFail("Parser should give a correct restart action")
            }
        }
    }
    
    func testSessionCouldRestartSendingRequestWithAnotherPipelines() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let request = StubRequestWithRestartAnotherPipeline()
        let delegate = SessionDelegateStub(stubs: [
            .response(Data(), .responseFromCode(123)),
            .response(StubRequestWithRestartPipeline.successData, .responseFromCode(200)),
            ])
        
        let pipelines = request.pipelines
        guard case .redirector(let redirector) = pipelines[0],
              let restarter = redirector as? StubRequestWithRestartAnotherPipeline.RestartAnotherPipeline else
        {
            XCTFail("The first pipeline should be a RestartAnotherPipeline")
            return
        }
        XCTAssertFalse(restarter.invoked)
        
        let session = Session(configuration: configuration, delegate: delegate)
        session.send(request) { result in
            expect.fulfill()
            guard let value = result.value else {
                XCTFail("Should parse to final result after restarting for once.")
                return
            }
            XCTAssertTrue(delegate.stubItems.isEmpty)
            XCTAssertEqual(value.foo, "bar")
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSessionPlainError() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let session = Session.stub(configuration: configuration, error: ErrorStub.testError)
        session.send(StubRequestSimple()) { result in
            guard case .responseFailed(reason: .URLSessionError(ErrorStub.testError)) = result.error! else {
                XCTFail("Request should fail with .testError")
                return
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSessionPlainResponse() {
        let expect = expectation(description: "\(#file)_\(#line)")
        let session = Session.stub(configuration: configuration, string: StubRequestSimple.success)
        session.send(StubRequestSimple()) { result in
            XCTAssertNotNil(result.value)
            XCTAssertEqual(result.value!.foo, "bar")
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testSessionDelegateLock() {

        // There should be no deadlock when sending requests from concurrent queue.

        let expect = expectation(description: "\(#file)_\(#line)")

        let range = 0 ..< 1000
        let delegate = SessionDelegate()
        let queue = DispatchQueue(label: "test", attributes: .concurrent)

        let group = DispatchGroup()
        for _ in range {
            group.enter()
            queue.async {
                delegate.add(
                    SessionTask(
                        session: URLSession.shared,
                        request: URLRequest(url: URL(string: "https://example.com")!)
                    )
                )
                group.leave()
            }
        }

        group.notify(queue: .main) {
            expect.fulfill()
        }

        waitForExpectations(timeout: 1, handler: nil)
    }
}

