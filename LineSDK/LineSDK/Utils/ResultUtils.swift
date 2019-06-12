//
//  ResultUtils.swift
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

/// A set of convenience methods for manipulating the `Result` type.
public enum ResultUtil {

    /// Evaluates the given transform closures to create a single output value.
    ///
    /// - Parameters:
    ///   - onSuccess: A closure that transforms the success value.
    ///   - onFailure: A closure that transforms the error value.
    /// - Returns: A single `Output` value.
    public static func match<Success, Failure: Error, Output>(
        result: Result<Success, Failure>,
        onSuccess: (Success) -> Output,
        onFailure: (Failure) -> Output) -> Output
    {
        switch result {
        case let .success(value):
            return onSuccess(value)
        case let .failure(error):
            return onFailure(error)
        }
    }

    public static func matchSuccess<Success, Failure: Error, Output>(
        result: Result<Success, Failure>,
        with folder: (Success?) -> Output) -> Output
    {
        return match(
            result: result,
            onSuccess: { value in folder(value) },
            onFailure: { _ in folder(nil) }
        )
    }

    public static func matchFailure<Success, Failure: Error, Output>(
        result: Result<Success, Failure>,
        with folder: (Error?) -> Output) -> Output
    {
        return match(
            result: result,
            onSuccess: { _ in folder(nil) },
            onFailure: { error in folder(error) }
        )
    }

    public static func match<Success, Failure: Error, Output>(
        result: Result<Success, Failure>,
        with folder: (Success?, Error?) -> Output) -> Output
    {
        return match(
            result: result,
            onSuccess: { folder($0, nil) },
            onFailure: { folder(nil, $0) }
        )
    }
}

// These helper methods are not public since we do not want them to be exposed or cause any conflicts.
// They are merely a wrapper for the `ResultUtil` static methods.
extension Result {

    /// Evaluates the given transform closures to create a single output value.
    ///
    /// - Parameters:
    ///   - onSuccess: A closure that transforms the success value.
    ///   - onFailure: A closure that transforms the error value.
    /// - Returns: A single `Output` value.
    func match<Output>(
        onSuccess: (Success) -> Output,
        onFailure: (Failure) -> Output) -> Output
    {
        return ResultUtil.match(result: self, onSuccess: onSuccess, onFailure: onFailure)
    }

    func matchSuccess<Output>(with folder: (Success?) -> Output) -> Output {
        return ResultUtil.matchSuccess(result: self, with: folder)
    }

    func matchFailure<Output>(with folder: (Error?) -> Output) -> Output {
        return ResultUtil.matchFailure(result: self, with: folder)
    }

    func match<Output>(with folder: (Success?, Error?) -> Output) -> Output {
        return ResultUtil.match(result: self, with: folder)
    }
}
