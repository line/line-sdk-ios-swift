//
//  ShareTarget.swift
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

public protocol ShareTarget {
    var targetID: String { get }
    var displayName: String { get }
    var avatarURL: URL? { get }
}

extension User: ShareTarget {
    public var targetID: String { return userID }
    public var avatarURL: URL? { return pictureURLSmall }
}

extension Group: ShareTarget {
    public var targetID: String { return groupID }
    public var displayName: String { return groupName }
    public var avatarURL: URL? { return pictureURLSmall }
}

extension ShareTarget {
    func placeholderImage() -> UIImage? {
        let value = displayName.count % 4 + 1
        return UIImage(named: "unknown_user_small_0\(value)", in: .frameworkBundle, compatibleWith: nil)
    }
}
