//
//  LineSDKViewControllerInterfaceTests.m
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

#import <XCTest/XCTest.h>
@import LineSDKObjC;

@interface LineSDKViewControllerInterfaceTests : XCTestCase

@end

@implementation LineSDKViewControllerInterfaceTests

- (void)testShareViewControllerCreating {
    LineSDKShareViewController *controller = [[LineSDKShareViewController alloc] init];

    UIColor *color = [UIColor redColor];
    XCTAssertNotEqual(controller.shareBarTintColor, color);
    controller.shareBarTintColor = color;
    XCTAssertEqual(controller.shareBarTintColor, color);

    XCTAssertNotEqual(controller.shareBarTextColor, color);
    controller.shareBarTextColor = color;
    XCTAssertEqual(controller.shareBarTextColor, color);

    XCTAssertEqual(controller.shareStatusBarStyle, UIStatusBarStyleLightContent);
    controller.shareStatusBarStyle = UIStatusBarStyleDefault;
    XCTAssertEqual(controller.shareStatusBarStyle, UIStatusBarStyleDefault);

    XCTAssertNil(controller.shareMessages);

    LineSDKTextMessage *m1 = [[LineSDKTextMessage alloc] initWithText:@"test"];

    LineSDKFlexBubbleContainer *container = [[LineSDKFlexBubbleContainer alloc] init];
    LineSDKFlexMessage *m2 = [[LineSDKFlexMessage alloc] initWithAltText:@"flex" container:container];

    controller.shareMessages = @[m1, m2];
    XCTAssertEqual(controller.shareMessages.count, 2);
}

@end
