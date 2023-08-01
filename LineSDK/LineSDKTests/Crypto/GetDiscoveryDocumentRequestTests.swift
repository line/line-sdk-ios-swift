//
//  GetDiscoveryDocumentRequestTests.swift
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

import XCTest
@testable import LineSDK

extension GetDiscoveryDocumentRequest: ResponseDataStub {
    static let success = """
    {
      "issuer": "https://access.line.me",
      "authorization_endpoint": "https://access.line.me/oauth2/v2.1/authorize",
      "token_endpoint": "https://api.line.me/oauth2/v2.1/token",
      "jwks_uri": "https://api.line.me/oauth2/v2.1/certs",
      "response_types_supported": [ "code" ],
      "subject_types_supported": [ "pairwise" ],
      "id_token_signing_alg_values_supported": [ "RS256" ]
    }
    """
}

class GetDiscoveryDocumentRequestTests: APITests {
    
    func testSuccess() {
        let r = GetDiscoveryDocumentRequest()
        runTestSuccess(for: r) { document in
            XCTAssertEqual(document.issuer, "https://access.line.me")
            XCTAssertEqual(document.jwksURI.absoluteString, "https://api.line.me/oauth2/v2.1/certs")
        }
    }

}
