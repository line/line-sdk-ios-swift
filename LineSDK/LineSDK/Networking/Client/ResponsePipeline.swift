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


/// Represents the final stage of response pipelines. It will be used to parse response data to
/// a final `Response` object of a certain `Request`.
public protocol ResponsePipelineTerminator: class { // Use class protocol for easier Equatable conforming
    /// Parse input `data` to a `Response`.
    ///
    /// - Parameters:
    ///   - request: Original `request` object.
    ///   - data: Received `Data` from `Session`.
    /// - Returns: The parsed `Response` object.
    /// - Throws: An error happens during the parsing process.
    func parse<T: Request>(request: T, data: Data) throws -> T.Response
}

/// Represents a redirection might be required to the response pipelines. It would be a chance
/// to take side effect on current response and data, then perform additional handling by
/// invoking `closure` with a proper `ResponsePipelineRedirectorAction`.
public protocol ResponsePipelineRedirector: class { // Use class protocol for easier Equatable conforming
    func shouldApply<T: Request>(request: T, data: Data, response: HTTPURLResponse) -> Bool
    func redirect<T: Request>(request: T, data: Data, response: HTTPURLResponse, done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws
}

/// Actions for `ResponsePipelineRedirector` result. A redirector needs to decide where to redirect
/// current handling after it applied its side effect. This enum provides possible destination and
/// behavior for a redirector.
///
/// - restart: The current request needs to be restarted with original pipelines.
/// - restartWithout: The current request needs to be restarted, but excluding a certain pipeline.
/// - stop: The handling process should be stopped due to an error.
/// - `continue`: The handling process should continue.
/// - continueWith: The handling process should continue with modified data and response.
public enum ResponsePipelineRedirectorAction {

    /// The current request needs to be restarted with original pipelines.
    case restart

    /// The current request needs to be restarted, but excluding a certain pipeline.
    case restartWithout(ResponsePipeline)

    /// The handling process should be stopped due to an error.
    case stop(Error)

    /// The handling process should continue.
    case `continue`

    /// The handling process should continue with modified data and response.
    case continueWith(Data, HTTPURLResponse)
}

/// Represents pipeline for response. A pipeline will take the response and its data from `Session`.
/// At the end of a pipeline, there should be always a `terminator` pipeline to convert data to a
/// `Response` object. In the middle of the pipelines, there could be multiple `redirector`s to
/// perform some side effects.
///
/// - terminator: Associates with a `ResponsePipelineTerminator`, to terminate the pipeline.
/// - redirector: Associates with a `ResponsePipelineRedirector`, to redirect current handling process.
public enum ResponsePipeline {

    /// Associates with a `ResponsePipelineTerminator`, to terminate the pipeline.
    case terminator(ResponsePipelineTerminator)

    /// Associates with a `ResponsePipelineRedirector`, to redirect current handling process.
    case redirector(ResponsePipelineRedirector)
}

extension ResponsePipeline: Equatable {
    public static func == (lhs: ResponsePipeline, rhs: ResponsePipeline) -> Bool {
        switch (lhs, rhs) {
        case (.terminator(let l), .terminator(let r)): return l === r
        case (.redirector(let l), .redirector(let r)): return l === r
        default: return false
        }
    }
}

/// Represents a terminator pipeline with a JSON decoder to parse data.
public class JSONParsePipeline: ResponsePipelineTerminator {
    
    /// An underlying JSON parser of this pipeline.
    public let parser: JSONDecoder
    
    /// Initializes a `JSONParsePipeline` object.
    ///
    /// - Parameter parser: The JSON parser for input data.
    public init(_ parser: JSONDecoder) {
        self.parser = parser
    }
    
    /// Parses `data` that holds input values to a `Response` object.
    ///
    /// - Parameters:
    ///   - request: The original request.
    ///   - data: The `Data` object that was received from the `Session` object.
    /// - Returns: The `Response` object.
    /// - Throws: An error that happens during the parsing process.
    public func parse<T: Request>(request: T, data: Data) throws -> T.Response {
        return try parser.decode(T.Response.self, from: data)
    }
}

class RefreshTokenRedirector: ResponsePipelineRedirector {
    
    func shouldApply<T: Request>(request: T, data: Data, response: HTTPURLResponse) -> Bool {
        return response.statusCode == 401
    }
    
    func redirect<T: Request>(
        request: T,
        data: Data,
        response: HTTPURLResponse,
        done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws
    {
        API.refreshAccessToken { result in
            switch result {
            case .success(_):
                try? closure(.restartWithout(.redirector(self)))
            case .failure(let error):
                try? closure(.stop(error))
            }
        }
    }
}

class BadHTTPStatusRedirector: ResponsePipelineRedirector {
    let valid: Range<Int>
    
    init(valid: Range<Int>) {
        self.valid = valid
    }
    
    func shouldApply<T: Request>(request: T, data: Data, response: HTTPURLResponse) -> Bool {
        let code = response.statusCode
        return !valid.contains(code)
    }
    
    func redirect<T: Request>(
        request: T,
        data: Data,
        response: HTTPURLResponse,
        done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws
    {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let rawString = String(data: data, encoding: .utf8)
        do {
            // There are two possible error format now.
            // First, try to parse the error into a auth related error
            let error = try decoder.decode(InternalAuthError.self, from: data)
            let detail = LineSDKError.ResponseErrorReason.APIErrorDetail(
                code: response.statusCode,
                error: .init(error),
                raw: response,
                rawString: rawString)
            
            try closure(.stop(
                LineSDKError.responseFailed(
                    reason: .invalidHTTPStatusAPIError(detail: detail))
                )
            )
        } catch {
            do {
                // If failed to parse to a auth error, then try APIError format.
                let error = try decoder.decode(InternalAPIError.self, from: data)
                let detail = LineSDKError.ResponseErrorReason.APIErrorDetail(
                    code: response.statusCode,
                    error: .init(error),
                    raw: response,
                    rawString: rawString)
                try closure(.stop(
                    LineSDKError.responseFailed(
                        reason: .invalidHTTPStatusAPIError(detail: detail))
                    )
                )
            } catch {
                // An unknown error response format, let framework user decide what to do.
                let detail = LineSDKError.ResponseErrorReason.APIErrorDetail(
                    code: response.statusCode,
                    error: nil,
                    raw: response,
                    rawString: rawString)
                try closure(.stop(
                    LineSDKError.responseFailed(
                        reason: .invalidHTTPStatusAPIError(detail: detail))
                    )
                )
            }
        }
    }
}

class DataTransformRedirector: ResponsePipelineRedirector {
    
    let condition: ((Data) -> Bool)?
    let transform: (Data) -> Data
    
    init(condition: ((Data) -> Bool)? = nil, transform: @escaping (Data) -> Data) {
        self.transform = transform
        self.condition = condition
    }
    
    func shouldApply<T: Request>(request: T, data: Data, response: HTTPURLResponse) -> Bool {
        return condition?(data) ?? true
    }
    
    func redirect<T: Request>(
        request: T,
        data: Data,
        response: HTTPURLResponse,
        done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws
    {
        try closure(.continueWith(transform(data), response))
    }
    
    
}
