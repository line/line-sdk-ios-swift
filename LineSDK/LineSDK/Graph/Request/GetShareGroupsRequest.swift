//
//  GetShareGroupsRequest.swift
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

/// LINE internal use only.
/// Represents the request of returning a list of groups that the user belongs to.
///
/// `LoginPermission.oneTimeShare` is required.
///
public struct GetShareGroupsRequest: Request {

    public init(pageToken: String? = nil) {
        self.pageToken = pageToken
    }

    let pageToken: String?

    public let method: HTTPMethod = .get
    public let path = "/graph/v2/ots/groups"
    public let authentication: AuthenticateMethod = .token

    public var parameters: [String : Any]? {
        var param: [String : Any] = [:]
        if let pageToken = pageToken {
            param["pageToken"] = pageToken
        }
        return param
    }

    public struct Response: Decodable {

        /// An array of `Group` that the user belongs to.
        public let groups: [Group]

        /// If there are more objects in the subsequent pages, use this value as the index in the next page request.
        /// This field is omitted when there is no more objects in subsequent pages.
        public let pageToken: String?
    }
}

extension GetShareGroupsRequest.Response: PaginatedResponse {
    var paginatedValues: [Group] { return groups }
}
