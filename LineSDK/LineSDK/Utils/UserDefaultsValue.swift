//
//  UserDefaultsValue.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

enum UserDefaultsValue {
    
    nonisolated(unsafe) private static let defaults = UserDefaults.standard

    private static let cachedUserProfileNameKey = "com.linecorp.sdk.cachedOpenChatUserProfileName"
    static var cachedOpenChatUserProfileName: String? {
        set {
            if let name = newValue {
                defaults.set(name, forKey: cachedUserProfileNameKey)
            } else {
                defaults.removeObject(forKey: cachedUserProfileNameKey)
            }
        }
        get {
            return defaults.string(forKey: cachedUserProfileNameKey)
        }
    }
    
    static func clear() {
        cachedOpenChatUserProfileName = nil
    }
}
