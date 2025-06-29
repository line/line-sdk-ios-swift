//
//  RequestStubs.swift
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

import Foundation
@testable import LineSDK

enum ErrorStub: Error {
    case testError
}

struct StubRequestSimple: Request, ResponseDataStub {
    
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authentication: AuthenticateMethod = .none
    
    static let success = "{\"foo\": \"bar\"}"
}


struct StubRequestWithAdapters: Request {
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .post
    let path: String = "/api/test"
    let authentication: AuthenticateMethod = .none
    
    var adapters: [RequestAdapter] {
        return [
            method.adapter,
            AnyRequestAdapter { r in
                var request = r
                request.addValue("bar", forHTTPHeaderField: "foo")
                return request
            }
        ]
    }
}

struct StubRequestWithSingleTerminatorPipeline: Request, ResponseDataStub {
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authentication: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [.terminator(JSONParsePipeline(JSONDecoder()))]
    }
    
    static let success = "{\"foo\": \"bar\"}"
}

struct StubRequestWithContinuesPipeline: Request, ResponseDataStub {
    
    final class ContinuesRedirector: ResponsePipelineRedirector, @unchecked Sendable {

        private var _invoked = false
        private let lock = NSLock()
        var invoked: Bool {
            get {
                lock.lock()
                defer { lock.unlock() }
                return _invoked
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                _invoked = newValue
            }
        }

        func shouldApply<T>(request: T, data: Data, response: HTTPURLResponse) -> Bool where T : Request {
            return true
        }
        
        func redirect<T>(
            request: T,
            data: Data,
            response: HTTPURLResponse,
            done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws where T : Request
        {
            invoked = true
            try closure(.continue)
        }
    }
    
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authentication: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [
            .redirector(ContinuesRedirector()),
            .terminator(JSONParsePipeline(JSONDecoder()))
        ]
    }
    
    static let success = "{\"foo\": \"bar\"}"
}

struct StubRequestWithContinusDataResponsePipeline: Request, ResponseDataStub {
    
    final class TransformRedirector: ResponsePipelineRedirector, @unchecked Sendable {

        private var _invoked = false
        private let lock = NSLock()
        var invoked: Bool {
            get {
                lock.lock()
                defer { lock.unlock() }
                return _invoked
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                _invoked = newValue
            }
        }

        func shouldApply<T>(request: T, data: Data, response: HTTPURLResponse) -> Bool where T : Request {
            return true
        }
        
        func redirect<T>(
            request: T,
            data: Data,
            response: HTTPURLResponse,
            done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws where T : Request
        {
            invoked = true
            let data = "{\"foo\": \"barbar\"}".data(using: .utf8)!
            let resultResponse = HTTPURLResponse(
                url: response.url!,
                statusCode: 999,
                httpVersion: nil,
                headerFields: nil)!
            
            try closure(.continueWith(data, resultResponse))
        }
    }
    
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authentication: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [
            .redirector(TransformRedirector()),
            .terminator(JSONParsePipeline(JSONDecoder()))
        ]
    }
    
    static let success = "{\"foo\": \"bar\"}"
}

struct StubRequestWithStopPipeline: Request, ResponseDataStub {
    final class StopRedirector: ResponsePipelineRedirector, @unchecked Sendable {

        private var _invoked = false
        private let lock = NSLock()
        var invoked: Bool {
            get {
                lock.lock()
                defer { lock.unlock() }
                return _invoked
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                _invoked = newValue
            }
        }

        func shouldApply<T>(request: T, data: Data, response: HTTPURLResponse) -> Bool where T : Request {
            return true
        }
        
        func redirect<T>(
            request: T,
            data: Data,
            response: HTTPURLResponse,
            done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws where T : Request
        {
            invoked = true
            try closure(.stop(ErrorStub.testError))
        }
    }
    
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authentication: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [
            .redirector(StopRedirector()),
            .terminator(JSONParsePipeline(JSONDecoder()))
        ]
    }
    
    static let success = "{\"foo\": \"bar\"}"
}

struct StubRequestWithRestartPipeline: Request, ResponseDataStub {
    final class RestartRedirector: ResponsePipelineRedirector, @unchecked Sendable {

        let valid: Int
        
        init(valid: Int) {
            self.valid = valid
        }
        
        private var _invoked = false
        private let lock = NSLock()
        var invoked: Bool {
            get {
                lock.lock()
                defer { lock.unlock() }
                return _invoked
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                _invoked = newValue
            }
        }

        func shouldApply<T>(request: T, data: Data, response: HTTPURLResponse) -> Bool where T : Request {
            return response.statusCode != valid
        }
        
        func redirect<T>(
            request: T,
            data: Data,
            response: HTTPURLResponse,
            done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws where T : Request
        {
            invoked = true
            try closure(.restart)
        }
    }
    
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authentication: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [
            .redirector(RestartRedirector(valid: 200)),
            .terminator(JSONParsePipeline(JSONDecoder()))
        ]
    }
    
    static let success = "{\"foo\": \"bar\"}"
}

struct StubRequestWithRestartAnotherPipeline: Request, ResponseDataStub {
    final class RestartAnotherPipeline: ResponsePipelineRedirector, @unchecked Sendable {

        private var _invoked = false
        private let lock = NSLock()
        var invoked: Bool {
            get {
                lock.lock()
                defer { lock.unlock() }
                return _invoked
            }
            set {
                lock.lock()
                defer { lock.unlock() }
                _invoked = newValue
            }
        }

        func shouldApply<T>(request: T, data: Data, response: HTTPURLResponse) -> Bool where T : Request {
            return true
        }
        
        func redirect<T>(
            request: T,
            data: Data,
            response: HTTPURLResponse,
            done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws where T : Request
        {
            invoked = true
            try closure(.restartWithout(.redirector(self)))
        }
    }
    
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authentication: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [
            .redirector(RestartAnotherPipeline()),
            .terminator(JSONParsePipeline(JSONDecoder()))
        ]
    }
    
    static let success = "{\"foo\": \"bar\"}"
}
