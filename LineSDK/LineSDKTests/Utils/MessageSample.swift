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

func assertEqual<T: Equatable>(
    in dic: [String: Any],
    forKey key: String,
    value: T,
    file: StaticString = #file,
    line: UInt = #line)
{
    guard let dicValue = dic[key] else {
        XCTFail("Value for key '\(key)' does not exist")
        return
    }
    let failingDescription =
        "Value not match in \(file), line: \(line). " +
        "Expect String value \(value), found \(String(describing: dic[key]))."
    
    switch value.self {
    case is String:
        XCTAssertEqual(dicValue as? String, value as? String, failingDescription, file: file, line: line)
    case is Bool:
        let boolValue = (dic[key] as? NSNumber)?.boolValue
        XCTAssertEqual(boolValue, value as? Bool, failingDescription, file: file, line: line)
    case is Int:
        let intValue = (dic[key] as? NSNumber)?.intValue
        XCTAssertEqual(intValue, value as? Int, failingDescription, file: file, line: line)
    case is Float:
        let floatValue = (dic[key] as? NSNumber)?.floatValue
        XCTAssertEqual(floatValue, value as? Float, failingDescription, file: file, line: line)
    case is Double:
        let doubleValue = (dic[key] as? NSNumber)?.doubleValue
        XCTAssertEqual(doubleValue, value as? Double, failingDescription, file: file, line: line)
    default:
        XCTFail("Type comparison for \(T.self) not implemented yet.", file: file, line: line)
    }
}

extension Encodable {
    var json: [String: Any] {
        let data = try! JSONEncoder().encode(self)
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }
}
