//
//  GetAllFriendsRequest.swift
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

protocol SortParameterRequest {
    var sortParameter: String? { get }
}

protocol PaginatedResponse: Decodable {
    associatedtype Item: Decodable
    var paginatedValues: [Item] { get }
    var pageToken: String? { get }
}

class ChainedPaginatedRequest<T: Request> : Request where T.Response: PaginatedResponse {

    var method: HTTPMethod { return originalRequest.method }
    var path: String { return originalRequest.path }
    var authentication: AuthenticateMethod { return originalRequest.authentication }

    typealias Response = [T.Response.Item]

    init(originalRequest: T) {
        self.originalRequest = originalRequest
    }

    /// Called when every time a page is loaded and parsed. This would be invoked in the session's delegate queue.
    let onPageLoaded = Delegate<T.Response, Void>()

    let originalRequest: T

    var items: Response = []
    var currentPageToken: String?

    var parameters: Parameters? {
        var param: [String : Any] = [:]
        if let s = originalRequest as? SortParameterRequest, let sort = s.sortParameter {
            param["sort"] = sort
        }
        if let pageToken = currentPageToken {
            param["pageToken"] = pageToken
        }
        return param
    }

    var pipelines: [ResponsePipeline] {
        var pipelines: [ResponsePipeline] = []
        if let refreshTokenPipeline = authentication.refreshTokenPipeline {
            pipelines.append(refreshTokenPipeline)
        }

        pipelines.append(.redirector(BadHTTPStatusRedirector(valid: 200..<300)))

        let intermediateParser = PaginatedParseRedirector(request: self, parser: defaultJSONParser)
        intermediateParser.onParsed.delegate(on: self) { (self, response) in
            self.onPageLoaded.call(response)
        }

        pipelines.append(.redirector(intermediateParser))
        pipelines.append(.terminator(PaginatedResultTerminator(request: self)))

        return pipelines
    }
}

// Parse an intermediate response (single response) of a `ChainedPaginatedRequest`.
class PaginatedParseRedirector<Wrapped: Request>: ResponsePipelineRedirector where Wrapped.Response: PaginatedResponse {

    let parser: JSONDecoder
    let chainedPaginatedRequest: ChainedPaginatedRequest<Wrapped>

    let onParsed = Delegate<Wrapped.Response, Void>()

    init(request: ChainedPaginatedRequest<Wrapped>, parser: JSONDecoder) {
        self.chainedPaginatedRequest = request
        self.parser = parser
    }

    func shouldApply<T: Request>(request: T, data: Data, response: HTTPURLResponse) -> Bool {
        return true
    }

    func redirect<T: Request>(
        request: T,
        data: Data,
        response: HTTPURLResponse,
        done closure: @escaping (ResponsePipelineRedirectorAction) throws -> Void) throws
    {
        let paginatedValue = try parser.decode(Wrapped.Response.self, from: data)
        onParsed.call(paginatedValue)

        chainedPaginatedRequest.items.append(contentsOf: paginatedValue.paginatedValues)

        if let nextPageToken = paginatedValue.pageToken {
            chainedPaginatedRequest.currentPageToken = nextPageToken
            try closure(.restart)
        } else {
            try closure(.continue)
        }
    }
}

class PaginatedResultTerminator<Wrapped: Request>: ResponsePipelineTerminator where Wrapped.Response: PaginatedResponse {
    let chainedPaginatedRequest: ChainedPaginatedRequest<Wrapped>

    init(request: ChainedPaginatedRequest<Wrapped>) {
        self.chainedPaginatedRequest = request
    }

    func parse<T: Request>(request: T, data: Data) throws -> T.Response {
        return chainedPaginatedRequest.items as! T.Response
    }
}
