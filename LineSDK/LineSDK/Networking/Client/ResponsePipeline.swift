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


/// Represents the final pipeline of a series of response pipelines. Use the terminator to parse response
/// data into a final `Response` object of a certain `Request` object.
public protocol ResponsePipelineTerminator: class { // Use class protocol for easier Equatable conforming
    /// Parses `data` that holds input values to a `Response` object.
    ///
    /// - Parameters:
    ///   - request: The original request.
    ///   - data: The `Data` object received from a `Session` object.
    /// - Returns: The `Response` object.
    /// - Throws: An error that occurs during the parsing process.
    func parse<T: Request>(request: T, data: Data) throws -> T.Response
}

/// Represents a redirection stage of a series of response pipelines. Use redirectors to additionally
/// perform data processing by invoking `closure` with a proper
/// `ResponsePipelineRedirectorAction` enumeration member.
public protocol ResponsePipelineRedirector: class { // Use class protocol for easier Equatable conforming
    
    /// Whether this redirector should be applied to execute and handle a received HTTP response.
    /// - Parameters:
    ///   - request: The original `Request`.
    ///   - data: The received data contained in the HTTP response.
    ///   - response: The received HTTP response to the request.
    func shouldApply<T: Request>(request: T, data: Data, response: HTTPURLResponse) -> Bool
    
    /// Performs the redirect action for current redirector. Define how to process the received response and data.
    /// When the process is finished, call `closure` with the required action to make the response pipeline continue.
    /// - Parameters:
    ///   - request: The original `Request`.
    ///   - data: The received data contained in the HTTP response.
    ///   - response: The received HTTP response to the request.
    ///   - closure: A block to be called when you have finished processing the received response and data.
    ///              The block takes a single parameter, which must be one of the member in the
    ///              `ResponsePipelineRedirectorAction` enumeration.
    func redirect<T: Request>(
        request: T,
        data: Data,
        response: HTTPURLResponse,
        done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws
}

/// Actions against the processing result from a `ResponsePipelineRedirector` object. A redirector needs to
/// decide where to redirect the current request after data processing. These enumeration members provide data
/// destinations and behaviors of a redirector.
///
/// - restart: Restarts the current request with the original pipelines.
/// - restartWithout: Restarts the current request without certain pipelines.
/// - stop: Stops the handling process due to an error.
/// - continue: Continues the handling process.
/// - continueWith: Continues the handling process with modified data and response.
public enum ResponsePipelineRedirectorAction {

    /// Restarts the current request with the original pipelines.
    case restart

    /// Restarts the current request without certain pipelines.
    case restartWithout(ResponsePipeline)

    /// Stops the handling process due to an error.
    case stop(Error)

    /// Continues the handling process.
    case `continue`

    /// Continues the handling process with modified data and response.
    case continueWith(Data, HTTPURLResponse)
}

/// Pipelines for a response. Pipelines take a response and its data from a `Session` object. To convert data to
/// a `Response` object, the last pipeline must be a `terminator` pipeline. To process data, you can have
/// multiple `redirector` pipelines before the `terminator` pipeline.
///
/// - terminator: Associates a pipeline with a `ResponsePipelineTerminator` object to terminate the
///               current handling process.
/// - redirector: Associates a pipeline with a `ResponsePipelineRedirector` object to redirect the current
///               handling process.
public enum ResponsePipeline {

    /// Associates a pipeline with a `ResponsePipelineTerminator` object to terminate the current handling
    /// process.
    case terminator(ResponsePipelineTerminator)

    /// Associates a pipeline with a `ResponsePipelineRedirector` object to redirect the current handling
    /// process.
    case redirector(ResponsePipelineRedirector)
}

/// :nodoc:
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
    
    /// An underlying JSON parser of the pipeline.
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
    ///   - data: The `Data` object received from a `Session` object.
    /// - Returns: The `Response` object.
    /// - Throws: An error that occurs during the parsing process.
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
        API.Auth.refreshAccessToken { result in
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
            // There are two possible error formats now.
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
