//
//  ResponsePipeline.swift
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

protocol ResponsePipelineTerminator {
    func parse<T: Request>(request: T, data: Data) throws -> T.Response
}

enum ResponsePipelineRedirectorAction {
    case restart
    case stop(Error?)
    case `continue`
}

protocol ResponsePipelineRedirector {
    func shouldApply<T: Request>(reqeust: T, data: Data, response: HTTPURLResponse) -> Bool
    func redirect(done closure: (ResponsePipelineRedirectorAction) throws -> Void)
}

enum ResponsePipeline {
    case terminator(ResponsePipelineTerminator)
    case redirector(ResponsePipelineRedirector)
}

struct ParsePipeline: ResponsePipelineTerminator {
    static let `default` = ParsePipeline()
    
    let parser: JSONDecoder
    
    private init() {
        parser = JSONDecoder()
    }
    
    func parse<T: Request>(request: T, data: Data) throws -> T.Response {
        let parser = request.responseParser ?? self.parser
        return try parser.decode(T.Response.self, from: data)
    }
}

struct RefreshTokenRedirector: ResponsePipelineRedirector {
    
    static let `default` = RefreshTokenRedirector()
    
    func shouldApply<T: Request>(reqeust: T, data: Data, response: HTTPURLResponse) -> Bool {
        return false
    }
    
    func redirect(done closure: (ResponsePipelineRedirectorAction) throws -> Void) {
        
    }
}
