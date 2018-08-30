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
}
