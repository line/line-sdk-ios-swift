//
//  OpenChatCategory.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
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

/// Represents the category of an Open Chat room.
public enum OpenChatCategory: Int, CaseIterable {
    // The order is important. It is the order which displayed when using `OpenChatCategory.allCases`.
    /// Not selected.
    case notSelected = 1
    /// Category "Schools".
    case school = 2
    /// Category "Friends".
    case friend = 7
    /// Category "Company".
    case company = 5
    /// Category "Organizations".
    case organization = 6
    /// Category "Local".
    case region = 8
    /// Category "Kids".
    case baby = 28
    /// Category "Sports".
    case sports = 16
    /// Category "Games".
    case game = 17
    /// Category "Books".
    case book = 29
    /// Category "Movies".
    case movies = 30
    /// Category "Photos".
    case photo = 37
    /// Category "Art".
    case art = 41
    /// Category "Animation & comics".
    case animation = 22
    /// Category "Music".
    case music = 33
    /// Category "TV shows".
    case tv = 24
    /// Category "Famous people".
    case celebrity = 26
    /// Category "Food".
    case food = 12
    /// Category "Travel".
    case travel = 18
    /// Category "Pets".
    case pet = 27
    /// Category "Automotive".
    case car = 19
    /// Category "Fashion & beauty".
    case fashion = 20
    /// Category "Health".
    case health = 23
    /// Category "Finance & business".
    case finance = 40
    /// Category "Study".
    case study = 11
    /// Category "Other".
    case etc = 35
}
