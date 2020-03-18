//
//  Page.swift
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

class Page {
    var app: XCUIApplication
    
    required init(_ app: XCUIApplication) {
        self.app = app
    }
    
    func on<T: Page>(page: T.Type) -> T {
        return page.init(app)
    }
    
    enum UIStatus: String {
        case exist = "exists == true"
        case notExist = "exist == false"
        case selected = "selected == true"
        case notSelected = "selected == false"
        case hittable = "isHittable == true"
        case notHittable = "hittable == false"
    }
    
    func expect(element: XCUIElement, status: UIStatus, withIn timeout: TimeInterval = 20) {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: status.rawValue), object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        
        if result == .timedOut {
            XCTFail(expectation.description)
        }
    }
    
    func tap(element: XCUIElement) {
        expect(element: element, status: .exist)
        element.tap()
    }
}
