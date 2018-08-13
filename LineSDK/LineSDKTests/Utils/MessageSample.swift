//
//  MessageSample.swift
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

import XCTest
import LineSDK

protocol MessageSample {
    static var samples: [String] { get }
    static var samplesData: [Data] { get }
}

extension MessageSample {
    static var samplesData: [Data] {
        return samples.map { $0.data(using: .utf8)! }
    }
}

func assertEqual(
    in dic: [String: Any],
    forKey key: String,
    string value: String,
    file: String = #file,
    line: Int = #line)
{
    XCTAssertEqual(
        dic[key] as? String,
        value,
        "Value not match in \(file), line: \(line). " +
        "Expect String value \(value), found \(String(describing: dic[key])).")
}

func assertEqual(
    in dic: [String: Any],
    forKey key: String,
    bool value: Bool,
    file: String = #file,
    line: Int = #line)
{
    XCTAssertEqual(
        (dic[key] as? NSNumber)?.boolValue,
        value,
        "Value not match in \(file), line: \(line). " +
        "Expect Bool value \(value), found \(String(describing: dic[key])).")
}

extension Message {
    var json: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }
}
