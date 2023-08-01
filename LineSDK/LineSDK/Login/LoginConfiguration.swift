//
//  LoginConfiguration.swift
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

struct LoginConfiguration {

    static var _shared: LoginConfiguration?
    static var shared: LoginConfiguration {
        return guardSharedProperty(_shared)
    }

    let channelID: String
    let universalLinkURL: URL?

    init(channelID: String, universalLinkURL: URL?) {
        self.channelID = channelID

        if let url = universalLinkURL, url.scheme?.lowercased() != "https" {
            Log.assertionFailure("Universal link is required to start with https scheme.")
        }

        self.universalLinkURL = universalLinkURL
    }

    /// Whether a `url` is a valid customize URL scheme of current app.
    ///
    /// - Parameter url: The input URL from LINE or web login flow.
    /// - Returns: `true` if the `url` is a valid app URL scheme for current app. Otherwise, `false`.
    func isValidCustomizeURL(url: URL) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }
        guard scheme.lowercased() == Constant.thirdPartyAppReturnScheme.lowercased() else {
            return false
        }
        guard url.host?.lowercased() == "authorize" else {
            return false
        }
        return true

    }

    /// Compares `url` with current set `universalLinkURL`, to check whether `url` is a valid universal URL or not.
    ///
    /// - Parameter url: The input URL from LINE or web login flow.
    /// - Returns: `true` if the `url` is a valid app universal link for current app. Otherwise, `false`.
    func isValidUniversalLinkURL(url: URL) -> Bool {

        guard let setURL = universalLinkURL else {
            return false
        }

        guard setURL.scheme?.lowercased() == url.scheme?.lowercased() else {
            return false
        }

        guard setURL.host?.lowercased() == url.host?.lowercased() else {
            return false
        }

        guard setURL.path.lowercased() == url.path.lowercased() else {
            return false
        }

        return true
    }
}
