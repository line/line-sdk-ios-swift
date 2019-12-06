//
//  String.swift
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

extension String {
    func truncatedTail(upper maxCount: Int) -> String {
        return count <= maxCount ? self : trimming(upper: maxCount).appending("\u{2026}")
    }
    
    var prefixNormalized: String {
        return String(drop { $0.isWhitespace })
    }
    
    var normalized: String {
        return trimmingCharacters(in: .whitespaces)
    }
    
    func trimming(upper count: Int) -> String {
        let startIndex = self.startIndex
        if let endIndex = index(startIndex, offsetBy: count, limitedBy: endIndex) {
            return String(self[startIndex..<endIndex])
        }
        return self
    }
}
