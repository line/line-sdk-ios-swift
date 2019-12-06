//
//  OpenChatCategory.swift
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

public enum OpenChatCategory: Int, CaseIterable {
    // The order is important. It is the order which displayed when using `OpenChatCategory.allCases`.
    case notSelected = 1
    case school = 2
    case friend = 7
    case company = 5
    case organization = 6
    case region = 8
    case baby = 28
    case sports = 16
    case game = 17
    case book = 29
    case movies = 30
    case photo = 37
    case art = 41
    case animation = 22
    case music = 33
    case tv = 24
    case celebrity = 26
    case food = 12
    case travel = 18
    case pet = 27
    case car = 19
    case fashion = 20
    case health = 23
    case finance = 40
    case study = 11
    case etc = 35
}

extension OpenChatCategory: CustomStringConvertible {
    public var description: String {
        let text: String
        switch self {
        case .notSelected:  text = "Unselected (not shown in any category)"
        case .school:       text = "Schools"
        case .friend:       text = "Friends"
        case .company:      text = "Company"
        case .organization: text = "Organizations"
        case .region:       text = "Local"
        case .baby:         text = "Kids"
        case .sports:       text = "Sports"
        case .game:         text = "Games"
        case .book:         text = "Books"
        case .movies:       text = "Movies"
        case .photo:        text = "Photos"
        case .art:          text = "Art"
        case .animation:    text = "Animation & comics"
        case .music:        text = "Music"
        case .tv:           text = "TV shows"
        case .celebrity:    text = "Famous people"
        case .food:         text = "Food"
        case .travel:       text = "Travel"
        case .pet:          text = "Pets"
        case .car:          text = "Automotive"
        case .fashion:      text = "Fashion & beauty"
        case .health:       text = "Health"
        case .finance:      text = "Finance & business"
        case .study:        text = "Study"
        case .etc:          text = "Other"
        }
        return text
    }
}
