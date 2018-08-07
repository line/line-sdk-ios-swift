//
//  Result.swift
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

/// Represents a result of some operation, whether it is successful or an error happens.
///
/// - success: The operation is successful and an associated value could be provided.
/// - failure: An error happens during the operation.
public enum Result<Value> {
    case success(Value)
    case failure(Error)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        if case .success(let v) = self {
            return v
        }
        return nil
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var failure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        if case .failure(let e) = self {
            return e
        }
        return nil
    }
    
    /// Map over the `Result` value. If it was a `.success`, `transform` closure will be applied to associated value
    /// and a new `.success` with transformed value will be returned. If it was a `.failure`, the same error will be
    /// returned.
    ///
    /// - Parameter transform: A closure that takes the success value of the instance.
    /// - Returns: A `Result` containing the result of the given closure. If this instance is a failure, returns the
    ///            same failure.
    public func map<T>(_ transform: (Value) -> T) -> Result<T> {
        switch self {
        case .success(let value): return .success(transform(value))
        case .failure(let error): return .failure(error)
        }
    }
}
