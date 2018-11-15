//
//  GetJWKSetRequestTests.swift
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

extension GetJWKSetRequest: ResponseDataStub {
    static let success = """
{"keys":[{"kty":"RSA","alg":"RS256","use":"sig","kid":"75724e7e200b4c6ca67c68580250ae3fb39afd36bfe1e0cccde76dc93f70ab2b","n":"APDmnDSCTmmbYiaHb4EzCXQNw86AdO6gaaKxK4o7G9fpa_rzR8xXERZvwz1PNqdM3kTphbGvpWwgAx0k9pWJX6vVnSWHknAZeO11rWLgPjYkFQPetVJHScVtVuMoBNJg4xlAj0BHVSBOquNEhIFAZomLX-HB6Xv1IFjxl3p4nNpVJzW0H8QG37K79C8yfn1SzFvYV-IlSoU_4CoFRL7RBx4av0MWNZCM43rYKMtDLO6rrxBe0DMRlYpcIbsRMh_ZRDREselJETRK4rH-KZZMt6Y3lWHguaRZxUxR2CBkET7LQ924TquvTIrIkVjmnXdW1_1EJGvaxyecHtC6rtQztx8","e":"AQAB"},{"kty":"RSA","alg":"RS256","use":"sig","kid":"1a1dd5ebedff5e8840d5958f2811bfae23ba2768d2ea482b0d815d29b6ead6c9","n":"AKLP6iVx_NOrijoYgOf9hhDRoG7eONhHCLlfgqALdKeWl4ZRkRJ4GyJJ2nUVbeyNV9jwd-Bac5fC8ilwjOmOITrK3UaRE5Hg4EmU2jOZ6Mj9EhjY9bTZq07Pa0ikS0qTS0-BGo7zgP9h-tgJvM9yuCjGGTLYbkNg1ZJmA6g4UGciOnVL1sRXJnV6gD_g5vtLtc1PwverKoMMMa6ELHNH5huICObFxxSJ8BA40Le4USPzeleAvWePs4EIfoJ5n9FD2Bytqm0lGqkVgJpJqH3n_I39Z_tVathDdJnyrmWW1_3-LlMhdc8YUJqVzGB73gQinUjocboF3MuDHRVsFaW27ak","e":"AQAB"},{"kty":"RSA","alg":"RS256","use":"sig","kid":"df26bfcda3629c19fa4c92da6b67527106b9754b279f4a59b91c9229719e30cc","n":"AIb6Got4QTOfot6gKbtbrtVaoVxtCuRjFOzBMNpBlF-2AQ21MHEuiMH5PuWB_-0sl8oa1mbIbtoaiCFXaM4t70IP7Gtv41YnvvA_PCRYKfNw5guM-cNBUpfJybjTTzmXy-JzyDJxeGo1d7dVwYbEOTh0Hixq0990yT4uhrXKsj4ch_2f0pv77u_8_iiXAhTVqbLjFCUeJl-pg8-9413mgb4hwrn8tNW8vFBMPy08yNV6Fl9vPiXRKRjbX0VlX1bJWNSLVa-jUb3XFXK6LcoretUB-s8ojojQl7-ZQYNsSmRtRvZCwxaKuIpjRR95wVQDUVe3XG9COo6Qd24wEgjX7k0","e":"AQAB"},{"kty":"EC","alg":"ES256","use":"sig","kid":"038513fc01804702e2670334007c8c8cbe744d4a8691b3f5bfe0f251dd2ca475","crv":"P-256","x":"GGERLwduXJpu_-Yizvypq5TlJS8VCOxoreD9J6DsZZs","y":"RLKGzm2JCHmixjsrKysjNKPym8-odN_HSY2rx72qZFM"}]}
"""
}

class GetJWKSetRequestTests: APITests {

    func testSuccess() {
        let r = GetJWKSetRequest(url: URL(string: "https://example.com")!)
        runTestSuccess(for: r) { result in
            XCTAssertEqual(result.keys.count, 4)
        }
    }
}
