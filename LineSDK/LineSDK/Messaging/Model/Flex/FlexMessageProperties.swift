//
//  FlexMessageProperties.swift
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

extension FlexMessageComponent {
    
    public enum Margin: String, DefaultEnumCodable {
        case none, xs, sm, md, lg, xl, xxl
        public static let defaultCase: FlexMessageComponent.Margin = .none
    }

    public enum Size: String, DefaultEnumCodable {
        case xxs, xs, sm, md, lg, xl, xl2 = "xxl", xl3 = "3xl", xl4 = "4xl", xl5 = "5xl"
        public static let defaultCase: FlexMessageComponent.Size = .md
    }
    
    public enum Align: String, DefaultEnumCodable {
        case start, end, center
        public static let defaultCase: FlexMessageComponent.Align = .start
    }
    
    public enum Gravity: String, DefaultEnumCodable {
        case top, bottom, center
        public static let defaultCase: FlexMessageComponent.Gravity = .top
    }
    
    public enum Weight: String, DefaultEnumCodable {
        case regular, bold
        public static let defaultCase: FlexMessageComponent.Weight = .regular
    }
    
    public enum Height: String, DefaultEnumCodable {
        case sm, md
        public static let defaultCase: FlexMessageComponent.Height = .md
    }
}

