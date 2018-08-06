//
//  LineSDKError.swift
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

/// `LineSDKError` is the error type returned by LineSDK. It encompasses a few different types of errors, each with
/// their own associated reasons.
///
/// You could switch over the error to know the detail reason and associated information for each error. Or you could
/// access the `localizedDescription` property to get a human-readable text description.
///
/// - requestFailed: Returned when something wrong happens while constructing a request.
/// - responseFailed: Returned when something wrong happens during handling response.
/// - authorizeFailed: Returned when something wrong happens during user authorizing process.
/// - generalError: Other general errors might happen in LineSDK.
public enum LineSDKError: Error {
    
    
    /// The underlying reason for why `.requestFailed` happens.
    ///
    /// - missingURL: `URL` is missing while encoding a request.
    /// - lackOfAccessToken: The request requires an access token, but there is no one.
    /// - jsonEncodingFailed: The request requires a JSON body, but provided data cannot be encoded to valid JSON.
    public enum RequestErrorReason {
        case missingURL
        case lackOfAccessToken
        case jsonEncodingFailed(Error)
    }
    
    /// The underlying reason for why `.responseFailed` happens.
    ///
    /// - URLSessionError: Error happens in the underlying `URLSession`.
    /// - nonHTTPURLResponse: The response is not a valid `HTTPURLResponse`.
    /// - dataParsingFailed: Cannot parse received data to an instance of target type.
    /// - invalidHTTPStatusAPIError: Received response contains an invalid HTTP status code, and the response can be
    ///                              converted to an `APIError` object to indicate what is going wrong.
    /// - invalidHTTPStatus: Received response contains an invalid HTTP status code, but the response cannot be
    ///                      converted to an `APIError` due to unknown response format.
    public enum ResponseErrorReason {
        case URLSessionError(Error)
        case nonHTTPURLResponse
        case dataParsingFailed(Any.Type, Data, Error)
        case invalidHTTPStatusAPIError(code: Int, error: APIError, raw: String?)
        case invalidHTTPStatus(code: Int, raw: String?)
    }
    
    /// The underlying reason for why `.authorizeFailed` happens.
    ///
    /// - exhaustedLoginFlow: There is no other login methods left. The login process cannot be completed.
    /// - malformedHierarchy: The view hierarchy or view controller hierarchy is malformed and LineSDK cannot present
    ///                       its login view controller.
    /// - userCancelled: User cancelled or interrupted the login process.
    /// - forceStopped: `stop` method is called on the login process.
    /// - callbackURLSchemeNotMatching: The received `URL` while opening app does not match the URL scheme defined.
    /// - invalidSourceApplication: The source application is invalid to finish auth process.
    /// - malformedRedirectURL: The received `URL` while opening app is not a valid one, or does not contain all
    ///                         necessary information.
    /// - invalidLineURLResultCode: An unknown `resultCode` in the opening app `URL`.
    /// - lineClientError: An error happens in the LINE client app while auth process.
    /// - responseStateValueNotMatching: Invalid `state` verification. Received URL response is not from the
    ///                                  original auth request.
    /// - webLoginError: An error happens in the web login flow while auth process.
    /// - keychainOperation: An error happens in keychain access which prevents LineSDK loads or writes to keychain.
    /// - invalidDataInKeychain: The retrieved auth information from keychain cannot be converted to valid data.
    public enum AuthorizeErrorReason {
        case exhaustedLoginFlow
        case malformedHierarchy
        case userCancelled
        case forceStopped
        case callbackURLSchemeNotMatching
        case invalidSourceApplication
        case malformedRedirectURL(url: URL, message: String?)
        case invalidLineURLResultCode(String)
        case lineClientError(code: String, message: String?)
        case responseStateValueNotMatching(expected: String, got: String?)
        case webLoginError(error: String, description: String?)
        case keychainOperation(status: OSStatus)
        case invalidDataInKeychain
    }
    
    /// The underlying reason for why `.generalError` happens.
    ///
    /// - conversionError: Cannot convert target `string` to valid data under `encoding`.
    public enum GeneralErrorReason {
        case conversionError(string: String, encoding: String.Encoding)
    }
    
    case requestFailed(reason: RequestErrorReason)
    case responseFailed(reason: ResponseErrorReason)
    case authorizeFailed(reason: AuthorizeErrorReason)
    case generalError(reason: GeneralErrorReason)
}

// MARK: - Classifies the Error
extension LineSDKError {
    /// Returns whether the `LineSDKError` is a request error.
    public var isRequestError: Bool {
        if case .requestFailed = self {
            return true
        }
        return false
    }
    
    /// Returns whether the `LineSDKError` is a response error.
    public var isResponseError: Bool {
        if case .responseFailed = self {
            return true
        }
        return false
    }
    
    /// Returns whether the `LineSDKError` is an authorization error.
    public var isAuthorizeError: Bool {
        if case .authorizeFailed = self {
            return true
        }
        return false
    }
    
    /// Returns whether the `LineSDKError` is a general error.
    public var isGeneralError: Bool {
        if case .generalError = self {
            return true
        }
        return false
    }
}

// MARK: - Convenience Properties
extension LineSDKError {
    /// Returns whether the `LineSDKError` is an authorization error with `.userCancelled` as its reason.
    public var isUserCancelled: Bool {
        if case .authorizeFailed(.userCancelled) = self {
            return true
        }
        return false
    }
}

// MARK: - Error Description
extension LineSDKError: LocalizedError {
    /// Describes why an error happens in human-readable text.
    public var errorDescription: String? {
        switch self {
        case .requestFailed(reason: let reason): return reason.errorDescription
        case .responseFailed(reason: let reason): return reason.errorDescription
        case .authorizeFailed(reason: let reason): return reason.errorDescription
        case .generalError(reason: let reason): return reason.errorDescription
        }
    }
}

extension LineSDKError.RequestErrorReason {
    var errorDescription: String? {
        switch self {
        case .missingURL:
            return "URL is missing while encoding a request."
        case .lackOfAccessToken:
            return "The request requires an access token, but there is no one."
        case .jsonEncodingFailed(let error):
            return "The request requires a JSON body, but provided data cannot be encoded to valid JSON. \(error)"
        }
    }
}

extension LineSDKError.ResponseErrorReason {
    var errorDescription: String? {
        switch self {
        case .URLSessionError(let error):
            return "URLSession task finished with error: \(error)"
        case .nonHTTPURLResponse:
            return "The response is not a valid `HTTPURLResponse`."
        case .dataParsingFailed(let type, let data, let error):
            let result = "Parsing response data to \(type) failed: \(error)."
            if let text = String(data: data, encoding: .utf8) {
                return result + "\nOriginal: \(text)"
            } else {
                return result
            }
        case .invalidHTTPStatusAPIError(let code, let error, let raw):
            return "HTTP status code is not valid in response. Code: \(code), error: \(error.error), raw data: \(raw ?? "nil")"
        case .invalidHTTPStatus(let code, let raw):
            return "HTTP status code is not valid in response. Code: \(code), raw data: \(raw ?? "nil")"
        }
    }
}

extension LineSDKError.AuthorizeErrorReason {
    var errorDescription: String? {
        switch self {
        case .exhaustedLoginFlow:
            return "There is no other login methods left. The login process cannot be completed."
        case .malformedHierarchy:
            return "The view hierarchy or view controller hierarchy is malformed and LineSDK cannot " +
                   "present its login view controller."
        case .userCancelled:
            return "User cancelled or interrupted the login process."
        case .forceStopped:
            return "Method stop is called on the login process."
        case .callbackURLSchemeNotMatching:
            return "The received `URL` while opening app does not match the URL scheme defined."
        case .invalidSourceApplication:
            return "The source application is invalid to finish auth process."
        case .malformedRedirectURL(let url, let message):
            return "The received `URL` while opening app is not a valid one, " +
                   "or does not contain all necessary information. URL: \(url), message: \(message ?? "nil")."
        case .invalidLineURLResultCode(let code):
            return "An unknown `resultCode` (\(code)) in the opening app `URL`."
        case .lineClientError(let code, let message):
            return "LINE client app failed while auth process. Error: \(code), message: \(message ?? "nil")"
        case .responseStateValueNotMatching(_, _):
            return "Invalid `state` verification. Received URL response is not from the original auth request."
        case .webLoginError(let error, let message):
            return "Web login flow failed while auth process. Error: \(error), message: \(message ?? "nil")"
        case .keychainOperation(let status):
            return "Writing or loading token failed. Keychain operation error: \(status)"
        case .invalidDataInKeychain:
            return "The retrieved auth information from keychain cannot be converted to valid data."
        }
    }
}

extension LineSDKError.GeneralErrorReason {
    var errorDescription: String? {
        switch self {
        case .conversionError(let text, let encoding):
            return "Cannot convert target \"\(text)\" to valid data under \(encoding) encoding."
        }
    }
}

