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

/// HTTP methods specified in a `Request` object.
///
/// - get: The GET method.
/// - post: The POST method.
/// - put: The PUT method.
/// - delete: The DELETE method.
public enum HTTPMethod: String {
    /// The GET method.
    case get = "GET"
    /// The POST method.
    case post = "POST"
    /// The PUT method.
    case put = "PUT"
    /// The DELETE method.
    case delete = "DELETE"
    
    var adapter: AnyRequestAdapter {
        return .init { request in
            var request = request
            request.httpMethod = self.rawValue
            return request
        }
    }
}

/// Authentication methods specified in a `Request` object.
///
/// - none: Does not use any authentication method.
/// - token: Uses an OAuth 2.0 Bearer token.
public enum AuthenticateMethod {
    /// Does not use any authentication method.
    case none
    /// Uses an OAuth 2.0 Bearer token.
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

/// Content types specified in a `Request` object.
///
/// - none: The request does not contain any body content.
/// - formUrlEncoded: The request contains form URL encoded data.
/// - json: The request contains JSON data.
public enum ContentType {
    /// The request does not contain any body content.
    case none
    /// The request contains form URL encoded data.
    case formUrlEncoded
    /// The request contains JSON data.
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

/// Parameter types for `Request` objects.
public typealias Parameters = [String: Any]

/// Represents a request to the LINE Platform. A request is composed of various components such as `method`,
/// `path`, `parameters` and so on. By conforming to the `Request` protocol, you can implement your own
/// request type for any API requests for the LINE Platform. To get a response, build a `Request` object and
/// then send it with a `Session` object.
public protocol Request {
    
    /// Represents a response type of the request. `Response` objects are decodable from raw data from an
    /// HTTP response.
    associatedtype Response: Decodable
    
    /// The `HTTPMethod` enumeration member used for the request.
    var method: HTTPMethod { get }
    
    /// The base URL of the current request.
    var baseURL: URL { get }
    
    /// The API entry path for the request.
    var path: String { get }

    /// The query items which should be appended to the path. Only applies to POST requests.
    /// For GET request, use `parameters` to specify the path queries.
    var pathQueries: [URLQueryItem]? { get }
    
    /// Parameters to be encoded and sent. The default value is `nil`.
    var parameters: Parameters? { get }
    
    /// The `AuthenticateMethod` enumeration member used for the request.
    var authentication: AuthenticateMethod { get }
    
    /// The `ContentType` enumeration member used for the HTTP body data of the request. The default value is
    /// `.json`.
    var contentType: ContentType { get }
    
    /// The request adapters for synthesizing the request. Use the `RequestAdapter` protocol to set up
    /// adapters. The items in `adapters` will be applied to and modify the underlying `URLRequest` object.
    /// By default, the LINE SDK will adapt the request by setting its header and body according to the
    /// properties of the request.
    ///
    /// You can provide your own `adapters` to change the request properties. However, it's more likely that
    /// you want to provide adapters with `suffixAdapters` instead, to modify the request according to
    /// the default result provided by the LINE SDK. The resulting adapters would be
    /// `adapters + (suffixAdapters ?? [])`.
    var adapters: [RequestAdapter] { get }
    
    /// Additional adapters to be appended to `adapters`. The default value is `nil`.
    var suffixAdapters: [RequestAdapter]? { get }
    
    /// The pipelines to intercept or parse the response. Use `ResponsePipeline` enumeration members to set up
    /// pipelines. The items in `pipelines` will be applied to the underlying `URLResponse` object and the
    /// received `Data` object. By default, the LINE SDK provides pipelines for handling token refreshes
    /// and bad HTTP status codes. The last pipeline will attempt to decode the data to a `Response` object.
    ///
    /// You can provide your own `pipelines` to change the response handling process. However, it's more
    /// likely that you want to provide pipelines with `prefixPipelines` instead, to handle a response
    /// before the LINE SDK applies the default behavior. The resulting pipelines would be
    /// `(prefixPipelines ?? []) + pipelines`.
    var pipelines: [ResponsePipeline] { get }
    
    /// Additional pipelines to be added before `pipelines`. The default value is `nil`.
    var prefixPipelines: [ResponsePipeline]? { get }
    
    /// The final data parser that parses the response data into a `Response` object at the end of
    /// `pipelines`. By default, a `JSONParsePipeline` object with the standard `JSONDecoder` object will be
    /// used.
    var dataParser: ResponsePipelineTerminator { get }
    
    /// The timeout in seconds for the current request before receiving a response. The default value is
    /// 30 seconds.
    var timeout: TimeInterval { get }
    
    /// The cache policy of the request. The default value is `.reloadIgnoringLocalCacheData` for general
    /// API requests.
    var cachePolicy: NSURLRequest.CachePolicy { get }
}

public extension Request {
    
    var baseURL: URL {
        return URL(string: "https://\(Constant.APIHost)")!
    }
    
    var cachePolicy: NSURLRequest.CachePolicy { return .reloadIgnoringLocalCacheData }
    
    var adapters: [RequestAdapter] {
        
        // Default header, UA etc
        var adapters: [RequestAdapter] = [
            HeaderAdapter.default,
            method.adapter
        ]
        
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

    var pathQueries: [URLQueryItem]? { return nil }
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
