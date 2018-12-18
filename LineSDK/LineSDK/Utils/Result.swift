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

// This is an identical implementation for SE-0235 and https://github.com/apple/swift/pull/19982/
// We could add a conditional flag to the whole file once `Result` contained in the Swift Standard Library.

import Foundation

/// The possible results of an operation, whether it is successful or not.
///
/// - success: The operation was successful and an associated value is available.
/// - failure: The operation failed and an associated error is available.
public enum Result<Value, Error> {

    /// The operation was successful and an associated value is available.
    case success(Value)

    /// The operation failed and an associated error is available.
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

    /// Maps the result to a `Result` object. If the result is `.success`, `transform` is called with the
    /// associated value and new `.success` with the transformed value is returned. If the result is `.failure`,
    /// the original error is returned without transformation.
    ///
    /// - Parameter transform: A closure that takes the `.success` value of the result.
    /// - Returns: The `Result` object containing the result of the given closure. If the result is a
    ///            failure, the `Result` object contains the original failure.
    public func map<NewValue>(_ transform: (Value) -> NewValue) -> Result<NewValue, Error> {
        switch self {
        case .success(let value): return .success(transform(value))
        case .failure(let error): return .failure(error)
        }
    }

    /// Evaluates the given transform closure when this `Result` instance is `.failure`, passing the error
    /// as a parameter.
    ///
    /// Use the `mapError` method with a closure that returns a non-`Result` value.
    ///
    /// - Parameter transform: A closure that takes the failure value of the instance.
    /// - Returns: A new `Result` instance with the result of the transform, if it was applied.
    public func mapError<NewError>(_ transform: (Error) -> NewError) -> Result<Value, NewError> {
        switch self {
        case .success(let value): return .success(value)
        case .failure(let error): return .failure(transform(error))
        }
    }

    /// Evaluates the given transform closure when this `Result` instance is
    /// `.success`, passing the value as a parameter and flattening the result.
    ///
    /// - Parameter transform: A closure that takes the successful value of the
    ///   instance.
    /// - Returns: A new `Result` instance, either from the transform or from
    ///   the previous error value.
    public func flatMap<NewValue>(
        _ transform: (Value) -> Result<NewValue, Error>
        ) -> Result<NewValue, Error> {
        switch self {
        case let .success(value):
            return transform(value)
        case let .failure(error):
            return .failure(error)
        }
    }

    /// Evaluates the given transform closure when this `Result` instance is
    /// `.failure`, passing the error as a parameter and flattening the result.
    ///
    /// - Parameter transform: A closure that takes the error value of the
    ///   instance.
    /// - Returns: A new `Result` instance, either from the transform or from
    ///   the previous success value.
    public func flatMapError<NewError>(
        _ transform: (Error) -> Result<Value, NewError>
        ) -> Result<Value, NewError> {
        switch self {
        case let .success(value):
            return .success(value)
        case let .failure(error):
            return transform(error)
        }
    }

    /// Evaluates the given transform closures to create a single output value.
    ///
    /// - Parameters:
    ///   - onSuccess: A closure that transforms the success value.
    ///   - onFailure: A closure that transforms the error value.
    /// - Returns: A single `Output` value.
    public func fold<Output>(
        onSuccess: (Value) -> Output,
        onFailure: (Error) -> Output
        ) -> Output {
        switch self {
        case let .success(value):
            return onSuccess(value)
        case let .failure(error):
            return onFailure(error)
        }
    }
}

extension Result where Error : Swift.Error {
    /// Unwraps the `Result` and includes it into a throwing expression.
    ///
    /// - Returns: The success value, if the instance is a success.
    /// - Throws:  The error value, if the instance is a failure.
    public func unwrapped() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}

extension Result where Error == Swift.Error {
    /// Create an instance by capturing the output of a throwing closure.
    ///
    /// - Parameter throwing: A throwing closure to evaluate.
    @_transparent
    public init(_ throwing: () throws -> Value) {
        do {
            let value = try throwing()
            self = .success(value)
        } catch {
            self = .failure(error)
        }
    }

    /// Unwraps the `Result` into a throwing expression.
    ///
    /// - Returns: The success value, if the instance is a success.
    /// - Throws:  The error value, if the instance is a failure.
    public func unwrapped() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }

    /// Evaluates the given transform closure when this `Result` instance is
    /// `.success`, passing the value as a parameter and flattening the result.
    ///
    /// - Parameter transform: A closure that takes the successful value of the
    ///   instance.
    /// - Returns: A new `Result` instance, either from the transform or from
    ///   the previous error value.
    public func flatMap<NewValue>(
        _ transform: (Value) throws -> NewValue
        ) -> Result<NewValue, Error> {
        switch self {
        case let .success(value):
            do {
                return .success(try transform(value))
            } catch {
                return .failure(error)
            }
        case let .failure(error):
            return .failure(error)
        }
    }
}

extension Result : Equatable where Value : Equatable, Error : Equatable { }

extension Result : Hashable where Value : Hashable, Error : Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(error)
    }
}

extension Result : CustomDebugStringConvertible {
    public var debugDescription: String {
        var output = "Result."
        switch self {
        case let .success(value):
            output += "success("
            debugPrint(value, terminator: "", to: &output)
        case let .failure(error):
            output += "failure("
            debugPrint(error, terminator: "", to: &output)
        }
        output += ")"

        return output
    }
}
