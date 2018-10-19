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

/// Represents an API error that occurs when interacting with the LINE Platform. If the LINE Platform
/// returns an error in a known format, the error is parsed into an `APIError` object and thrown out. The
/// error type is `LineSDKError.responseFailed` with `.invalidHTTPStatusAPIError`.
///
public struct APIError {
    
    /// The error state received from the LINE Platform.
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
