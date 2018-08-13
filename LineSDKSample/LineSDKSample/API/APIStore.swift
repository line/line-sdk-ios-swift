//
//  APIStore.swift
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
import LineSDK

enum APICategory: Int {
    case auth
    case graph
    case messaging
    
    static let count = 3
}

class APIStore {
    static let shared = APIStore()
    
    private(set) var authAPIs: [APIItem] = []
    private(set) var graphAPIs: [APIItem] = []
    private(set) var messagingAPIs: [APIItem] = []
    
    private init() {
        refresh()
        let center = NotificationCenter.default
        center.addObserver(forName: .LineSDKAccessTokenDidUpdate , object: nil, queue: nil) { _ in
            self.refresh()
        }
        center.addObserver(forName: .LineSDKAccessTokenDidRemove , object: nil, queue: nil) { _ in
            self.refresh()
        }
    }
    
    func refresh() {
        authAPIs = [
            .init(
                title: "Get User Profile",
                request: GetUserProfileRequest()
            ),
            .init(
                title: "Verify Token",
                request: GetVerifyTokenRequest(accessToken: AccessTokenStore.shared.current?.value ?? ""),
                avaliable: AccessTokenStore.shared.current != nil
            )
        ]
        
        graphAPIs = [
            .init(title: "Get Friends" ,
                  request: GetFriendsRequest()
            )
        ]
        
        messagingAPIs = [
            
        ]
    }
    
    func numberOfAPIs(in category: APICategory) -> Int {
        switch category {
        case .auth: return authAPIs.count
        case .graph: return graphAPIs.count
        case .messaging: return messagingAPIs.count
        }
    }
    
    func api(in category: APICategory, at index: Int) -> APIItem {
        switch category {
        case .auth: return authAPIs[index]
        case .graph: return graphAPIs[index]
        case .messaging: return messagingAPIs[index]
        }
    }
}

struct APIItem {
    
    typealias AnyResultBlock = (@escaping (Result<Any>) -> Void) -> Void
    
    let block: AnyResultBlock
    
    let path: String
    let title: String
    
    let avaliable: Bool
    
    init<T: Request>(title: String, request: T, avaliable: Bool = true) {
        
        self.title = title
        self.path = request.path
        
        let block: AnyResultBlock = { handler in
            Session.shared.send(request) { result in handler(result.map { $0 as Any }) }
        }
        self.block = block
        self.avaliable = avaliable
    }
    
    func execute(handler: @escaping (Result<Any>) -> Void) -> Void {
        block(handler)
    }
}
