//
//  PostOpenChatCreateRequest.swift
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

public struct PostOpenChatCreateRequest: Request {
    
    public struct Response: Decodable {
        public let squareMid: String
        public let url: URL
    }
    
    public struct Parameter: Encodable {
        // length <= 50
        public var name: String
        // length <= 200
        public var description: String
        // length <= 50
        public var creatorDisplayName: String
        public var category: Int
        public var allowSearch: Bool = true
        
        public init(
            name: String,
            description: String,
            creatorDisplayName: String,
            category: OpenChatCategory,
            allowSearch: Bool
        )
        {
            self.name = name
            self.description = description
            self.creatorDisplayName = creatorDisplayName
            self.category = category.rawValue
            self.allowSearch = allowSearch
        }
    }
    
    public let method: HTTPMethod = .post
    public let path = "/square/v1/square"
    public let authentication: AuthenticateMethod = .token
    
    public let parameter: Parameter
    
    public init(parameter: Parameter) {
        self.parameter = parameter
    }
    
    public var parameters: Parameters? {
        return [
            "name": parameter.name,
            "description": parameter.description,
            "creatorDisplayName": parameter.creatorDisplayName,
            "category": parameter.category,
            "allowSearch": parameter.allowSearch
        ]
    }
}
