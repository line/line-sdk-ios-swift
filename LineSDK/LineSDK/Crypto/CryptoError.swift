//
//  CryptoError.swift
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

/// `CryptoError` is an error subtype of LineSDK, which is related to certs, keys and token verification.
/// A `CryptoError` will not be thrown to you directly, all these kind of errors will be wrapped under
/// `LineSDKError.authorizeFailed` with `.cryptoError` reason (which has an error code `3016`).
/// You could find the underlying `CryptoError` by checking the associated value of `.cryptoError` reason,
/// or by accessing the `.underlyingError` key in the error's `userInfo`.
///
/// You could switch over the error to know the detail reason and associated information for each error. Or you could
/// access the `localizedDescription` property to get a human-readable text description. Access `errorCode` to get a
/// fixed error code to identify the error type quickly.
/// All `CryptoError`s are under the "LineSDKError.CryptoError" error domain.
///
/// - RSAFailed: Returned when something wrong happens while performing RSA related operations like creating keys or
///              verifying signed data.
/// - JWTFailed: Returned when something wrong happens while performing JWT related operations.
/// - JWKFailed: Returned when something wrong happens while performing JWK related operations.
/// - generalError: Other general errors might happen for crypto in LineSDK.
public enum CryptoError: Error {
    
    /// The underlying reason for why a `.algorithmsFailed` happens.
    ///
    /// - invalidDERKey: The DER data does not contain a valid RSA key. Code 3016_1001.
    /// - invalidX509Header: x509 header is found in the key, but the expected data is wrong. Code 3016_1002.
    /// - createKeyFailed: Error happens while creating security key. Code 3016_1003.
    /// - invalidPEMKey: The PEM key is invalid. Code 3016_1004.
    /// - encryptingError: Error happens while encrypting some plain data. Code 3016_1005.
    /// - decryptingError: Error happens while decrypting some encrypted data. Code 3016_1006.
    /// - signingError: Error happens while signing some plain data. Code 3016_1007.
    /// - verifyingError:  Error happens while verifying data. Code 3016_1008.
    public enum AlgorithmsErrorReason {
        
        /// The DER data does not contain a valid RSA key. Code 3016_1001.
        case invalidDERKey(data: Data, reason: String)
        
        /// x509 header is found in the key, but the expected data is wrong. Code 3016_1002.
        case invalidX509Header(data: Data, index: Int, reason: String)
        
        /// Error happens while creating security key. Code 3016_1003.
        case createKeyFailed(data: Data, reason: String)
        
        /// The PEM key is invalid. Code 3016_1004.
        case invalidPEMKey(string: String, reason: String)
        
        /// Error happens while encrypting some plain data. Code 3016_1005.
        case encryptingError(Error?)
        
        /// Error happens while decrypting some encrypted data. Code 3016_1006.
        case decryptingError(Error?)
        
        /// Error happens while signing some plain data. Code 3016_1007.
        case signingError(Error?)
        
        /// Error happens while verifying data. Code 3016_1008.
        case verifyingError(Error?, statusCode: Int?)
    }

    /// The underlying reason for why a `.JWTFailed` happens.
    ///
    /// - malformedJWTFormat: The input text is not a valid JWT encoded string. Code 3016_2001.
    /// - unsupportedHeaderAlgorithm: The algorithm defined in JWT header is not supported in LineSDK. Code 3016_2002.
    /// - claimVerifyingFailed: Verification for a certain key in JWT payload does not pass. Code 3016_2003.
    public enum JWTErrorReason {
        
        /// The input text is not a valid JWT encoded string. Code 3016_2001.
        case malformedJWTFormat(string: String)
        
        /// The algorithm defined in JWT header is not supported in LineSDK. Code 3016_2002.
        case unsupportedHeaderAlgorithm(name: String)
        
        /// Verification for a certain key in JWT payload does not pass. Code 3016_2003.
        case claimVerifyingFailed(key: String, got: String, description: String)
    }    

    /// The underlying reason for why a `.JWKFailed` happens.
    ///
    /// - unsupportedKeyType: The key type is not supported in LineSDK. Code 3016_3001.
    public enum JWKErrorReason {
        
        /// The key type is not supported in LineSDK. Code 3016_3001.
        case unsupportedKeyType(String)
    }
    
    /// The underlying reason for why a `.generalError` happens.
    ///
    /// - base64ConversionFailed: String cannot be converted to base64 data format. Code 3016_4001.
    /// - dataConversionFailed: Cannot convert data to string under a given encoding. Code 3016_4002.
    /// - stringConversionFailed: Cannot convert string to data under a given encoding. Code 3016_4003.
    /// - operationNotSupported: The operation is not supported in current OS. Code 3016_4004.
    /// - decodingFailed: Decoding data to a target type failed. Code 3016_4005.
    public enum GeneralErrorReason {
        
        /// String cannot be converted to base64 data format. Code 3016_4001.
        case base64ConversionFailed(string: String)
        
        /// Cannot convert data to string under a given encoding. Code 3016_4002.
        case dataConversionFailed(data: Data, encoding: String.Encoding)
        
        /// Cannot convert string to data under a given encoding. Code 3016_4003.
        case stringConversionFailed(string: String, encoding: String.Encoding)
        
        /// The operation is not supported in current OS. Code 3016_4004.
        case operationNotSupported(reason: String)
        
        /// Decoding data to a target type failed. Code 3016_4005.
        case decodingFailed(string: String, type: Any.Type)
    }
    
    case algorithmsFailed(reason: AlgorithmsErrorReason)
    case JWTFailed(reason: JWTErrorReason)
    case JWKFailed(reason: JWKErrorReason)
    case generalError(reason: GeneralErrorReason)
}

extension CryptoError.AlgorithmsErrorReason {
    
    var errorDescription: String? {
        switch self {
        case .invalidDERKey(_, let reason):
            return "DER data does not contain a valid key. \(reason)"
        case .invalidX509Header(_, let index, let reason):
            return "x509 header is found in the key, but the expected data at index: \(index) is wrong. \(reason)"
        case .createKeyFailed(_, let reason):
            return "Error happens while creating security key. \(reason)"
        case .invalidPEMKey(_, let reason):
            return "The PEM key is invalid. \(reason)"
        case .encryptingError(let error):
            return "Error happens while encrypting some plain data. Error: \(String(describing: error))"
        case .decryptingError(let error):
            return "Error happens while decrypting some plain data. Error: \(String(describing: error))"
        case .signingError(let error):
            return "Error happens while signing some plain data. Error: \(String(describing: error))"
        case .verifyingError(let error, let code):
            return "Error happens while verifying some plain data. " +
                   "Error: \(String(describing: error)), code: \(String(describing: code))"
        }
    }
    
    var errorCode: Int {
        switch self {
        case .invalidDERKey:     return 3016_1001
        case .invalidX509Header: return 3016_1002
        case .createKeyFailed:   return 3016_1003
        case .invalidPEMKey:     return 3016_1004
        case .encryptingError:   return 3016_1005
        case .decryptingError:   return 3016_1006
        case .signingError:      return 3016_1007
        case .verifyingError:    return 3016_1008
        }
    }
    
    var errorUserInfo: [String: Any] {
        var userInfo = [LineSDKErrorUserInfoKey: Any]()
        switch self {
        case .invalidDERKey(let data, _):
            userInfo[.data] = data
        case .invalidX509Header(let data, let index, _):
            userInfo[.data] = data
            userInfo[.index] = index
        case .createKeyFailed(let data, _):
            userInfo[.data] = data
        case .invalidPEMKey(let data, _):
            userInfo[.data] = data
        case .encryptingError(let error):
            userInfo[.underlyingError] = error
        case .decryptingError(let error):
            userInfo[.underlyingError] = error
        case .signingError(let error):
            userInfo[.underlyingError] = error
        case .verifyingError(let error, let code):
            userInfo[.underlyingError] = error
            if let code = code {
                userInfo[.statusCode] = code
            }
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

extension CryptoError.JWTErrorReason {
    
    var errorDescription: String? {
        switch self {
        case .malformedJWTFormat(let string):
            return "The input text is not a valid JWT encoded string: \(string)"
        case .unsupportedHeaderAlgorithm(let name):
            return "The algorithm (\(name)) defined in JWT header is not supported in LineSDK."
        case .claimVerifyingFailed(let key, let got, let description):
            return "Verification failed for key: \(key). Got: \(got), \(description)"
        }
    }
    
    var errorCode: Int {
        switch self {
            
        case .malformedJWTFormat:         return 3016_2001
        case .unsupportedHeaderAlgorithm: return 3016_2002
        case .claimVerifyingFailed:       return 3016_2003
        }
    }
    
    var errorUserInfo: [String: Any] {
        var userInfo = [LineSDKErrorUserInfoKey: Any]()
        switch self {
        case .malformedJWTFormat(let string):
            userInfo[.text] = string
        case .unsupportedHeaderAlgorithm(let name):
            userInfo[.raw] = name
        case .claimVerifyingFailed(let key, let got, _):
            userInfo[.key] = key
            userInfo[.got] = got
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

extension CryptoError.JWKErrorReason {
    
    var errorDescription: String? {
        switch self {
        case .unsupportedKeyType(let keyType):
            return "The key type (\(keyType)) is not supported in LineSDK."
        }
    }
    
    var errorCode: Int {
        switch self {
        case .unsupportedKeyType: return 3016_3001
        }
    }
    
    var errorUserInfo: [String: Any] {
        var userInfo = [LineSDKErrorUserInfoKey: Any]()
        switch self {
        case .unsupportedKeyType(let keyType):
            userInfo[.raw] = keyType
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

extension CryptoError.GeneralErrorReason {
    
    var errorDescription: String? {
        switch self {
        case .base64ConversionFailed(let string):
            return "String cannot be converted to base64 data format: \(string)"
        case .dataConversionFailed(let data, let encoding):
            return "Cannot convert data to string under a given encoding. Data: \(data), encoding: \(encoding)"
        case .stringConversionFailed(let string, let encoding):
            return "Cannot convert string to data under a given encoding. String: \(string), encoding: \(encoding)"
        case .operationNotSupported(let reason):
            return "The operation is not supported in current OS. \(reason)"
        case .decodingFailed(let string, let type):
            return "Cannot decode string: \(string) to \(type)."
        }
    }
    
    var errorCode: Int {
        switch self {
            
        case .base64ConversionFailed: return 3016_4001
        case .dataConversionFailed:   return 3016_4002
        case .stringConversionFailed: return 3016_4003
        case .operationNotSupported:  return 3016_4004
        case .decodingFailed:         return 3016_4005
        }
    }
    
    var errorUserInfo: [String: Any] {
        var userInfo = [LineSDKErrorUserInfoKey: Any]()
        switch self {
        case .base64ConversionFailed(let string):
            userInfo[.text] = string
        case .dataConversionFailed(let data, let encoding):
            userInfo[.data] = data
            userInfo[.encoding] = encoding
        case .stringConversionFailed(let string, let encoding):
            userInfo[.text] = string
            userInfo[.encoding] = encoding
        case .operationNotSupported:
            break
        case .decodingFailed(let string, let type):
            userInfo[.raw] = string
            userInfo[.type] = type
        }
        return .init(uniqueKeysWithValues: userInfo.map { ($0.rawValue, $1) })
    }
}

// MARK: - Error Description
extension CryptoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .algorithmsFailed(reason: let reason): return reason.errorDescription
        case .JWTFailed(reason: let reason): return reason.errorDescription
        case .JWKFailed(reason: let reason): return reason.errorDescription
        case .generalError(reason: let reason): return reason.errorDescription
        }
    }
}

// MARK: - NSError Compatibility
extension CryptoError: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        switch self {
        case .algorithmsFailed(reason: let reason): return reason.errorUserInfo
        case .JWTFailed(reason: let reason): return reason.errorUserInfo
        case .JWKFailed(reason: let reason): return reason.errorUserInfo
        case .generalError(reason: let reason): return reason.errorUserInfo
        }
    }
    
    public var errorCode: Int {
        switch self {
        case .algorithmsFailed(reason: let reason): return reason.errorCode
        case .JWTFailed(reason: let reason): return reason.errorCode
        case .JWKFailed(reason: let reason): return reason.errorCode
        case .generalError(reason: let reason): return reason.errorCode
        }
    }
    
    public static var errorDomain: String {
        return "LineSDKError.CryptoError"
    }
}
