//
//  APIClient.swift
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

protocol Client {
    var baseURL: String { get }
    func send<T: APIRequest>(_ request: T, handler: (Result<T.Response>) -> Void)
}

class Session: Client {
    
    let baseURL: String
    let session: URLSession
    let delegate: SessionDelegate
    
    init(configuration: LoginConfiguration) {
        baseURL = "https://\(configuration.APIHost)"
        delegate = SessionDelegate()
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: delegate, delegateQueue: nil)
    }
    
    func send<T: Request>(_ request: T, handler: (Result<T.Response>) -> Void) {
        
    }
    
    func create<T: Request>(_ request: T) -> URLRequest {
        let urlString = baseURL + request.path

        guard let url = URL(string: urlString) else {
            Log.fatalError("Cannot create correct URLRequest for url string: \(urlString)")
        }
        
        let urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        
        
        
        
        
        
        
        return urlRequest
    }
}

class SessionDelegate: NSObject {
    var requests: [Int: URLRequest] = [:]
}

extension SessionDelegate: URLSessionTaskDelegate {
    
}
