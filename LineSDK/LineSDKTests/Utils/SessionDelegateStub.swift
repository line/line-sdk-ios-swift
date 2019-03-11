//
//  SessionDelegateStub.swift
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
@testable import LineSDK

extension HTTPURLResponse {
    static func responseFromCode(_ code: Int, urlString: String = "linesdktest://sampleurl") -> HTTPURLResponse {
        return HTTPURLResponse(
            url: URL(string: urlString)!,
            statusCode: code,
            httpVersion: "HTTP/1.1",
            headerFields: [:])!
    }
}

class SessionDelegateStub: NSObject, SessionDelegateType {

    struct StubItem {
        let action: Either
        let verifier: RequestTaskVerifier
    }

    struct RequestTaskVerifier {
        let block: (SessionTask) throws -> Void
        func verify(sessionTask: SessionTask) throws {
            try block(sessionTask)
        }

        static let empty = RequestTaskVerifier { _ in }
    }

    enum Either {
        case response(Data, HTTPURLResponse)
        case error(Error)
        
        init(data: Data, response: HTTPURLResponse) {
            self = .response(data, response)
        }
        
        init(data: Data, responseCode code: Int = 200) {
            let response = HTTPURLResponse.responseFromCode(code)
            self.init(data: data, response: response)
        }
        
        init(string: String, response: HTTPURLResponse) {
            let data = string.data(using: .utf8)!
            self.init(data: data, response: response)
        }
        
        init(string: String, responseCode: Int = 200) {
            let data = string.data(using: .utf8)!
            self.init(data: data, responseCode: responseCode)
        }
    }
    
    var stubItems: [StubItem]
    
    convenience init(stub: Either) {
        self.init(stubs: [stub])
    }
    
    convenience init(stubs: [Either]) {
        self.init(stubItems: stubs.map { StubItem(action: $0, verifier: .empty) })
    }

    init(stubItems: [StubItem]) {
        self.stubItems = stubItems
    }
    
    func shouldTaskStart(_ task: SessionTask) -> Bool {
        guard !stubItems.isEmpty else {
            fatalError("Stubs are not enough. Make sure you have enough response stubs prepared for task: \(task)")
        }
        
        let stub = stubItems.removeFirst()

        do {
            try stub.verifier.verify(sessionTask: task)
        } catch {
            fatalError("Stub request verifying failed without handling for task: \(task)")
        }

        switch stub.action {
        case .response(let data, let response):
            task.onResult.call((data, response, nil))
        case .error(let error):
            task.onResult.call((nil, nil, error))
        }
        
        return false
    }
    
    func add(_ task: SessionTask) { }
    func remove(_ task: URLSessionTask) { }
    func task(for task: URLSessionTask) -> SessionTask? { return nil }
}

extension Session {
    static func stub(configuration: LoginConfiguration, string: String, statusCode: Int = 200) -> Session {
        let stub = SessionDelegateStub(stub: .init(string: string, responseCode: statusCode))
        return Session(configuration: configuration, delegate: stub)
    }
    
    static func stub(configuration: LoginConfiguration, error: Error) -> Session {
        let stub = SessionDelegateStub(stub: .error(error))
        return Session(configuration: configuration, delegate: stub)
    }
}


