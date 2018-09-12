//
//  LineSDKModelInterfaceTests.m
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

@interface LineSDKModelInterfaceTests : XCTestCase

@end

@implementation LineSDKModelInterfaceTests

+ (void)setUp {
    [super setUp];
    [[LineSDKLoginManager sharedManager] setupWithChannelID:@"123" universalLinkURL:nil];
}

- (void)testLoginPermissionInterface {
    XCTAssertNotNil([LineSDKLoginPermission openID]);
    XCTAssertNotNil([LineSDKLoginPermission profile]);
    XCTAssertNotNil([LineSDKLoginPermission email]);
    XCTAssertNotNil([LineSDKLoginPermission friends]);
    XCTAssertNotNil([LineSDKLoginPermission groups]);
    XCTAssertNotNil([LineSDKLoginPermission messageWrite]);
//    XCTAssertNotNil([LineSDKLoginPermission phone]);
//    XCTAssertNotNil([LineSDKLoginPermission birthday]);
//    XCTAssertNotNil([LineSDKLoginPermission profilePictureUpdate]);
//    XCTAssertNotNil([LineSDKLoginPermission timelinePost]);
//    XCTAssertNotNil([LineSDKLoginPermission addAssociatedOfficialAccounts]);
//    XCTAssertNotNil([LineSDKLoginPermission profileExtendedName]);
//    XCTAssertNotNil([LineSDKLoginPermission profileExtendedNameUpdate]);
//    XCTAssertNotNil([LineSDKLoginPermission profileExtendedGender]);
//    XCTAssertNotNil([LineSDKLoginPermission profileExtendedGenderUpdate]);
//    XCTAssertNotNil([LineSDKLoginPermission profileExtendedAddress]);
//    XCTAssertNotNil([LineSDKLoginPermission profileExtendedAddressUpdate]);
//    XCTAssertNotNil([LineSDKLoginPermission profileExtendedBirthday]);
//    XCTAssertNotNil([LineSDKLoginPermission profileExtendedBirthdayUpdate]);
//    XCTAssertNotNil([LineSDKLoginPermission payHistory]);
//    XCTAssertNotNil([LineSDKLoginPermission payAccount]);
//    XCTAssertNotNil([LineSDKLoginPermission merchant]);
//    XCTAssertNotNil([LineSDKLoginPermission gender]);
//    XCTAssertNotNil([LineSDKLoginPermission birthDate]);
//    XCTAssertNotNil([LineSDKLoginPermission address]);
//    XCTAssertNotNil([LineSDKLoginPermission realName]);
//    XCTAssertNotNil([LineSDKLoginPermission botAdd]);
    
    XCTAssertNotNil([[LineSDKLoginPermission alloc] initWithRawValue:@"value"]);
    XCTAssertNotNil([LineSDKLoginPermission chatMessageWrite:@"123"]);
    XCTAssertNotNil([LineSDKLoginPermission squareChatMessageWriteWithSquareID:@"123" chatID:@"456"]);
}

- (void)testAccessTokenInterface {
    LineSDKAccessToken* token = nil;
    XCTAssertNil(token.value);
    XCTAssertNil(token.createdAt);
    XCTAssertNil(token.IDToken);
    XCTAssertNil(token.refreshToken);
    XCTAssertNil(token.permissions);
    XCTAssertNil(token.expiresAt);
}

- (void)testAccessTokenStoreInterface {
    LineSDKAccessTokenStore *store = nil;
    XCTAssertNil(store.currentToken);
    XCTAssertNotNil([LineSDKAccessTokenStore sharedStore]);
}

- (void)testAccessTokenStoreNotificationDefinition {
    XCTAssertNotNil(NSNotification.LineSDKAccessTokenDidUpdate);
    XCTAssertNotNil(NSNotification.LineSDKAccessTokenDidRemove);
    XCTAssertNotNil(NSNotification.LineSDKOldAccessTokenKey);
    XCTAssertNotNil(NSNotification.LineSDKNewAccessTokenKey);
}

- (void)testUserProfileInterface {
    LineSDKUserProfile* profile = nil;
    XCTAssertNil(profile.userID);
    XCTAssertNil(profile.displayName);
    XCTAssertNil(profile.pictureURL);
    XCTAssertNil(profile.statusMessage);
}

- (void)testAccessTokenVerifyResultInterface {
    LineSDKAccessTokenVerifyResult *result = nil;
    XCTAssertNil(result.channelID);
    XCTAssertNil(result.permissions);
    XCTAssertEqual(result.expiresIn, 0);
}

- (void)testLoginManagerOptionInterface {
    XCTAssertNotNil(LineSDKLoginManagerOptions.onlyWebLogin);
    XCTAssertNotNil(LineSDKLoginManagerOptions.botPromptNormal);
    XCTAssertNotNil(LineSDKLoginManagerOptions.botPromptAggressive);
    
    XCTAssertNotNil([[LineSDKLoginManagerOptions alloc] initWithRawValue:1]);
}

- (void)testLoginResultInterface {
    LineSDKLoginResult *result = nil;
    XCTAssertNil(result.accessToken);
    XCTAssertNil(result.permissions);
    XCTAssertNil(result.userProfile);
}

- (void)testLoginProcessInterface {
    LineSDKLoginProcess *process = nil;
    [process stop];
}

- (void)testLoginManagerInterface {
    LineSDKLoginManager *manager = nil;
    
    XCTAssertNil(manager.currentProcess);
    XCTAssertFalse(manager.isSetupFinished);
    XCTAssertFalse(manager.isAuthorized);
    XCTAssertFalse(manager.isAuthorizing);
    [manager setupWithChannelID:@"" universalLinkURL:nil];
    [manager loginWithPermissions:nil
                 inViewController:nil
                          options:nil
                completionHandler:^(LineSDKLoginResult *result, NSError *error)
    {
        XCTAssertNil([result accessToken]);
        XCTAssertNil([result permissions]);
        XCTAssertNil([result userProfile]);
        XCTAssertNil([result friendshipStatusChanged]);
    }];
    [manager logoutWithCompletionHandler:^(NSError *error) {
        
    }];
    
    BOOL opened = [manager application:[UIApplication sharedApplication]
                                  open:[NSURL URLWithString:@"https://sample.com"]
                               options:@{}];
    XCTAssertFalse(opened);
    
    XCTAssertNotNil([LineSDKLoginManager sharedManager]);
}

- (void)testHexColorInterface {
    LineSDKHexColor *color = nil;
    XCTAssertNil(color.rawValue);
    XCTAssertNil(color.color);
    XCTAssertNotNil([[LineSDKHexColor alloc] init:[UIColor redColor]]);
    XCTAssertNotNil([[LineSDKHexColor alloc] initWithRawValue:@"#123123" defaultColor:[UIColor whiteColor]]);
    XCTAssertFalse([color isEqualsToColor:color]);
}

- (void)testAPIErrorInterface {
    LineSDKAPIError *error = nil;
    XCTAssertNil(error.error);
    XCTAssertNil(error.description);
}

- (void)testCallbackQueueInterface {
    XCTAssertNotNil([LineSDKCallbackQueue asyncMain]);
    XCTAssertNotNil([LineSDKCallbackQueue currentMainOrAsync]);
    XCTAssertNotNil([LineSDKCallbackQueue untouch]);
    
    dispatch_queue_t q = dispatch_get_main_queue();
    XCTAssertNotNil([LineSDKCallbackQueue callbackQueueWithDispatchQueue:q]);
    
    NSOperationQueue *oq = [NSOperationQueue mainQueue];
    XCTAssertNotNil([LineSDKCallbackQueue callbackQueueWithOperationQueue:oq]);
}

- (void)testUserInterface {
    LineSDKUser *user = nil;
    XCTAssertNil(user.userID);
    XCTAssertNil(user.displayName);
    XCTAssertNil(user.pictureURL);
}

- (void)testGroupInterface {
    LineSDKGroup *group = nil;
    XCTAssertNil(group.groupID);
    XCTAssertNil(group.groupName);
    XCTAssertNil(group.pictureURL);
}

- (void)testGetFriendsResponseInterface {
    LineSDKGetFriendsResponse *response = nil;
    XCTAssertNil(response.friends);
    XCTAssertNil(response.pageToken);
}

- (void)testGetGroupsResponseInterface {
    LineSDKGetGroupsResponse *response = nil;
    XCTAssertNil(response.groups);
    XCTAssertNil(response.pageToken);
}

- (void)testGetApproversInFriendsResponseInterface {
    LineSDKGetApproversInFriendsResponse *response = nil;
    XCTAssertNil(response.friends);
    XCTAssertNil(response.pageToken);
}

- (void)testGetApproversInGroupResponseInterface {
    LineSDKGetApproversInGroupResponse *response = nil;
    XCTAssertNil(response.users);
    XCTAssertNil(response.pageToken);
}

- (void)testGetFriendsSortInterface {
    XCTAssertEqual(LineSDKGetFriendsRequestSortNone, 0);
    XCTAssertEqual(LineSDKGetFriendsRequestSortName, 1);
}

- (void)testMessageSendingStatusInterface {
    LineSDKMessageSendingStatus *status = nil;
    XCTAssertFalse(status.isOK);
    XCTAssertTrue([[LineSDKMessageSendingStatus statusOK] isOK]);
    XCTAssertFalse([[LineSDKMessageSendingStatus statusDiscarded] isOK]);
}

- (void)testPostSendMessagesResponseInterface {
    LineSDKPostSendMessagesResponse *response = nil;
    XCTAssertNil(response.status);
}

- (void)testPostMultisendMessagesResponseSendingResultInterface {
    LineSDKPostMultisendMessagesResponseSendingResult *result = nil;
    XCTAssertNil(result.to);
    XCTAssertNil(result.status);
}

- (void)testPostMultisendMessagesResponseInterface {
    LineSDKPostMultisendMessagesResponse *response = nil;
    XCTAssertNil(response.result);
}

-(void)testErrorDomain {
    NSLog(@"%@", [LineSDKErrorConstant errorDomain]);
    XCTAssertTrue([[LineSDKErrorConstant errorDomain] isEqualToString:@"LineSDKError"]);
}

- (void)testJWTInterface {
    LineSDKJWT *jwt = nil;
    LineSDKJWTPayload *payload = jwt.payload;
    XCTAssertNil([payload getStringForKey:@"key"]);
    XCTAssertNil([payload getNumberForKey:@"key"]);
    XCTAssertNil(payload.issuer);
    XCTAssertNil(payload.subject);
    XCTAssertNil(payload.audience);
    XCTAssertNil(payload.name);
    XCTAssertNil(payload.expiration);
    XCTAssertNil(payload.issueAt);
    XCTAssertNil(payload.name);
    XCTAssertNil(payload.picture);
    XCTAssertNil(payload.email);
}

@end


