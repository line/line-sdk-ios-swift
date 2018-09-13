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
/// access the `localizedDescription` property to get a human-readable text description. Access `errorCode` to get a
/// fixed error code to identify the error type quickly. All `LineSDKError`s are under the "LineSDKError" error domain.
///
/// - requestFailed: Returned when something wrong happens while constructing a request.
/// - responseFailed: Returned when something wrong happens during handling response.
/// - authorizeFailed: Returned when something wrong happens during user authorizing process.
/// - generalError: Other general errors might happen in LineSDK.
public enum LineSDKError: Error {
    
    /// The underlying reason for why `.requestFailed` happens.
    ///
    /// - missingURL: `URL` is missing while encoding a request. Code 1001.
    /// - lackOfAccessToken: The request requires an access token, but there is no one. Code 1002.
    /// - jsonEncodingFailed: The request requires a JSON body, but provided data cannot be encoded to valid JSON.
    ///                       Code 1003.
    public enum RequestErrorReason {
        case missingURL
        case lackOfAccessToken
        case jsonEncodingFailed(Error)
    }
    
    /// The underlying reason for why `.responseFailed` happens.
    ///
    /// - URLSessionError: Error happens in the underlying `URLSession`. Code 2001.
    /// - nonHTTPURLResponse: The response is not a valid `HTTPURLResponse`. Code 2002.
    /// - dataParsingFailed: Cannot parse received data to an instance of target type. Code 2003.
    /// - invalidHTTPStatusAPIError: Received response contains an invalid HTTP status code. If the response data
    ///                              can be converted to an `APIError` object, it will be associated as the `error`
    ///                              to indicate what is going wrong. Otherwise, the `error` will be `nil`. In both
    ///                              cases, `raw` will contain the plain error text. Code 2004.
    public enum ResponseErrorReason {
        case URLSessionError(Error)
        case nonHTTPURLResponse
        case dataParsingFailed(Any.Type, Data, Error)
        case invalidHTTPStatusAPIError(code: Int, error: APIError?, raw: String?)
    }
    
    /// The underlying reason for why `.authorizeFailed` happens.
    ///
    /// - exhaustedLoginFlow: There is no other login methods left. The login process cannot be completed. Code 3001.
    /// - malformedHierarchy: The view hierarchy or view controller hierarchy is malformed and LineSDK cannot present
    ///                       its login view controller. Code 3002.
    /// - userCancelled: User cancelled or interrupted the login process. Code 3003.
    /// - forceStopped: `stop` method is called on the login process. Code 3004.
    /// - callbackURLSchemeNotMatching: The received `URL` while opening app does not match the URL scheme defined.
    ///                                 Code 3005.
    /// - invalidSourceApplication: The source application is invalid to finish auth process. Code 3006.
    /// - malformedRedirectURL: The received `URL` while opening app is not a valid one, or does not contain all
    ///                         necessary information. Code 3007.
    /// - invalidLineURLResultCode: An unknown `resultCode` in the opening app `URL`. Code 3008.
    /// - lineClientError: An error happens in the LINE client app while auth process. Code 3009.
    /// - responseStateValueNotMatching: Invalid `state` verification. Received URL response is not from the
    ///                                  original auth request. Code 3010.
    /// - webLoginError: An error happens in the web login flow while auth process. Code 3011.
    /// - keychainOperation: An error happens in keychain access which prevents LineSDK loads or writes to keychain.
    ///                      Code 3012.
    /// - invalidDataInKeychain: The retrieved auth information from keychain cannot be converted to valid data.
    ///                          Code 3013.
    /// - lackOfIDToken: The authorization contains openID permission, but ID token cannot be found or parsed in
    ///                  server response. Code 3014.
    /// - JWTPublicKeyNotFound: Public key not found for a give key ID or the key ID does not exist. Code 3015.
    /// - cryptoError: Something wrong happened inside LineSDK crypto part. This usually indicates a malformed
    ///                certificate or key error, or an unsupport algorithm is used. See `CryptoError` for more.
    ///                Code 3016.
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
        case lackOfIDToken(raw: String?)
        case JWTPublicKeyNotFound(keyID: String?)
        case cryptoError(error: CryptoError)
    }
    
    /// The underlying reason for why `.generalError` happens.
    ///
    /// - conversionError: Cannot convert target `string` to valid data under `encoding`.
    /// - parameterError: Method invoked with an invalid parameter.
    public enum GeneralErrorReason {
        case conversionError(string: String, encoding: String.Encoding)
        case parameterError(parameterName: String, description: String)
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
    
    /// Returns whether the `LineSDKError` represents a bad request error.
    public var isBadRequest: Bool {
        return isResponseError(statusCode: 400)
    }
    
    /// Returns whether the `LineSDKError` represents a permission granting issue. Usually, it means you do not have
    /// enough permission to invoke a LINE API.
    public var isPermissionError: Bool {
        return isResponseError(statusCode: 403)
    }
    
    /// Returns whether the `LineSDKError` represents a token problem. Usually, it means your token is expired or
    /// malformed.
    public var isTokenError: Bool {
        return isResponseError(statusCode: 401)
    }
    
    /// Returns whether the `LineSDKError` represents a response failing with specified HTTP status code.
    ///
    /// - Parameter statusCode: The status code to check whether matches HTTP status error code.
    /// - Returns: `true` if `self` is a .invalidHTTPStatusAPIError with give `statusCode`. Otherwise, `false`.
    public func isResponseError(statusCode: Int) -> Bool {
        if case .responseFailed(.invalidHTTPStatusAPIError(code: statusCode, error: _, raw: _)) = self {
            return true
        }
        return false
    }
    
    /// Returns whether the `LineSDKError` represents a time out error from underlying URL session error.
    public var isURLSessionTimeout: Bool {
        return isURLSessionErrorCode(sessionErrorCode: NSURLErrorTimedOut)
    }
    
    /// Returns whether the `LineSDKError` represents a URL session error with specified error code.
    ///
    /// - Parameter code: The underlying URL session error code. See `NSURLError` in Foundation.
    /// - Returns: `true` if `self` is a .URLSessionError with give `code`. Otherwise, `false`.
    public func isURLSessionErrorCode(sessionErrorCode code: Int) -> Bool {
        if case .responseFailed(.URLSessionError(let error)) = self {
            let nsError = error as NSError
            return nsError.code == code
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

// MARK: - NSError Compatibility
extension LineSDKError: CustomNSError {
    public var errorCode: Int {
        switch self {
        case .requestFailed(reason: let reason): return reason.errorCode
        case .responseFailed(reason: let reason): return reason.errorCode
        case .authorizeFailed(reason: let reason): return reason.errorCode
        case .generalError(reason: let reason): return reason.errorCode
        }
    }
    
    public var errorUserInfo: [String : Any] {
        switch self {
        case .requestFailed(reason: let reason): return reason.errorUserInfo
        case .responseFailed(reason: let reason): return reason.errorUserInfo
        case .authorizeFailed(reason: let reason): return reason.errorUserInfo
        case .generalError(reason: let reason): return reason.errorUserInfo
        }
    }
    
    public static var errorDomain: String {
        return "LineSDKError"
    }
}

// MARK: - Private Definition
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
    
    var errorCode: Int {
        switch self {
        case .missingURL:         return 1001
        case .lackOfAccessToken:  return 1002
        case .jsonEncodingFailed: return 1003
        }
    }
    
    var errorUserInfo: [String: Any] {
        var userInfo: [LineSDKErrorUserInfoKey: Any] = [:]
        switch self {
        case .missingURL: break
        case .lackOfAccessToken: break
        case .jsonEncodingFailed(let error):
            userInfo[.underlyingError] = error
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
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
            if let error = error {
                return "HTTP status code is not valid in response. Code: \(code), error: \(error.error), raw data: \(raw ?? "nil")"
            } else {
                return "HTTP status code is not valid in response. Code: \(code), raw data: \(raw ?? "nil")"
            }
        }
    }
    
    var errorCode: Int {
        switch self {
        case .URLSessionError:           return 2001
        case .nonHTTPURLResponse:        return 2002
        case .dataParsingFailed:         return 2003
        case .invalidHTTPStatusAPIError: return 2004
        }
    }
    
    var errorUserInfo: [String: Any] {
        var userInfo: [LineSDKErrorUserInfoKey: Any] = [:]
        switch self {
        case .URLSessionError(let error):
            userInfo[.underlyingError] = error
        case .nonHTTPURLResponse:
            break
        case .dataParsingFailed(let type, let data, let error):
            userInfo[.underlyingError] = error
            userInfo[.type] = type
            userInfo[.data] = data
        case .invalidHTTPStatusAPIError(let code, let error, let raw):
            userInfo[.statusCode] = code
            if let error = error { userInfo[.APIError] = error }
            if let raw = raw { userInfo[.raw] = raw }
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
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
        case .lackOfIDToken(let raw):
            return "Authorization permission contains .openID, but no ID Token can be found or parsed in response. " +
                   "Raw: \(String(describing: raw))"
        case .JWTPublicKeyNotFound(let keyID):
            return "Cannot find a JWT public key in JWKs for Key ID: \(keyID ?? "nil")"
        case .cryptoError(let error):
            return "CryptoError: \(error.errorDescription ?? "nil")"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .exhaustedLoginFlow:            return 3001
        case .malformedHierarchy:            return 3002
        case .userCancelled:                 return 3003
        case .forceStopped:                  return 3004
        case .callbackURLSchemeNotMatching:  return 3005
        case .invalidSourceApplication:      return 3006
        case .malformedRedirectURL:          return 3007
        case .invalidLineURLResultCode:      return 3008
        case .lineClientError:               return 3009
        case .responseStateValueNotMatching: return 3010
        case .webLoginError:                 return 3011
        case .keychainOperation:             return 3012
        case .invalidDataInKeychain:         return 3013
        case .lackOfIDToken:                 return 3014
        case .JWTPublicKeyNotFound:          return 3015
        case .cryptoError:                   return 3016
        }
    }
    
    var errorUserInfo: [String: Any] {
        var userInfo: [LineSDKErrorUserInfoKey: Any] = [:]
        switch self {
        case .exhaustedLoginFlow: break
        case .malformedHierarchy: break
        case .userCancelled: break
        case .forceStopped: break
        case .callbackURLSchemeNotMatching: break
        case .invalidSourceApplication: break
        case .malformedRedirectURL(let url, let message):
            userInfo[.url] = url
            if let message = message { userInfo[.message] = message }
        case .invalidLineURLResultCode(let code):
            userInfo[.resultCode] = code
        case .lineClientError(let code, let message):
            userInfo[.resultCode] = code
            if let message = message { userInfo[.message] = message }
        case .responseStateValueNotMatching(_, _):
            userInfo = [:]
        case .webLoginError(let error, let message):
            userInfo[.underlyingError] = error
            if let message = message { userInfo[.message] = message }
        case .keychainOperation(let status):
            userInfo[.status] = status
        case .invalidDataInKeychain: break
        case .lackOfIDToken(let raw):
            if let raw = raw { userInfo[.raw] = raw }
        case .JWTPublicKeyNotFound(let keyID):
            if let keyID = keyID { userInfo[.raw] = keyID }
        case .cryptoError(let error):
            userInfo[.underlyingError] = error
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

extension LineSDKError.GeneralErrorReason {
    var errorDescription: String? {
        switch self {
        case .conversionError(let text, let encoding):
            return "Cannot convert target \"\(text)\" to valid data under \(encoding) encoding."
        case .parameterError(let parameterName, let reason):
            return "Method invoked with an invalid parameter \"\(parameterName)\". Reason: \(reason)"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .conversionError(_, _): return 4001
        case .parameterError(_, _):  return 4002
        }
    }
    
    var errorUserInfo: [String: Any] {
        var userInfo: [LineSDKErrorUserInfoKey: Any] = [:]
        switch self {
        case .conversionError(let text, let encoding):
            userInfo[.text] = text
            userInfo[.encoding] = encoding
        case .parameterError(let parameterName, let reason):
            userInfo[.parameterName] = parameterName
            userInfo[.reason] = reason
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

public enum LineSDKErrorUserInfoKey: String {
    case underlyingError
    case statusCode
    case resultCode
    case type
    case data
    case APIError
    case raw
    case url
    case message
    case status
    case text
    case encoding
    case parameterName
    case reason
    case index
    case key
    case got
}

