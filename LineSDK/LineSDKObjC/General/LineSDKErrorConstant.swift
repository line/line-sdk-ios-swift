//
//  LineSDKErrorConstant.swift
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
#if !LineSDKCocoaPods && !LineSDKBinary
import LineSDK
#endif

@objcMembers
public class LineSDKErrorConstant: NSObject {
    public static let errorDomain = LineSDKError.errorDomain
    public static let cryptoErrorDomain = CryptoError.errorDomain
    
    public static let userInfoKeyUnderlyingError = LineSDKErrorUserInfoKey.underlyingError.rawValue
    public static let userInfoKeyStatusCode = LineSDKErrorUserInfoKey.statusCode.rawValue
    public static let userInfoKeyResultCode = LineSDKErrorUserInfoKey.resultCode.rawValue
    public static let userInfoKeyType = LineSDKErrorUserInfoKey.type.rawValue
    public static let userInfoKeyData = LineSDKErrorUserInfoKey.data.rawValue
    public static let userInfoKeyAPIError = LineSDKErrorUserInfoKey.APIError.rawValue
    public static let userInfoKeyRaw = LineSDKErrorUserInfoKey.raw.rawValue
    public static let userInfoKeyUrl = LineSDKErrorUserInfoKey.url.rawValue
    public static let userInfoKeyMessage = LineSDKErrorUserInfoKey.message.rawValue
    public static let userInfoKeyStatus = LineSDKErrorUserInfoKey.status.rawValue
    public static let userInfoKeyText = LineSDKErrorUserInfoKey.text.rawValue
    public static let userInfoKeyEncoding = LineSDKErrorUserInfoKey.encoding.rawValue
    public static let userInfoKeyParameterName = LineSDKErrorUserInfoKey.parameterName.rawValue
    public static let userInfoKeyReason = LineSDKErrorUserInfoKey.reason.rawValue
    public static let userInfoKeyIndex = LineSDKErrorUserInfoKey.index.rawValue
    public static let userInfoKeyKey = LineSDKErrorUserInfoKey.key.rawValue
    public static let userInfoKeyGot = LineSDKErrorUserInfoKey.got.rawValue
}
