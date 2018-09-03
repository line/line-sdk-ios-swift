//
//  JWT.swift
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

struct JWT {
    let header: Header
    let payload: Payload
    let signature: Signature
    
    init(data: Data) throws {
        guard let text = String(data: data, encoding: .utf8) else {
            throw CryptoError.generalError(reason: .dataConversionFailed(data: data, encoding: .utf8))
        }
        let components = text.components(separatedBy: ".")
        guard components.count == 3 else {
            throw CryptoError.JWTFailed(reason: .malformedJWTFormat(string: text))
        }
        header = Header(raw: components[0])
        payload = Payload(raw: components[1])
        signature = Signature(raw: components[2])
    }
}

extension JWT {
    var plainSegment: String {
        return "\(header.raw).\(payload.raw)"
    }
    
}

extension JWT {
    struct Header: Codable {
        let raw: String
        
//        let algorithm: String?
//        let 
//        
//        enum CodingKeys: String, CodingKey {
//            case
//        }
//        
//        public init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            
//        }
        
    }
}

extension JWT {
    struct Payload {
        let raw: String
    }
}

extension JWT.Payload {
    struct Claim {
        let key: String
        let value: String
    }
}

extension JWT {
    struct Signature {
        let raw: String
    }
}
