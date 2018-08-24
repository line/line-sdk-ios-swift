//
//  APIError.swift
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

struct InternalAuthError: Decodable {
    let error: String
    let errorDescription: String?
}

struct InternalAPIError: Decodable {
    let message: String
}

/// Represents API error happens when interacting with LINE APIs.
/// If server returns an error in a known format, the error will be parsed to an `APIError` and
/// an `SDKError.responseFailed` with `.invalidHTTPStatusAPIError` as its reason will be thrown out.
///
public struct APIError {
    
    /// Error state received from server.
    public let error: String
    
    /// Detail of the error.
    public let detail: String?
    
    init(_ original: InternalAPIError) {
        self.error = original.message
        self.detail = nil
    }
    
    init(_ original: InternalAuthError) {
        self.error = original.error
        self.detail = original.errorDescription
    }
}
