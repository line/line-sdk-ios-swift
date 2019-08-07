//
//  NotificationToken.swift
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

/// Wraps normal `Notification` observing method, to provide a behavior of releasing `token` automatically when
/// observer gets deinit.
class NotificationToken {
    let token: NSObjectProtocol
    let center: NotificationCenter
    
    init(token: NSObjectProtocol, in center: NotificationCenter) {
        self.token = token
        self.center = center
    }
    
    deinit {
        center.removeObserver(token)
    }
}

extension NotificationCenter {
    func addObserver(
        forName name: Notification.Name?,
        object obj: Any?,
        queue: OperationQueue?,
        using block: @escaping (Notification) -> Swift.Void) -> NotificationToken
    {
        let token: NSObjectProtocol = addObserver(forName: name, object: obj, queue: queue, using: block)
        return NotificationToken(token: token, in: self)
    }

}
