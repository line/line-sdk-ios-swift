//
//  APIHomePage.swift
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

class APIHomePage {

    let app = XCUIApplication()
    var table: XCUIElement

    init() {
        table = app.tables.firstMatch
    }

    func navigateToAPIHomePage() {
        app.tabBars.buttons["API"].tap()
    }

    func tapGetFriends() {
        table.cells.staticTexts["Get Friends"].tap()
    }

    func tapGetApproversInFriends() {
        table.cells.staticTexts["Get Approvers in Friends"].tap()
    }

    func tapGetGroups() {
        table.cells.staticTexts["Get Groups"].tap()
    }

    func tapGetApproversInGivenGroup() {
        table.cells.staticTexts["Get Approvers in given Group"].tap()
    }
    
    func tapSendTextMessage() {
        table.cells.staticTexts["Send text message to a friend"].tap()
    }

    func tapMultisendTextMessage() {
        table.cells.staticTexts["Multisend text message to first five friends"].tap()
    }

    func tapSendFlexMessage() {
        table.cells.staticTexts["Send flex message to a friend"].tap()
    }
}
