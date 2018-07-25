//
//  Request.swift
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

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    
    var adapter: AnyRequestAdapter {
        return .init { request in
            var request = request
            request.httpMethod = self.rawValue
            return request
        }
    }
}

enum AuthenticateMethod {
    case none
    case token
    
    var adapter: TokenAdapter? {
        switch self {
        case .none:
            return nil
        case .token:
            return TokenAdapter(token: AccessTokenStore.shared.current)
        }
    }
}

enum ContentType {
    case none
    case formUrlEncoded
    case json
    
    var headerValue: String {
        switch self {
        case .none: return ""
        case .formUrlEncoded: return "application/x-www-form-urlencoded; charset=utf-8"
        case .json: return "application/json"
        }
    }
    
    var adapter: AnyRequestAdapter? {
        if self == .none {
            return nil
        }
        
        return .init { request in
            var request = request
            request.setValue(self.headerValue, forHTTPHeaderField: "Content-Type")
            return request
        }
    }
}

typealias Parameters = [String: Any]

protocol Request {
    associatedtype Response: Decodable
    
    var method: HTTPMethod { get }
    
    var path: String { get }
    
    var parameters: Parameters? { get }
    
    var authenticate: AuthenticateMethod { get }
    
    var contentType: ContentType { get }
    
    var additionalAdapters: [RequestAdapter]? { get }
    
    var additionalPipelines: [ResponsePipeline]? { get }
    
    var responseParser: JSONDecoder? { get }
}

extension Request {
    var adapters: [RequestAdapter] {
        
        // Default header, UA etc
        var adapters: [RequestAdapter] = [HeaderAdapter.default, method.adapter]
        
        // Parameter adapters
        if let parameters = parameters {
            switch (method, contentType) {
            case (.get, _):
                adapters.append(URLQueryEncoder(parameters: parameters))
            case (_, .formUrlEncoded):
                adapters.append(FormUrlEncodedParameterEncoder(parameters: parameters))
            case (_, .json):
                adapters.append(JSONParameterEncoder(parameters: parameters))
            case (_, .none):
                Log.fatalError("You must specifiy a contentType to use POST request.")
            }
        }
        
        // Content type adapter
        contentType.adapter.map { adapters.append($0) }
        
        // Token adapter
        authenticate.adapter.map { adapters.append($0) }
        
        // Other adapters
        if let additionalAdapters = additionalAdapters {
            adapters.append(contentsOf: additionalAdapters)
        }
        
        return adapters
    }
    
    var pipelines: [ResponsePipeline] {
        let pipelines: [ResponsePipeline] = [
            .redirector(RefreshTokenRedirector.default),
            .terminator(ParsePipeline.default)
        ]
        return pipelines
    }
    
    var additionalPipelines: [ResponsePipeline]? { return nil }
    var additionalAdapters: [RequestAdapter]? { return nil }
    var responseParser: JSONDecoder? { return nil }
    var contentType: ContentType { return .json }
}

protocol APIRequest: Request {
    
}

