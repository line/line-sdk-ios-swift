//
//  CallbackQueue.swift
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

/// Callback queue behaviors when a closure call is dispatched.
///
/// - asyncMain: Dispatches a call to `DispatchQueue.main` with the `async` behavior.
/// - currentMainOrAsync: Dispatches a call to `DispatchQueue.main` with the `async` behavior if
///                       the current queue is not `.main`. Otherwise, calls a closure immediately in the main
///                       queue.
/// - untouch: Does not change a call queue for a closure.
/// - dispatch: Dispatches a call to a specified `DispatchQueue` object.
/// - operation: Uses a specified `OperationQueue` object and adds a closure to the operation queue.
public enum CallbackQueue {

    /// Dispatches a call to `DispatchQueue.main` with the `async` behavior.
    case asyncMain

    /// Dispatches a call to `DispatchQueue.main` with the `async` behavior if
    /// the current queue is not `.main`. Otherwise, calls a closure immediately in the main queue.
    case currentMainOrAsync

    /// Does not change a call queue for a closure.
    case untouch

    /// Dispatches a call to a specified `DispatchQueue` object.
    case dispatch(DispatchQueue)

    /// Uses a specified `OperationQueue` object and adds a closure to the operation queue.
    case operation(OperationQueue)
    
    func execute(_ block: @escaping () -> Void) {
        switch self {
        case .asyncMain:
            DispatchQueue.main.async { block() }
        case .currentMainOrAsync:
            DispatchQueue.main.safeAsync { block() }
        case .untouch:
            block()
        case .dispatch(let queue):
            queue.async { block() }
        case .operation(let queue):
            queue.addOperation { block() }
        }
    }
}

extension DispatchQueue {
    // This method will dispatch the `block` to self.
    // If `self` is the main queue, and current thread is main thread, the block
    // will be invoked immediately instead of being dispatched.
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
