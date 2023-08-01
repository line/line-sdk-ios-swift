//
//  OpenChatCategoryExtensions.swift
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

extension OpenChatCategory: CustomStringConvertible {
    /// :nodoc:
    public var description: String {
        let key: String
        switch self {
        case .notSelected:  key = "square.create.category.notselected"
        case .school:       key = "square.create.category.school"
        case .friend:       key = "square.create.category.friend"
        case .company:      key = "square.create.category.company"
        case .organization: key = "square.create.category.org"
        case .region:       key = "square.create.category.region"
        case .baby:         key = "square.create.category.baby"
        case .sports:       key = "square.create.category.sports"
        case .game:         key = "square.create.category.game"
        case .book:         key = "square.create.category.book"
        case .movies:       key = "square.create.category.movies"
        case .photo:        key = "square.create.category.photo"
        case .art:          key = "square.create.category.art"
        case .animation:    key = "square.create.category.ani"
        case .music:        key = "square.create.category.music"
        case .tv:           key = "square.create.category.tv"
        case .celebrity:    key = "square.create.category.celebrity"
        case .food:         key = "square.create.category.food"
        case .travel:       key = "square.create.category.travel"
        case .pet:          key = "square.create.category.pet"
        case .car:          key = "square.create.category.car"
        case .fashion:      key = "square.create.category.fashion"
        case .health:       key = "square.create.category.health"
        case .finance:      key = "square.create.category.finance"
        case .study:        key = "square.create.category.study"
        case .etc:          key = "square.create.category.etc"
        }
        return Localization.string(key)
    }
}
