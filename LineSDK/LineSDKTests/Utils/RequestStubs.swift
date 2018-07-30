//
//  RequestStubs.swift
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

enum ErrorStub: Error {
    case testError
}

struct StubRequestSimple: Request {
    
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authenticate: AuthenticateMethod = .none
    
    static let success = "{\"foo\": \"bar\"}"
    static var successData: Data {
        return success.data(using: .utf8)!
    }
}


struct StubRequestWithAdapters: Request {
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .post
    let path: String = "/api/test"
    let authenticate: AuthenticateMethod = .none
    
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

struct StubRequestWithSingleTerminatorPipeline: Request {
    struct Response: Decodable {
        let foo: String
    }
    
    let method: HTTPMethod = .get
    let path: String = ""
    let authenticate: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [.terminator(ParsePipeline(JSONDecoder()))]
    }
    
    static let success = "{\"foo\": \"bar\"}"
    static var successData: Data {
        return success.data(using: .utf8)!
    }
}

struct StubRequestWithContinusPipeline: Request {
    
    class ContinuesRedirector: ResponsePipelineRedirector {
        
        var invoked = false
        
        func shouldApply<T>(reqeust: T, data: Data, response: HTTPURLResponse) -> Bool where T : Request {
            return true
        }
        
        func redirect<T>(
            reqeust: T,
            data: Data,
            response: HTTPURLResponse,
            done closure: (ResponsePipelineRedirectorAction) throws -> Void) throws where T : Request
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
    let authenticate: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [
            .redirector(ContinuesRedirector()),
            .terminator(ParsePipeline(JSONDecoder()))
        ]
    }
    
    static let success = "{\"foo\": \"bar\"}"
    static var successData: Data {
        return success.data(using: .utf8)!
    }
}

struct StubRequestWithStopPipeline: Request {
    class StopRedirector: ResponsePipelineRedirector {
        
        var invoked = false
        
        func shouldApply<T>(reqeust: T, data: Data, response: HTTPURLResponse) -> Bool where T : Request {
            return true
        }
        
        func redirect<T>(
            reqeust: T,
            data: Data,
            response: HTTPURLResponse,
            done closure: (ResponsePipelineRedirectorAction) throws -> Void) throws where T : Request
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
    let authenticate: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [
            .redirector(StopRedirector()),
            .terminator(ParsePipeline(JSONDecoder()))
        ]
    }
    
    static let success = "{\"foo\": \"bar\"}"
    static var successData: Data {
        return success.data(using: .utf8)!
    }
}

struct StubRequestWithRestartPipeline: Request {
    class RestartRedirector: ResponsePipelineRedirector {
        
        let valid: Int
        
        init(valid: Int) {
            self.valid = valid
        }
        
        var invoked = false
        
        func shouldApply<T>(reqeust: T, data: Data, response: HTTPURLResponse) -> Bool where T : Request {
            return response.statusCode != valid
        }
        
        func redirect<T>(
            reqeust: T,
            data: Data,
            response: HTTPURLResponse,
            done closure: (ResponsePipelineRedirectorAction) throws -> Void) throws where T : Request
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
    let authenticate: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [
            .redirector(RestartRedirector(valid: 200)),
            .terminator(ParsePipeline(JSONDecoder()))
        ]
    }
    
    static let success = "{\"foo\": \"bar\"}"
    static var successData: Data {
        return success.data(using: .utf8)!
    }
}

struct StubRequestWithRestartAnotherPipeline: Request {
    class RestartAnotherPipeline: ResponsePipelineRedirector {
        
        var invoked = false
        
        func shouldApply<T>(reqeust: T, data: Data, response: HTTPURLResponse) -> Bool where T : Request {
            return true
        }
        
        func redirect<T>(
            reqeust: T,
            data: Data,
            response: HTTPURLResponse,
            done closure: (ResponsePipelineRedirectorAction) throws -> Void) throws where T : Request
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
    let authenticate: AuthenticateMethod = .none
    
    var pipelines: [ResponsePipeline] {
        return [
            .redirector(RestartAnotherPipeline()),
            .terminator(ParsePipeline(JSONDecoder()))
        ]
    }
    
    static let success = "{\"foo\": \"bar\"}"
    static var successData: Data {
        return success.data(using: .utf8)!
    }
}
