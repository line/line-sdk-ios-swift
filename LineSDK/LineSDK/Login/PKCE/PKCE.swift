//
//  PKCE.swift
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

struct PKCE {

    /// If the client is capable of using "S256", it MUST use "S256", as
    /// "S256" is Mandatory To Implement (MTI) on the server.
    /// Ref: https://tools.ietf.org/html/rfc7636#section-4.2
    let codeChallengeMethod = "S256"

    /// Code Verifier
    /// The code verifier SHOULD have enough entropy to make it
    /// impractical to guess the value.  It is RECOMMENDED that the output of
    /// a suitable random number generator be used to create a 32-octet
    /// sequence. The octet sequence is then base64url-encoded to produce a
    /// 43-octet URL safe string to use as the code verifier.
    ///
    /// Ref: https://tools.ietf.org/html/rfc7636#section-4.1
    let codeVerifier: String
    
    /// Code Challenge
    /// The client creates a code challenge derived from the code verifier by using S256 transformations
    /// code_challenge = BASE64URL-ENCODE(SHA256(ASCII(code_verifier)))
    ///
    /// Ref: https://tools.ietf.org/html/rfc7636#section-4.2
    ///
    var codeChallenge: String {
        return PKCE.generateCodeChallenge(codeVerifier: codeVerifier)
    }

    init() {
        codeVerifier = Data.randomData(bytesCount: 32).base64URLEncoded
    }

    static func generateCodeChallenge(codeVerifier: String) -> String {
        guard let codeVerifierData = codeVerifier.data(using: .ascii) else {
            preconditionFailure("Invalid codeVerifier parameter")
        }
        return codeVerifierData.digest(using: .sha256).base64URLEncoded
    }
}
