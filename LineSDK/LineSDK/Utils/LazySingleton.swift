//
//  LazySingleton.swift
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

// Represents a singleton which needs to be lazily initiated and setup from outside.
protocol LazySingleton {
    associatedtype T
    static var _shared: T? { get set }
    static var shared: T { get set }
}

extension LazySingleton {
    public static var shared: T {
        get {
            guard let session = _shared else {
                Log.fatalError("Use \(T.self) before setup. Please call `LoginManager.setup` before you do any other things in LineSDK.")
            }
            return session
        }
        set {
            guard _shared == nil else {
                Log.fatalError("Trying to set \(T.self) multiplet times is not permitted.")
            }
            _shared = newValue
        }
    }
}
