//
//  AssertionHelpers.swift
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

import UIKit
import XCTest

func XCTAssertViewController<T: UIViewController>(
    _ input: @autoclosure () -> UIViewController,
    isKindOf viewControllerType: T.Type,
    file: StaticString = #file,
    line: UInt = #line
)
{
    let inputViewController = input()
    if inputViewController is T {
        return
    }
    
    if let navigation = inputViewController as? UINavigationController,
        navigation.topViewController is T
    {
        return
    }
    
    XCTFail(
        "The input view controller (\(inputViewController)) or its top view controller is not an instance " +
        "of `\(viewControllerType)` or any class that inherits from that class",
        file: file,
        line: line
    )
}
