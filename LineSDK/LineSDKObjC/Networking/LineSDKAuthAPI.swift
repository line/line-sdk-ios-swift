//
//  LineSDKAuthAPI.swift
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

@objcMembers
public class LineSDKAuthAPI: NSObject {
    // MARK: - refreshAccessToken
    public static func refreshAccessToken(
        completionHandler completion: @escaping @Sendable (LineSDKAccessToken?, Error?) -> Void
    )
    {
        refreshAccessToken(callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func refreshAccessToken(
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping @Sendable (LineSDKAccessToken?, Error?) -> Void
    )
    {
        API.Auth.refreshAccessToken(callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKAccessToken.init).match(with: completion)
        }
    }
    
    // MARK: - revokeAccessToken
    public static func revokeAccessToken(
        completionHandler completion: @escaping @Sendable (Error?) -> Void
    )
    {
        revokeAccessToken(nil, completionHandler: completion)
    }
    
    public static func revokeAccessToken(
        _ token: String?,
        completionHandler completion: @escaping @Sendable (Error?) -> Void
    )
    {
        revokeAccessToken(token, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func revokeAccessToken(
        _ token: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping @Sendable (Error?) -> Void
    )
    {
        API.Auth.revokeAccessToken(token, callbackQueue: queue.unwrapped) { result in
            result.matchFailure(with: completion)
        }
    }
    
    // MARK: - revokeRefreshToken
    public static func revokeRefreshToken(
        completionHandler completion: @escaping @Sendable (Error?) -> Void
    )
    {
        revokeRefreshToken(nil, completionHandler: completion)
    }
    
    public static func revokeRefreshToken(
        _ token: String?,
        completionHandler completion: @escaping @Sendable (Error?) -> Void
    )
    {
        revokeRefreshToken(token, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func revokeRefreshToken(
        _ token: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping @Sendable (Error?) -> Void
    )
    {
        API.Auth.revokeRefreshToken(token, callbackQueue: queue.unwrapped) { result in
            result.matchFailure(with: completion)
        }
    }
    
    // MARK: - verifyAccessToken
    public static func verifyAccessToken(
        completionHandler completion: @escaping @Sendable (LineSDKAccessTokenVerifyResult?, Error?) -> Void)
    {
        verifyAccessToken(nil, completionHandler: completion)
    }
    
    public static func verifyAccessToken(
        _ token: String?,
        completionHandler completion: @escaping @Sendable (LineSDKAccessTokenVerifyResult?, Error?) -> Void)
    {
        verifyAccessToken(token, callbackQueue: .currentMainOrAsync, completionHandler: completion)
    }
    
    public static func verifyAccessToken(
        _ token: String?,
        callbackQueue queue: LineSDKCallbackQueue,
        completionHandler completion: @escaping @Sendable (LineSDKAccessTokenVerifyResult?, Error?) -> Void)
    {
        API.Auth.verifyAccessToken(token, callbackQueue: queue.unwrapped) { result in
            result.map(LineSDKAccessTokenVerifyResult.init).match(with: completion)
        }
    }
}
