//
//  LineSDKErrorTests.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

import XCTest
@testable import LineSDK

class LineSDKErrorTests: XCTestCase {
    
    func testErrorClassifying() {
        let requestError = LineSDKError.requestFailed(reason: .missingURL)
        XCTAssertTrue(requestError.isRequestError)
        XCTAssertFalse(requestError.isResponseError)
        
        let responseError = LineSDKError.responseFailed(reason: .nonHTTPURLResponse)
        XCTAssertTrue(responseError.isResponseError)
        XCTAssertFalse(responseError.isAuthorizeError)
        
        let authError = LineSDKError.authorizeFailed(reason: .exhaustedLoginFlow)
        XCTAssertTrue(authError.isAuthorizeError)
        XCTAssertFalse(authError.isGeneralError)
        
        let generalError = LineSDKError.generalError(reason: .conversionError(string: "123", encoding: .utf8))
        XCTAssertTrue(generalError.isGeneralError)
        XCTAssertFalse(generalError.isRequestError)
        
    }
    
    func testUserCancelError() {
        let userCancelled = LineSDKError.authorizeFailed(reason: .userCancelled)
        let otherError = LineSDKError.authorizeFailed(reason: .exhaustedLoginFlow)
        
        XCTAssertTrue(userCancelled.isUserCancelled)
        XCTAssertFalse(otherError.isUserCancelled)
    }
    
    func testIsResponseError() {
        let err = APIError(InternalAPIError(message: "321"))
        let error = LineSDKError.responseFailed(reason: apiErrorReason(code: 123, error: err, rawString: "raw"))
        XCTAssertTrue(error.isResponseError(statusCode: 123))
        XCTAssertFalse(error.isResponseError(statusCode: 321))
    }

    func testURLSessionError() {
        let networkLostError = NSError(domain: NSURLErrorDomain, code: -1005, userInfo: nil)
        let error = LineSDKError.responseFailed(reason: .URLSessionError(networkLostError))
        XCTAssertTrue(error.isURLSessionErrorCode(sessionErrorCode: NSURLErrorNetworkConnectionLost))
    }
    
    func testIsBadRequest() {
        let err = APIError(InternalAPIError(message: "Bad request"))
        let error = LineSDKError.responseFailed(reason: apiErrorReason(code: 400, error: err, rawString: "raw"))
        XCTAssertTrue(error.isBadRequest)
    }
    
    func testIsPermission() {
        let err = APIError(InternalAPIError(message: "Not enough permission"))
        let error = LineSDKError.responseFailed(reason: apiErrorReason(code: 403, error: err, rawString: "raw"))
        XCTAssertTrue(error.isPermissionError)
    }
    
    func testIsTokenError() {
        let err = APIError(InternalAPIError(message: "The access token expired"))
        let error = LineSDKError.responseFailed(reason: apiErrorReason(code: 401, error: err, rawString: "raw"))
        XCTAssertTrue(error.isTokenError)
    }
    
    func testIsRefreshTokenError() {
        let err = APIError(InternalAPIError(message: "The refresh token expired"))
        let refresh = PostRefreshTokenRequest(channelID: "", refreshToken: "")
        let urlString = refresh.baseURL.appendingPathComponentIfNotEmpty(refresh).absoluteString
        let response = HTTPURLResponse.responseFromCode(400, urlString: urlString)
        let detail = LineSDKError.ResponseErrorReason.APIErrorDetail(
            code: 400, error: err, raw: response, rawString: "raw")
        
        let error = LineSDKError.responseFailed(reason: .invalidHTTPStatusAPIError(detail: detail))
        XCTAssertTrue(error.isRefreshTokenError)
    }
    
    func testErrorCode() {
        let error = LineSDKError.requestFailed(reason: .lackOfAccessToken)
        XCTAssertEqual(error.errorCode, 1002)
    }

    func testAuthorizeErrorReasonDescription() {
        let authReasons: [LineSDKError.AuthorizeErrorReason] = [
            .exhaustedLoginFlow,
            .malformedHierarchy,
            .userCancelled,
            .forceStopped,
            .callbackURLSchemeNotMatching,
            .invalidSourceApplication,
            .malformedRedirectURL(url: URL(string: "https://example.com")!, message: nil),
            .invalidLineURLResultCode("error"),
            .lineClientError(code: "error", message: nil),
            .responseStateValueNotMatching(expected: "123", got: "456"),
            .webLoginError(error: "error", description: nil),
            .keychainOperation(status: 1),
            .invalidDataInKeychain,
            .lackOfIDToken(raw: nil),
            .JWTPublicKeyNotFound(keyID: "test"),
            .cryptoError(error: .JWKFailed(reason: .unsupportedKeyType("")))
        ]
        for reason in authReasons {
            XCTAssertNotNil(reason.errorDescription)
            XCTAssertFalse(reason.errorDescription!.isEmpty)
        }
    }

    func testRequestErrorReasonDescription() {
        let requestReasons: [LineSDKError.RequestErrorReason] = [
            .missingURL,
            .lackOfAccessToken,
            .jsonEncodingFailed(NSError(domain: "TestDomain", code: 1, userInfo: nil)),
            .invalidParameter([.invalidEntityID("p", value: "v")]),
        ]
        for reason in requestReasons {
            XCTAssertNotNil(reason.errorDescription)
            XCTAssertFalse(reason.errorDescription!.isEmpty)

            if case .jsonEncodingFailed(let error) = reason {
                XCTAssertFalse(reason.errorUserInfo.isEmpty)

                let errorInUserInfo = reason.errorUserInfo[LineSDKErrorUserInfoKey.underlyingError.rawValue] as? NSError
                XCTAssertNotNil(errorInUserInfo)
                XCTAssertEqual(error as NSError, errorInUserInfo)
            } else {
                XCTAssertTrue(reason.errorUserInfo.isEmpty)
            }
        }
    }

    func testResponseErrorReasonDescription() {
        let responseReasons: [LineSDKError.ResponseErrorReason] = [
            .URLSessionError(NSError(domain: NSURLErrorDomain, code: NSURLErrorNetworkConnectionLost)),
            .nonHTTPURLResponse,
            .dataParsingFailed(String.self, Data(), nil),
            .invalidHTTPStatusAPIError(detail: LineSDKError.ResponseErrorReason.APIErrorDetail(
                code: 400, error: APIError(InternalAPIError(message: "Bad Request")),
                raw: HTTPURLResponse.responseFromCode(400), rawString: "raw")),
        ]
        for reason in responseReasons {
            XCTAssertNotNil(reason.errorDescription)
            XCTAssertFalse(reason.errorDescription!.isEmpty)
        }
    }

    @MainActor
    func testGeneralErrorReasonDescription() {

        LoginManager.shared.setup(channelID: "123", universalLinkURL: nil)
        defer {
            LoginManager.shared.reset()
        }

        let generalReasons: [LineSDKError.GeneralErrorReason] = [
            .conversionError(string: "", encoding: .utf8),
            .parameterError(parameterName: "", description: ""),
            .notOriginalTask(token: 1),
            .processDiscarded(.init(configuration: .shared, scopes: [], parameters: .init(), viewController: nil)),
        ]
        for reason in generalReasons {
            XCTAssertNotNil(reason.errorDescription)
            XCTAssertFalse(reason.errorDescription!.isEmpty)
        }
    }
    
    func testCryptoErrorAlgorithmsErrorReason() {
        let testData = Data([1, 2, 3, 4])
        let testError = NSError(domain: "TestDomain", code: 1001, userInfo: nil)
        
        let algorithmReasons: [CryptoError.AlgorithmsErrorReason] = [
            .invalidDERKey(data: testData, reason: "test reason"),
            .invalidX509Header(data: testData, index: 10, reason: "x509 test"),
            .createKeyFailed(data: testData, reason: "key creation failed"),
            .invalidPEMKey(string: "invalid-pem", reason: "pem test"),
            .encryptingError(testError),
            .encryptingError(nil),
            .decryptingError(testError),
            .decryptingError(nil),
            .signingError(testError),
            .signingError(nil),
            .verifyingError(testError, statusCode: 401),
            .verifyingError(nil, statusCode: nil),
            .invalidSignature(data: testData)
        ]
        
        for reason in algorithmReasons {
            XCTAssertNotNil(reason.errorDescription)
            XCTAssertFalse(reason.errorDescription!.isEmpty)
            
            let userInfo = reason.errorUserInfo
            
            switch reason {
            case .invalidDERKey(let data, _):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.data.rawValue] as? Data, data)
                XCTAssertEqual(reason.errorCode, 3016_1001)
            case .invalidX509Header(let data, let index, _):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.data.rawValue] as? Data, data)
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.index.rawValue] as? Int, index)
                XCTAssertEqual(reason.errorCode, 3016_1002)
            case .createKeyFailed(let data, _):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.data.rawValue] as? Data, data)
                XCTAssertEqual(reason.errorCode, 3016_1003)
            case .invalidPEMKey(let string, _):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.data.rawValue] as? String, string)
                XCTAssertEqual(reason.errorCode, 3016_1004)
            case .encryptingError(let error):
                if error != nil {
                    XCTAssertNotNil(userInfo[LineSDKErrorUserInfoKey.underlyingError.rawValue])
                } else {
                    XCTAssertNil(userInfo[LineSDKErrorUserInfoKey.underlyingError.rawValue])
                }
                XCTAssertEqual(reason.errorCode, 3016_1005)
            case .decryptingError(let error):
                if error != nil {
                    XCTAssertNotNil(userInfo[LineSDKErrorUserInfoKey.underlyingError.rawValue])
                } else {
                    XCTAssertNil(userInfo[LineSDKErrorUserInfoKey.underlyingError.rawValue])
                }
                XCTAssertEqual(reason.errorCode, 3016_1006)
            case .signingError(let error):
                if error != nil {
                    XCTAssertNotNil(userInfo[LineSDKErrorUserInfoKey.underlyingError.rawValue])
                } else {
                    XCTAssertNil(userInfo[LineSDKErrorUserInfoKey.underlyingError.rawValue])
                }
                XCTAssertEqual(reason.errorCode, 3016_1007)
            case .verifyingError(let error, let statusCode):
                if error != nil {
                    XCTAssertNotNil(userInfo[LineSDKErrorUserInfoKey.underlyingError.rawValue])
                } else {
                    XCTAssertNil(userInfo[LineSDKErrorUserInfoKey.underlyingError.rawValue])
                }
                if let statusCode = statusCode {
                    XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.statusCode.rawValue] as? Int, statusCode)
                } else {
                    XCTAssertNil(userInfo[LineSDKErrorUserInfoKey.statusCode.rawValue])
                }
                XCTAssertEqual(reason.errorCode, 3016_1008)
            case .invalidSignature(let data):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.data.rawValue] as? Data, data)
                XCTAssertEqual(reason.errorCode, 3016_1009)
            }
        }
    }
    
    func testCryptoErrorJWTErrorReason() {
        let jwtReasons: [CryptoError.JWTErrorReason] = [
            .malformedJWTFormat(string: "invalid-jwt"),
            .unsupportedHeaderAlgorithm(name: "HS512"),
            .claimVerifyingFailed(key: "iss", got: "wrong-issuer", description: "issuer mismatch")
        ]
        
        for reason in jwtReasons {
            XCTAssertNotNil(reason.errorDescription)
            XCTAssertFalse(reason.errorDescription!.isEmpty)
            
            let userInfo = reason.errorUserInfo
            
            switch reason {
            case .malformedJWTFormat(let string):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.text.rawValue] as? String, string)
                XCTAssertEqual(reason.errorCode, 3016_2001)
            case .unsupportedHeaderAlgorithm(let name):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.raw.rawValue] as? String, name)
                XCTAssertEqual(reason.errorCode, 3016_2002)
            case .claimVerifyingFailed(let key, let got, _):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.key.rawValue] as? String, key)
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.got.rawValue] as? String, got)
                XCTAssertEqual(reason.errorCode, 3016_2003)
            }
        }
    }
    
    func testCryptoErrorJWKErrorReason() {
        let jwkReasons: [CryptoError.JWKErrorReason] = [
            .unsupportedKeyType("EC-P521")
        ]
        
        for reason in jwkReasons {
            XCTAssertNotNil(reason.errorDescription)
            XCTAssertFalse(reason.errorDescription!.isEmpty)
            
            let userInfo = reason.errorUserInfo
            
            switch reason {
            case .unsupportedKeyType(let keyType):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.raw.rawValue] as? String, keyType)
                XCTAssertEqual(reason.errorCode, 3016_3001)
            }
        }
    }
    
    func testCryptoErrorGeneralErrorReason() {
        let testData = Data([5, 6, 7, 8])
        
        let generalReasons: [CryptoError.GeneralErrorReason] = [
            .base64ConversionFailed(string: "invalid-base64"),
            .dataConversionFailed(data: testData, encoding: .utf8),
            .stringConversionFailed(string: "test-string", encoding: .ascii),
            .operationNotSupported(reason: "iOS version too old"),
            .decodingFailed(string: "invalid-json", type: [String: Any].self)
        ]
        
        for reason in generalReasons {
            XCTAssertNotNil(reason.errorDescription)
            XCTAssertFalse(reason.errorDescription!.isEmpty)
            
            let userInfo = reason.errorUserInfo
            
            switch reason {
            case .base64ConversionFailed(let string):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.text.rawValue] as? String, string)
                XCTAssertEqual(reason.errorCode, 3016_4001)
            case .dataConversionFailed(let data, let encoding):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.data.rawValue] as? Data, data)
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.encoding.rawValue] as? String.Encoding, encoding)
                XCTAssertEqual(reason.errorCode, 3016_4002)
            case .stringConversionFailed(let string, let encoding):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.text.rawValue] as? String, string)
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.encoding.rawValue] as? String.Encoding, encoding)
                XCTAssertEqual(reason.errorCode, 3016_4003)
            case .operationNotSupported(_):
                XCTAssertTrue(userInfo.isEmpty)
                XCTAssertEqual(reason.errorCode, 3016_4004)
            case .decodingFailed(let string, _):
                XCTAssertEqual(userInfo[LineSDKErrorUserInfoKey.raw.rawValue] as? String, string)
                XCTAssertNotNil(userInfo[LineSDKErrorUserInfoKey.type.rawValue])
                XCTAssertEqual(reason.errorCode, 3016_4005)
            }
        }
    }
    
    func testCryptoErrorMain() {
        let testData = Data([1, 2, 3])
        let testError = NSError(domain: "TestDomain", code: 500, userInfo: nil)
        
        let cryptoErrors: [CryptoError] = [
            .algorithmsFailed(reason: .invalidDERKey(data: testData, reason: "test")),
            .algorithmsFailed(reason: .encryptingError(testError)),
            .JWTFailed(reason: .malformedJWTFormat(string: "invalid")),
            .JWTFailed(reason: .unsupportedHeaderAlgorithm(name: "RS512")),
            .JWKFailed(reason: .unsupportedKeyType("EC-P256")),
            .generalError(reason: .base64ConversionFailed(string: "invalid-base64"))
        ]
        
        for error in cryptoErrors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
            
            XCTAssertEqual(CryptoError.errorDomain, "LineSDKError.CryptoError")
            
            let userInfo = error.errorUserInfo
            XCTAssertFalse(userInfo.isEmpty)
            
            switch error {
            case .algorithmsFailed(let reason):
                XCTAssertEqual(error.errorCode, reason.errorCode)
            case .JWTFailed(let reason):
                XCTAssertEqual(error.errorCode, reason.errorCode)
            case .JWKFailed(let reason):
                XCTAssertEqual(error.errorCode, reason.errorCode)
            case .generalError(let reason):
                XCTAssertEqual(error.errorCode, reason.errorCode)
            }
        }
    }
}

func apiErrorReason(code: Int, error: APIError, rawString: String) -> LineSDKError.ResponseErrorReason {
    let response = HTTPURLResponse.responseFromCode(code)
    let detail = LineSDKError.ResponseErrorReason.APIErrorDetail(
        code: code, error: error, raw: response, rawString: rawString)
    return .invalidHTTPStatusAPIError(detail: detail)
}
