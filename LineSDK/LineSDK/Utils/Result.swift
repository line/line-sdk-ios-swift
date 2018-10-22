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

/// The possible results of an operation, whether it is successful or not.
///
/// - success: The operation is successful and an associated value is available.
/// - failure: The operation is failed and an associated error is available.
public enum Result<Value, Error: Swift.Error>: CustomStringConvertible, CustomDebugStringConvertible {

    /// The operation is successful and an associated value is available.
    case success(Value)

    /// The operation is failed and an associated error is available.
    case failure(Error)
    
    /// Checks and returns whether the result is a success.
    public var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    /// Checks and returns the associated value if the result is a success; `nil` otherwise.
    public var value: Value? {
        if case .success(let v) = self {
            return v
        }
        return nil
    }
    
    /// Returns whether the result is a failure; `false` otherwise.
    public var failure: Bool {
        return !isSuccess
    }
    
    /// Checks and returns the associated error value if the result is a failure; `nil` otherwise.
    public var error: Error? {
        if case .failure(let e) = self {
            return e
        }
        return nil
    }

    public var description: String {
        switch self {
        case let .success(value): return ".success(\(value))"
        case let .failure(error): return ".failure(\(error))"
        }
    }

    public var debugDescription: String {
        return description
    }
    
    /// Maps the result to a `Result` object. If the result is `.success`, `transform` is called with the
    /// associated value and new `.success` with the transformed value is returned. If the result is `.failure`,
    /// the original error is returned without transformation.
    ///
    /// - Parameter transform: A closure that takes the `.success` value of the result.
    /// - Returns: The `Result` object containing the result of the given closure. If the result is a
    ///            failure, the `Result` object contains the original failure.
    public func map<T>(_ transform: (Value) -> T) -> Result<T, Error> {
        switch self {
        case .success(let value): return .success(transform(value))
        case .failure(let error): return .failure(error)
        }
    }
}
