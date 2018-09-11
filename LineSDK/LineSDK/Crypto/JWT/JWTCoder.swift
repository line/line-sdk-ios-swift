//
//  JWTCoder.swift
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

// A customize JSON decoder to decode from base64URL strings.
class Base64JSONDecoder: JSONDecoder {
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let string = String(data: data, encoding: .ascii) else {
            throw CryptoError.generalError(reason: .dataConversionFailed(data: data, encoding: .ascii))
        }
        
        return try decode(type, from: string)
    }
    
    func decode<T>(_ type: T.Type, from string: String) throws -> T where T : Decodable {
        guard let decodedData = string.base64URLDecoded else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: string))
        }
        return try super.decode(type, from: decodedData)
    }
    
    func decodeDictionary(_ string: String) throws -> [String: Any] {
        guard let decodedData = string.base64URLDecoded else {
            throw CryptoError.generalError(reason: .base64ConversionFailed(string: string))
        }
        guard let result = try JSONSerialization.jsonObject(with: decodedData) as? [String: Any] else {
            throw CryptoError.generalError(
                reason: .decodingFailed(string: String(data: decodedData, encoding: .utf8)!, type: [String: Any].self))
        }
        return result
    }
}
