//
//  LineSDKLoginPermissionTests.m
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

@interface LineSDKLoginPermissionTests : XCTestCase

@end

@implementation LineSDKLoginPermissionTests

- (void)testInterface {
    XCTAssertNotNil([LineSDKLoginPermission openID]);
    XCTAssertNotNil([LineSDKLoginPermission profile]);
    XCTAssertNotNil([LineSDKLoginPermission email]);
    XCTAssertNotNil([LineSDKLoginPermission friends]);
    XCTAssertNotNil([LineSDKLoginPermission groups]);
    XCTAssertNotNil([LineSDKLoginPermission messageWrite]);
    XCTAssertNotNil([LineSDKLoginPermission phone]);
    XCTAssertNotNil([LineSDKLoginPermission birthday]);
    XCTAssertNotNil([LineSDKLoginPermission profilePictureUpdate]);
    XCTAssertNotNil([LineSDKLoginPermission timelinePost]);
    XCTAssertNotNil([LineSDKLoginPermission addAssociatedOfficialAccounts]);
    XCTAssertNotNil([LineSDKLoginPermission profileExtendedName]);
    XCTAssertNotNil([LineSDKLoginPermission profileExtendedNameUpdate]);
    XCTAssertNotNil([LineSDKLoginPermission profileExtendedGender]);
    XCTAssertNotNil([LineSDKLoginPermission profileExtendedGenderUpdate]);
    XCTAssertNotNil([LineSDKLoginPermission profileExtendedAddress]);
    XCTAssertNotNil([LineSDKLoginPermission profileExtendedAddressUpdate]);
    XCTAssertNotNil([LineSDKLoginPermission profileExtendedBirthday]);
    XCTAssertNotNil([LineSDKLoginPermission profileExtendedBirthdayUpdate]);
    XCTAssertNotNil([LineSDKLoginPermission payHistory]);
    XCTAssertNotNil([LineSDKLoginPermission payAccount]);
    XCTAssertNotNil([LineSDKLoginPermission merchant]);
    XCTAssertNotNil([LineSDKLoginPermission gender]);
    XCTAssertNotNil([LineSDKLoginPermission birthDate]);
    XCTAssertNotNil([LineSDKLoginPermission address]);
    XCTAssertNotNil([LineSDKLoginPermission realName]);
    XCTAssertNotNil([LineSDKLoginPermission botAdd]);

    XCTAssertNotNil([[LineSDKLoginPermission alloc] initWithRawValue:@"value"]);
    XCTAssertNotNil([LineSDKLoginPermission chatMessageWrite:@"123"]);
    XCTAssertNotNil([LineSDKLoginPermission squareChatMessageWriteWithSquareID:@"123" chatID:@"456"]);
    
    
}

@end
