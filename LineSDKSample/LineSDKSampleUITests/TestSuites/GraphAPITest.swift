//
//  GraphAPITest.swift
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
import XCTest

class GraphAPITest: XCTestCase{
    
    let app = XCUIApplication()
    let apiHomePage = APIHomePage()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
        
        let loginPage = LoginPage()
        if loginPage.isLineLogoutButtonExists() {
            LineSDKScript.logout(app: app, loginPage: loginPage)
        }
    }

    func testGetFriends() {
        apiHomePage.navigateToAPIHomePage()
        apiHomePage.tapGetFriends()
        tapOKButtonInErrorAlertView()
    }

    func testGetApproversInFriends() {
        apiHomePage.navigateToAPIHomePage()
        apiHomePage.tapGetApproversInFriends()
        tapOKButtonInErrorAlertView()
    }

    func testGetGroups() {
        apiHomePage.navigateToAPIHomePage()
        apiHomePage.tapGetGroups()
        tapOKButtonInErrorAlertView()
    }

    func testGetApproversInGivenGroup() {
        apiHomePage.navigateToAPIHomePage()
        apiHomePage.tapGetApproversInGivenGroup()
        tapOKButtonInErrorAlertView()
    }

    func tapOKButtonInErrorAlertView() {
        addUIInterruptionMonitor(withDescription: "No access token error of using graph API") { (alert) -> Bool in
            
            XCTAssert(alert.staticTexts["Error"].exists)
            
            if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
                return true
            }
            return false
        }
        app.navigationBars.firstMatch.tap()
    }
}
