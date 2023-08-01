//
//  JWKSet.swift
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

/// A JSON object that represents a set of JWKs.
struct JWKSet: Decodable {
    
    struct Dummy: Decodable {}
    
    let keys: [JWK]
    
    enum CodingKeys: String, CodingKey {
        case keys
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var nestedContainer = try container.nestedUnkeyedContainer(forKey: .keys)
        var supportedKeys = [JWK]()
        while !nestedContainer.isAtEnd {
            do {
                let key = try nestedContainer.decode(JWK.self)
                supportedKeys.append(key)
            } catch {
                // Failing decoding will not increase container's currentIndex. Let it decode successfully.
                _ = try nestedContainer.decode(Dummy.self)
                Log.print("\(error)")
            }
        }
        keys = supportedKeys
    }
    
    func getKeyByID(_ keyID: String) -> JWK? {
        return keys.first { $0.keyID == keyID }
    }
}
