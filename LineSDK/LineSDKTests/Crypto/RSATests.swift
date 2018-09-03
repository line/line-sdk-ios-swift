//
//  RSATests.swift
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

class RSATests: XCTestCase {
    
    func testInitRSAData() {
        let text = "hello"
        
        let data = text.data(using: .utf8)!

        let data1 = RSA.PlainData(raw: data)
        let data2 = try! RSA.PlainData(base64Encoded: data.base64EncodedString())
        let data3 = try! RSA.PlainData(string: text)
        
        XCTAssertEqual(data1, data2)
        XCTAssertEqual(data2, data3)
    }
    
    func testSign() {
        let privateKeyPath = getFileURL(forResource: "test_private", ofType: "pem")
        let privateKey = try! RSA.PrivateKey(pem: try! String(contentsOf: privateKeyPath))
        
        let publicKeyPath = getFileURL(forResource: "test_public", ofType: "cer")
        let publicKey = try! RSA.PublicKey(certificate: try! Data(contentsOf: publicKeyPath))
        
        let data = "hello".data(using: .utf8)!
        let plainData = RSA.PlainData(raw: data)
        do {
            let signedData = try plainData.signed(with: privateKey, algorithm: .sha256)
            let plainData = RSA.PlainData(raw: data)
            
            let result = try plainData.verify(with: publicKey, signature: signedData, algorithm: .sha256)
            
            let malformedData = "world".data(using: .utf8)!
            let wrong = try? RSA.PlainData(raw: malformedData)
                            .verify(with: publicKey, signature: signedData, algorithm: .sha256)
            
            XCTAssertTrue(result)
            XCTAssertNil(wrong)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testEncrypt() {
        let privateKeyPath = getFileURL(forResource: "test_private", ofType: "pem")
        let privateKey = try! RSA.PrivateKey(pem: try! String(contentsOf: privateKeyPath))
        
        let publicKeyPath = getFileURL(forResource: "test_public", ofType: "cer")
        let publicKey = try! RSA.PublicKey(certificate: try! Data(contentsOf: publicKeyPath))
        
        let data = "hello".data(using: .utf8)!
        let plainData = RSA.PlainData(raw: data)
        
        let encrypted = try! plainData.encrypted(with: publicKey, using: .sha512)
        let decrypted = try! encrypted.decrypted(with: privateKey, using: .sha512)
        
        let result = String(data: decrypted.raw, encoding: .utf8)
        XCTAssertEqual(result, "hello")
    }
    
    func testVerify() {
        let publicKey = try! RSA.PublicKey(pem: """
            -----BEGIN PUBLIC KEY-----
            MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDdlatRjRjogo3WojgGHFHYLugd
            UWAY9iR3fy4arWNA1KoS8kVw33cJibXr8bvwUAUparCwlvdbH6dvEOfou0/gCFQs
            HUfQrSDv+MuSUMAe8jzKE4qW+jK+xQU9a03GUnKHkkle+Q0pX/g6jXZ7r1/xAK5D
            o2kQ+X5xK9cipRgEKwIDAQAB
            -----END PUBLIC KEY-----
            """)
        
        let plainData = try! RSA.PlainData(
            string: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiw" +
                    "ibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0")
        
        let signed = try! RSA.SignedData(
            base64Encoded: "TCYt5XsITJX1CxPCT8yAV+TVkIEq/PbChOMqsLfRoPsnsgw5WEuts01mq+pQy7UJiN5mgRx" +
                           "D+WUcX16dUEMGlv50aqzpqh4Qktb3rk+BuQy72IFLOqV0G/zS245+kronKb78cPN25DGlcT" +
                           "wLtjPAYuNzVBAh4vGHSrQyHUdBBPM=")
        do {
            let result = try plainData.verify(with: publicKey, signature: signed, algorithm: .sha256)
            XCTAssertTrue(result)
        } catch {
            XCTFail("\(error)")
        }
        
    }
}
