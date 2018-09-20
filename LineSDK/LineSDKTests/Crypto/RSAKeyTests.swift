//
//  RSAKeyTests.swift
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

let rsaBundle = Bundle(for: RSATests.self)
func getFileURL(forResource name: String, ofType type: String) -> URL {
    guard let path = rsaBundle.path(forResource: name, ofType: type) else {
        fatalError("Cannot find resource in test bundle: \(name).\(type).")
    }
    return URL(fileURLWithPath: path)
}

class RSAKeyTests: XCTestCase {

    func testCreatingKeyFromBase64() {
        let path = getFileURL(forResource: "public_base_64", ofType: "")
        let text = try! String(contentsOf: path)
        do {
            _ = try Crypto.RSAPublicKey(base64Encoded: text)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCreatingKeyFromBase64WithNewLine() {
        let path = getFileURL(forResource: "public_base_64_newline", ofType: "")
        let text = try! String(contentsOf: path)
        do {
            _ = try Crypto.RSAPublicKey(base64Encoded: text)
        } catch {
            XCTFail("\(error)")
        }
    }
        
    func testCreatingKeyFromBase64WithHeader() {
        let path = getFileURL(forResource: "public_base_64_header", ofType: "")
        let text = try! String(contentsOf: path)
        do {
            _ = try Crypto.RSAPublicKey(pem: text)
        } catch {
            XCTFail("\(error)")
        }
    }
    
    func testCreatingKeyFromPEM() {
        let path = getFileURL(forResource: "public", ofType: "pem")
        let text = try! String(contentsOf: path)
        do {
            _ = try Crypto.RSAPublicKey(pem: text)
        }  catch {
            XCTFail("\(error)")
        }
    }
    
    func testCreatingRSAPublicKeyFromDERData() {
        let path = getFileURL(forResource: "public", ofType: "der")
        let data = try! Data(contentsOf: path)
        do {
            _ = try Crypto.RSAPublicKey(der: data)
        }  catch {
            XCTFail("\(error)")
        }
    }

    func testCreatingPrivateKeyFromDERData() {
        let path = getFileURL(forResource: "private", ofType: "der")
        let data = try! Data(contentsOf: path)
        do {
            _ = try Crypto.RSAPrivateKey(der: data)
        }  catch {
            XCTFail("\(error)")
        }
    }
    
    func testCreatingRSAPublicKeyFromCertificate() {
        let path = getFileURL(forResource: "test_public", ofType: "cer")
        let data = try! Data(contentsOf: path)
        do {
            _ = try Crypto.RSAPublicKey(certificate: data)
        }  catch {
            XCTFail("\(error)")
        }
    }
}
