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

/// Represents an HTTP method specified with a `Request` instance.
///
/// - get: The GET method.
/// - post: The POST method.
/// - put: The PUT method.
/// - delete: The DELETE method.
public enum HTTPMethod: String {
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

/// Represents an authentication method specified with a `Request` instance.
///
/// - none: Does not use any authentication method.
/// - token: Uses OAuth 2.0 Bearer token.
public enum AuthenticateMethod {
    case none
    case token
    
    var adapter: TokenAdapter? {
        switch self {
        case .none:
            return nil
        case .token:
            return TokenAdapter(token: AccessTokenStore.shared.current?.value)
        }
    }
    
    var refreshTokenPipeline: ResponsePipeline? {
        switch self {
        case .none:
            return nil
        case .token:
            let tokenRefresher = RefreshTokenRedirector()
            return .redirector(tokenRefresher)
        }
    }
}

/// Represents a content type specified with a `Request` instance.
///
/// - none: The request does not contain any body content.
/// - formUrlEncoded: The request contains form url encoded data.
/// - json: The request contains JSON data.
public enum ContentType {
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

/// Type for `Request` parameters.
public typealias Parameters = [String: Any]

/// Represents a request to LINE APIs. A request is composed by `method`, `path`, `parameters` and some other
/// necessary components. By conforming to `Request`, you could implement your own request type for arbitrary LINE API.
/// You could build a `Request` instance and then send it by `Session` to get a response.
public protocol Request {
    
    /// Response type of this request. The `Response` should conforms to `Decodable` and be able to be decoded from
    /// raw data from an HTTP response.
    associatedtype Response: Decodable
    
    /// `HTTPMethod` used for this request.
    var method: HTTPMethod { get }
    
    /// The base URL of current request.
    var baseURL: URL { get }
    
    /// API entry path for this request.
    var path: String { get }
    
    /// Parameters be encoded and sent. Default is `nil`.
    var parameters: Parameters? { get }
    
    /// `AuthenticateMethod` should be used for this request.
    var authentication: AuthenticateMethod { get }
    
    /// `ContentType` of HTTP body data for this request. Default is `.json`.
    var contentType: ContentType { get }
    
    /// The `RequestAdapter`s should be used to synthesize the request. The items in `adapters` will be applied to the
    /// underlying `URLRequest` to modify it. By default, LineSDK will adapt the request by setting its header and
    /// body according to properties of this request.
    ///
    /// You could provide your own `adapters` to completely change the request properties. However, it's more likely
    /// you might want to provide some adapters by `suffixAdapters` instead, to modify the request based on LineSDK
    /// default result. The final adapters are `adapters + (suffixAdapters ?? [])`.
    var adapters: [RequestAdapter] { get }
    
    /// Additional adapters which will be appended to `adapters`. Default is `nil`.
    var suffixAdapters: [RequestAdapter]? { get }
    
    /// The `ResponsePipeline`s should be used to intercept or parse the response. The items in `pipelines` will be
    /// applied to the underlying `URLResponse` and received `Data`. By default, LineSDK provides pipelines to handle
    /// token refreshing and bad HTTP status code. At last, it will try to decode the data to an instance of `Response`.
    ///
    /// You could provide your own `pipelines` to completely change response handling process. However, it's more likely
    /// you might want to provide some pipelines by `prefixPipelines` instead, to handle the response before LineSDK
    /// apply its default behaviors. The final pipelines are `(prefixPipelines ?? []) + pipelines`.
    var pipelines: [ResponsePipeline] { get }
    
    /// Additional pipelines which will be prefixed to `pipelines`. Default is `nil`.
    var prefixPipelines: [ResponsePipeline]? { get }
    
    /// The final data parser used in the end of `pipeline`. It should parse the response data into a `Response` object.
    /// By default, a `JSONParsePipeline` with a standard `JSONDecoder` will be used.
    var dataParser: ResponsePipelineTerminator { get }
    
    /// Timeout interval by second of current request before receiving a response. Default is 30 seconds.
    var timeout: TimeInterval { get }
    
    /// Cache policy of this request. Default is .reloadIgnoringLocalCacheData for general API request.
    var cachePolicy: NSURLRequest.CachePolicy { get }
}

public extension Request {
    
    var baseURL: URL {
        return URL(string: "https://\(Constant.APIHost)")!
    }
    
    var cachePolicy: NSURLRequest.CachePolicy { return .reloadIgnoringLocalCacheData }
    
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
                Log.fatalError("You must specify a contentType to use POST request.")
            }
        }
        
        // Content type adapter
        contentType.adapter.map { adapters.append($0) }
        
        // Token adapter
        authentication.adapter.map { adapters.append($0) }
        
        return adapters
    }
    
    var pipelines: [ResponsePipeline] {
        var pipelines: [ResponsePipeline] = []
        
        // Token refresh pipeline
        authentication.refreshTokenPipeline.map { pipelines.append($0) }
        
        pipelines.append(contentsOf: [
            .redirector(BadHTTPStatusRedirector(valid: 200..<300)),
            .terminator(dataParser)
        ])
        return pipelines
    }
    
    var suffixAdapters: [RequestAdapter]? { return nil }
    var prefixPipelines: [ResponsePipeline]? { return nil }
    var dataParser: ResponsePipelineTerminator {
        get { return JSONParsePipeline(defaultJSONParser) }
    }
    var contentType: ContentType { return .json }
    var parameters: Parameters? { return nil }
    var timeout: TimeInterval { return 30 }
}

let defaultJSONParser = JSONDecoder()
