//
//  LineSDKMessagingModelTests.m
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

@interface LineSDKMessagingModelTests : XCTestCase

@end

@implementation LineSDKMessagingModelTests

- (void)testMessageSenderInterface {
    LineSDKMessageSender *sender = [
                                    [LineSDKMessageSender alloc] initWithLabel:@"123"
                                    iconURL:[NSURL URLWithString:@"https://example.com"]
                                    linkURL:[NSURL URLWithString:@"https://example.com"]];
    [sender setLabel:@"456"];
    XCTAssertEqual([sender label], @"456");
    
    sender.iconURL = [NSURL URLWithString:@"https://example.com"];
    sender.linkURL = [NSURL URLWithString:@"https://example.com"];
    XCTAssertNotNil(sender.iconURL);
    XCTAssertNotNil(sender.linkURL);
}

- (void)testTextMessageInterface {
    LineSDKMessageSender *sender = [
                                    [LineSDKMessageSender alloc] initWithLabel:@"123"
                                    iconURL:[NSURL URLWithString:@"https://example.com"]
                                    linkURL:[NSURL URLWithString:@"https://example.com"]];
    LineSDKTextMessage *message = [[LineSDKTextMessage alloc] initWithText:@"hello" sender:sender];
    message.sender.label = @"456";
    XCTAssertEqual([message.sender label], @"456");
    
    message.text = @"hello";
    XCTAssertEqual([message text], @"hello");
    
    LineSDKTextMessage *converted = [message textMessage];
    XCTAssertEqual(converted.text, message.text);
}

- (void)testImageMessageInterface {
    LineSDKMessageSender *sender = [
                                    [LineSDKMessageSender alloc] initWithLabel:@"123"
                                    iconURL:[NSURL URLWithString:@"https://example.com"]
                                    linkURL:[NSURL URLWithString:@"https://example.com"]];
    
    NSURL *url = [NSURL URLWithString:@"https://example.com"];
    LineSDKImageMessage *message1 = [[LineSDKImageMessage alloc]
                                     initWithOriginalContentURL:url
                                     previewImageURL:url];
    LineSDKImageMessage *message2 = [[LineSDKImageMessage alloc]
                                     initWithOriginalContentURL:url
                                     previewImageURL:url
                                     animated:true
                                     fileExtension:@"abc" sender:sender];
    
    XCTAssertNotNil([message1 originalContentURL]);
    XCTAssertNotNil([message1 previewImageURL]);
    XCTAssertFalse([message1 animated]);
    XCTAssertNil([message1 fileExtension]);
    XCTAssertNil([message1 sender]);
    XCTAssertNotNil([message2 fileExtension]);
    
    LineSDKImageMessage *converted = [message1 imageMessage];
    XCTAssertEqual(message1.originalContentURL, converted.originalContentURL);
    
    message2.sender.label = @"456";
    XCTAssertEqual([message2.sender label], @"456");
}

- (void)testVideoMessageInterface {
    NSURL *url = [NSURL URLWithString:@"https://example.com"];
    LineSDKVideoMessage *message = [[LineSDKVideoMessage alloc] initWithOriginalContentURL:url previewImageURL:url];
    XCTAssertNotNil([message originalContentURL]);
    XCTAssertNotNil([message previewImageURL]);
    
    LineSDKVideoMessage *converted = [message videoMessage];
    XCTAssertEqual(message.originalContentURL, converted.originalContentURL);
}

- (void)testAudioMessageInterface {
    NSURL *url = [NSURL URLWithString:@"https://example.com"];
    LineSDKAudioMessage *message = [[LineSDKAudioMessage alloc] initWithOriginalContentURL:url duration:3.0];
    XCTAssertNotNil([message originalContentURL]);
    XCTAssertEqual([message duration], 3.0);
    
    LineSDKAudioMessage *converted = [message audioMessage];
    XCTAssertEqual(message.originalContentURL, converted.originalContentURL);
}

- (void)testLocationMessageInterface {
    LineSDKLocationMessage *message = [[LineSDKLocationMessage alloc]
                                       initWithTitle:@"a"
                                       address:@"b"
                                       latitude:0
                                       longitude:1];
    [message setTitle:@"123"];
    [message setAddress:@"456"];
    [message setLatitude:100];
    [message setLongitude:200];
    XCTAssertEqual(message.title, @"123");
    XCTAssertEqual(message.address, @"456");
    XCTAssertEqual(message.latitude, 100);
    XCTAssertEqual(message.longitude, 200);
    
    LineSDKLocationMessage *converted = [message locationMessage];
    XCTAssertEqual(message.title, converted.title);
}

- (void)testMessageActionInterface {
    LineSDKMessageURIAction *action = [[LineSDKMessageURIAction alloc]
                                       initWithLabel:@"action"
                                       uri:[NSURL URLWithString:@"https://example.com"]];
    XCTAssertEqual(action.label, @"action");
    XCTAssertEqual(action.uri.absoluteString, @"https://example.com");
    
    XCTAssertNotEqual([action URIAction], action);
    XCTAssertEqual([action URIAction].label, action.label);
    
}

- (void)testTemplateMessagePayloadInterface {
    LineSDKMessageURIAction *action = [[LineSDKMessageURIAction alloc]
                                       initWithLabel:@"action"
                                       uri:[NSURL URLWithString:@"https://example.com"]];
    LineSDKTemplateButtonsPayload *payload = [[LineSDKTemplateButtonsPayload alloc]
                                              initWithTitle:@"title"
                                              text:@"text"
                                              actions:@[action]];
    LineSDKTemplateMessage *message = [[LineSDKTemplateMessage alloc] initWithAltText:@"alt" payload:payload];
    
    LineSDKTemplateMessage *converted = [message templateMessage];
    XCTAssertEqual(converted.altText, message.altText);
    XCTAssertEqual(converted.payload.buttonsPayload.title, message.payload.buttonsPayload.title);
    
}

- (void)testTemplateButtonsPayloadInterface {
    LineSDKMessageURIAction *action = [[LineSDKMessageURIAction alloc]
                                       initWithLabel:@"action"
                                       uri:[NSURL URLWithString:@"https://example.com"]];
    LineSDKTemplateButtonsPayload *payload = [[LineSDKTemplateButtonsPayload alloc]
                                              initWithTitle:@"title"
                                              text:@"text"
                                              actions:@[action]];
    XCTAssertEqual(payload.title, @"title");
    XCTAssertEqual(payload.text, @"text");
    XCTAssertNotNil(payload.actions);
    XCTAssertNil(payload.defaultAction);
    XCTAssertNil(payload.thumbnailImageURL);
    XCTAssertEqual(payload.imageAspectRatio, LineSDKTemplateMessagePayloadImageAspectRatioNone);
    XCTAssertEqual(payload.imageContentMode, LineSDKTemplateMessagePayloadImageContentModeNone);
    XCTAssertNil(payload.imageBackgroundColor);
    XCTAssertNil(payload.sender);
    
    XCTAssertEqual([payload buttonsPayload].text, payload.text);
    [payload setText:@"123"];
    XCTAssertNotEqual([payload buttonsPayload], payload);
    XCTAssertEqual([payload buttonsPayload].text, @"123");
    
    [payload setImageAspectRatio:LineSDKTemplateMessagePayloadImageAspectRatioRectangle];
    XCTAssertEqual([payload imageAspectRatio], 1);
}

- (void)testTemplateConfirmPayloadInterface {
    LineSDKMessageURIAction *confirm = [[LineSDKMessageURIAction alloc]
                                        initWithLabel:@"confirm"
                                        uri:[NSURL URLWithString:@"https://example.com/confirm"]];
    LineSDKMessageURIAction *cancel = [[LineSDKMessageURIAction alloc]
                                       initWithLabel:@"cancel"
                                       uri:[NSURL URLWithString:@"https://example.com/cancel"]];
    LineSDKTemplateConfirmPayload *payload = [[LineSDKTemplateConfirmPayload alloc]
                                              initWithText:@"Text"
                                              confirmAction:confirm
                                              cancelAction:cancel];
    XCTAssertEqual(payload.text, @"Text");
    XCTAssertEqual([payload.confirmAction URIAction].label, @"confirm");
    XCTAssertEqual([payload.cancelAction URIAction].label, @"cancel");
    
    payload.confirmAction = cancel;
    XCTAssertEqual([[payload confirmPayload].confirmAction URIAction].label, @"cancel");
}

- (void)testTemplateCarouselPayloadColumnInterface {
    LineSDKMessageURIAction *action = [[LineSDKMessageURIAction alloc]
                                       initWithLabel:@"action"
                                       uri:[NSURL URLWithString:@"https://example.com"]];
    LineSDKTemplateCarouselPayloadColumn *column = [[LineSDKTemplateCarouselPayloadColumn alloc]
                                                    initWithTitle:@"title"
                                                    text:@"text"
                                                    actions:@[action]];
    XCTAssertEqual([column text], @"text");
    XCTAssertEqual([column title], @"title");
    XCTAssertNil([column defaultAction]);
    XCTAssertNil([column thumbnailImageURL]);
    XCTAssertNil([column imageBackgroundColor]);
    XCTAssertEqual([column actions].count, 1);
    
    [column addAction:action];
    [column setDefaultAction:action];
    
    XCTAssertEqual([column actions].count, 2);
    XCTAssertNotNil([column defaultAction]);
}

- (void)testTemplateCarouselPayloadInterface {
    LineSDKMessageURIAction *action = [[LineSDKMessageURIAction alloc]
                                       initWithLabel:@"action"
                                       uri:[NSURL URLWithString:@"https://example.com"]];
    LineSDKTemplateCarouselPayloadColumn *column = [[LineSDKTemplateCarouselPayloadColumn alloc]
                                                    initWithTitle:@"title"
                                                    text:@"text"
                                                    actions:@[action]];
    LineSDKTemplateCarouselPayload *payload = [[LineSDKTemplateCarouselPayload alloc] initWithColumns:@[column]];
    XCTAssertEqual(payload.columns.count, 1);
    
    [payload addColumn:column];
    XCTAssertEqual(payload.columns.count, 2);
    
    XCTAssertEqual(payload.imageAspectRatio, LineSDKTemplateMessagePayloadImageAspectRatioNone);
    XCTAssertEqual(payload.imageContentMode, LineSDKTemplateMessagePayloadImageContentModeNone);
    [payload setImageAspectRatio:LineSDKTemplateMessagePayloadImageAspectRatioSquare];
    [payload setImageContentMode:LineSDKTemplateMessagePayloadImageContentModeAspectFill];
    
    XCTAssertEqual([payload carouselPayload].columns.count, payload.columns.count);
}

- (void)testTemplateImageCarouselPayloadColumnInterface {
    LineSDKMessageURIAction *action = [[LineSDKMessageURIAction alloc]
                                       initWithLabel:@"action"
                                       uri:[NSURL URLWithString:@"https://example.com"]];
    LineSDKTemplateImageCarouselPayloadColumn *column = [[LineSDKTemplateImageCarouselPayloadColumn alloc]
                                                         initWithImageURL:[NSURL URLWithString:@"https://image.com"]
                                                         action:action];
    XCTAssertEqual([column imageURL].absoluteString, @"https://image.com");
    XCTAssertNotNil(column.action);
}

- (void)testTemplateImageCarouselPayloadInterface {
    LineSDKMessageURIAction *action = [[LineSDKMessageURIAction alloc]
                                       initWithLabel:@"action"
                                       uri:[NSURL URLWithString:@"https://example.com"]];
    LineSDKTemplateImageCarouselPayloadColumn *column = [[LineSDKTemplateImageCarouselPayloadColumn alloc]
                                                         initWithImageURL:[NSURL URLWithString:@"https://image.com"]
                                                         action:action];
    LineSDKTemplateImageCarouselPayload *payload = [[LineSDKTemplateImageCarouselPayload alloc] initWithColumns:@[column]];
    XCTAssertEqual(payload.columns.count, 1);
    
    [payload addColumn:column];
    XCTAssertEqual(payload.columns.count, 2);
    
    XCTAssertEqual([payload imageCarouselPayload].columns.count, payload.columns.count);
}

- (void)testFlexBlockStyleInterface {
    LineSDKHexColor *color = [[LineSDKHexColor alloc] init:[UIColor redColor]];
    LineSDKFlexBlockStyle *style = [[LineSDKFlexBlockStyle alloc]
                                    initWithBackgroundColor:color
                                    separator:NO
                                    separatorColor:color];
    style.backgroundColor = nil;
    style.separatorColor = [[LineSDKHexColor alloc] init:[UIColor blueColor]];
    style.separator = YES;
    
    XCTAssertNil([style.backgroundColor color]);
    XCTAssertEqual([style.separatorColor color], [UIColor blueColor]);
    XCTAssertTrue(style.separator);
}

- (void)testFlexBubbleContainerStyleInterface {
    LineSDKHexColor *color = [[LineSDKHexColor alloc] init:[UIColor redColor]];
    LineSDKFlexBlockStyle *style = [[LineSDKFlexBlockStyle alloc]
                                    initWithBackgroundColor:color
                                    separator:NO
                                    separatorColor:color];
    LineSDKFlexBubbleContainerStyle *containerStyle = [[LineSDKFlexBubbleContainerStyle alloc] init];
    containerStyle.header = style;
    containerStyle.hero = style;
    containerStyle.body = style;
    containerStyle.footer = style;
    
    style.backgroundColor = [[LineSDKHexColor alloc] init:[UIColor blueColor]];;
    
    XCTAssertEqual([containerStyle.header.backgroundColor color], [UIColor blueColor]);
    XCTAssertEqual([containerStyle.hero.backgroundColor color], [UIColor blueColor]);
    XCTAssertEqual([containerStyle.body.backgroundColor color], [UIColor blueColor]);
    XCTAssertEqual([containerStyle.footer.backgroundColor color], [UIColor blueColor]);
}

- (void)testFlexMessageComponentLayoutInterface {
    XCTAssertEqual(LineSDKFlexMessageComponentLayoutHorizontal, 0);
    XCTAssertEqual(LineSDKFlexMessageComponentLayoutVertical, 1);
    XCTAssertEqual(LineSDKFlexMessageComponentLayoutBaseline, 2);
}

- (void)testFlexMessageComponentMarginInterface {
    XCTAssertEqual(LineSDKFlexMessageComponentMarginNone, 0);
    XCTAssertEqual(LineSDKFlexMessageComponentMarginXs, 1);
    XCTAssertEqual(LineSDKFlexMessageComponentMarginSm, 2);
    XCTAssertEqual(LineSDKFlexMessageComponentMarginMd, 3);
    XCTAssertEqual(LineSDKFlexMessageComponentMarginLg, 4);
    XCTAssertEqual(LineSDKFlexMessageComponentMarginXl, 5);
    XCTAssertEqual(LineSDKFlexMessageComponentMarginXxl, 6);
}

- (void)testFlexMessageComponentSizeInterface {
    XCTAssertEqual(LineSDKFlexMessageComponentSizeNone, 0);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeXxs, 1);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeXs, 2);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeSm, 3);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeMd, 4);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeLg, 5);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeXl, 6);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeXxl, 7);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeXl3, 8);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeXl4, 9);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeXl5, 10);
    XCTAssertEqual(LineSDKFlexMessageComponentSizeFull, 11);
}

- (void)testFlexMessageComponentAlignment {
    XCTAssertEqual(LineSDKFlexMessageComponentAlignmentNone, 0);
    XCTAssertEqual(LineSDKFlexMessageComponentAlignmentStart, 1);
    XCTAssertEqual(LineSDKFlexMessageComponentAlignmentEnd, 2);
    XCTAssertEqual(LineSDKFlexMessageComponentAlignmentCenter, 3);
}

- (void)testFlexMessageComponentGravity {
    XCTAssertEqual(LineSDKFlexMessageComponentGravityNone, 0);
    XCTAssertEqual(LineSDKFlexMessageComponentGravityTop, 1);
    XCTAssertEqual(LineSDKFlexMessageComponentGravityBottom, 2);
    XCTAssertEqual(LineSDKFlexMessageComponentGravityCenter, 3);
}

- (void)testFlexMessageComponentWeight {
    XCTAssertEqual(LineSDKFlexMessageComponentWeightNone, 0);
    XCTAssertEqual(LineSDKFlexMessageComponentWeightRegular, 1);
    XCTAssertEqual(LineSDKFlexMessageComponentWeightBold, 2);
}

- (void)testFlexMessageComponentHeight {
    XCTAssertEqual(LineSDKFlexMessageComponentHeightNone, 0);
    XCTAssertEqual(LineSDKFlexMessageComponentHeightSm, 1);
    XCTAssertEqual(LineSDKFlexMessageComponentHeightMd, 2);
}

- (void)testFlexMessageComponentAspectRatio {
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioNone, 0);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_1x1, 1);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_1_51x1, 2);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_1_91x1, 3);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_4x3, 4);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_16x9, 5);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_20x13, 6);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_2x1, 7);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_3x1, 8);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_3x4, 9);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_9x16, 10);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_1x2, 11);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectRatioRatio_1x3, 12);
}

- (void)testFlexMessageComponentAspectMode {
    XCTAssertEqual(LineSDKFlexMessageComponentAspectModeNone, 0);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectModeFill, 1);
    XCTAssertEqual(LineSDKFlexMessageComponentAspectModeFit, 2);
}

- (void)testFlexTextComponentInterface {
    LineSDKFlexTextComponent *component = [[LineSDKFlexTextComponent alloc] initWithText:@"text"];
    component.flex = @3;
    component.margin = LineSDKFlexMessageComponentMarginXs;
    component.size = LineSDKFlexMessageComponentSizeLg;
    component.alignment = LineSDKFlexMessageComponentAlignmentEnd;
    component.gravity = LineSDKFlexMessageComponentGravityBottom;
    component.wrapping = YES;
    component.maxLines = nil;
    component.weight = LineSDKFlexMessageComponentWeightBold;
    component.color = nil;
    component.action = nil;
    XCTAssertEqual(component.text, @"text");
    XCTAssertEqual([component textComponent].text, @"text");
}

- (void)testFlexButtonComponentInterface {
    LineSDKMessageURIAction *action = [[LineSDKMessageURIAction alloc]
                                       initWithLabel:@"action"
                                       uri:[NSURL URLWithString:@"https://example.com"]];
    LineSDKFlexButtonComponent *component = [[LineSDKFlexButtonComponent alloc] initWithAction:action];
    component.flex = @3;
    component.margin = LineSDKFlexMessageComponentMarginSm;
    component.height = LineSDKFlexMessageComponentHeightSm;
    component.style = LineSDKFlexButtonComponentStylePrimary;
    component.color = [[LineSDKHexColor alloc] init:[UIColor redColor]];
    component.gravity = LineSDKFlexMessageComponentGravityCenter;
    XCTAssertEqual(component.action.URIAction.label, @"action");
    XCTAssertEqual([component buttonComponent].action.URIAction.label, @"action");
}

- (void)testFlexImageComponentInterface {
    LineSDKFlexImageComponent *component = [[LineSDKFlexImageComponent alloc]
                                            initWithImageURL:[NSURL URLWithString:@"https://example.com"]];
    component.flex = @3;
    component.margin = LineSDKFlexMessageComponentMarginXs;
    component.size = LineSDKFlexMessageComponentSizeLg;
    component.alignment = LineSDKFlexMessageComponentAlignmentEnd;
    component.gravity = LineSDKFlexMessageComponentGravityBottom;
    component.size = LineSDKFlexMessageComponentSizeLg;
    component.aspectRatio = LineSDKFlexMessageComponentAspectRatioRatio_1x3;
    component.aspectMode = LineSDKFlexMessageComponentAspectModeFill;
    component.backgroundColor = nil;
    XCTAssertEqual(component.url.absoluteString, @"https://example.com");
    XCTAssertEqual([component imageComponent].url.absoluteString, @"https://example.com");
}

- (void)testFlexFillerComponentInterface {
    LineSDKFlexFillerComponent *component = [[LineSDKFlexFillerComponent alloc] init];
    XCTAssertNotNil([component fillerComponent]);
}

- (void)testFlexSeparatorComponentInterface {
    LineSDKHexColor *color = [[LineSDKHexColor alloc] init:[UIColor redColor]];
    LineSDKFlexSeparatorComponent *component = [[LineSDKFlexSeparatorComponent alloc]
                                                initWithMargin:LineSDKFlexMessageComponentMarginLg
                                                color:color];
    component.margin = LineSDKFlexMessageComponentMarginMd;
    component.color = nil;
    XCTAssertEqual(component.margin, LineSDKFlexMessageComponentMarginMd);
    XCTAssertEqual([component separatorComponent].margin, component.margin);
}

- (void)testFlexSpacerComponentInterface {
    LineSDKFlexSpacerComponent *component = [[LineSDKFlexSpacerComponent alloc]
                                             initWithSize:LineSDKFlexMessageComponentSizeMd];
    component.size = LineSDKFlexMessageComponentSizeXl5;
    XCTAssertEqual(component.size, LineSDKFlexMessageComponentSizeXl5);
    XCTAssertEqual([component spacerComponent].size, component.size);
}

- (void)testFlexIconComponentInterface {
    LineSDKFlexIconComponent *component = [[LineSDKFlexIconComponent alloc]
                                           initWithIconURL:[NSURL URLWithString:@"https://example.com"]];
    component.margin = LineSDKFlexMessageComponentMarginMd;
    component.size = LineSDKFlexMessageComponentSizeMd;
    component.aspectRatio = LineSDKFlexMessageComponentAspectRatioRatio_2x1;
    XCTAssertEqual(component.size, LineSDKFlexMessageComponentSizeMd);
    XCTAssertEqual([component iconComponent].size, component.size);
}

- (void)testFlexBoxComponentInterface {
    LineSDKFlexTextComponent *text = [[LineSDKFlexTextComponent alloc] initWithText:@"Hello World"];
    LineSDKFlexBoxComponent *box = [[LineSDKFlexBoxComponent alloc]
                                    initWithLayout:LineSDKFlexMessageComponentLayoutHorizontal contents:@[text]];
    box.flex = @1;
    box.spacing = LineSDKFlexMessageComponentSpacingSm;
    box.margin = LineSDKFlexMessageComponentMarginLg;
    box.action = [[LineSDKMessageURIAction alloc]
                  initWithLabel:@"action" uri:[NSURL URLWithString:@"https://hello.com"]];
    
    XCTAssertEqual(box.contents.count, 1);
    XCTAssertEqual([box boxComponent].contents.count, [box boxComponent].contents.count);
    
}

- (void)testFlexBubbleContainerInterface {
    LineSDKFlexImageComponent *image = [[LineSDKFlexImageComponent alloc]
                                        initWithImageURL:[NSURL URLWithString:@"https://example.com"]];
    LineSDKFlexBoxComponent *box = [[LineSDKFlexBoxComponent alloc]
                                    initWithLayout:LineSDKFlexMessageComponentLayoutHorizontal contents:@[image]];
    LineSDKFlexBubbleContainer *container = [[LineSDKFlexBubbleContainer alloc] init];
    container.header = box;
    container.hero = image;
    container.body = box;
    container.footer = box;
    container.direction = LineSDKFlexBubbleContainerDirectionRightToLeft;
    
    XCTAssertEqual([container bubbleContainer].direction, container.direction);
}

- (void)testFlexCarouselContainerInterface {
    LineSDKFlexImageComponent *image = [[LineSDKFlexImageComponent alloc]
                                        initWithImageURL:[NSURL URLWithString:@"https://example.com"]];
    LineSDKFlexBoxComponent *box = [[LineSDKFlexBoxComponent alloc]
                                    initWithLayout:LineSDKFlexMessageComponentLayoutHorizontal contents:@[image]];
    LineSDKFlexBubbleContainer *bubble = [[LineSDKFlexBubbleContainer alloc] init];
    bubble.body = box;
    LineSDKFlexCarouselContainer *carousel =  [[LineSDKFlexCarouselContainer alloc]
                                               initWithContents:@[bubble, bubble, bubble]];
    XCTAssertEqual(carousel.contents.count, 3);
    XCTAssertEqual([carousel carouselContainer].contents.count, 3);
}

-(void)testFlexMessageInterface {
    LineSDKFlexImageComponent *image = [[LineSDKFlexImageComponent alloc]
                                        initWithImageURL:[NSURL URLWithString:@"https://example.com"]];
    LineSDKFlexBoxComponent *box = [[LineSDKFlexBoxComponent alloc]
                                    initWithLayout:LineSDKFlexMessageComponentLayoutHorizontal contents:@[image]];
    LineSDKFlexBubbleContainer *container = [[LineSDKFlexBubbleContainer alloc] init];
    container.header = box;
    
    LineSDKFlexMessage *message = [[LineSDKFlexMessage alloc] initWithAltText:@"alt" container:container];
    message.altText = @"hello";
    message.contents = container;
    XCTAssertEqual(message.altText, @"hello");
    XCTAssertEqual([message flexMessage].altText, message.altText);
}


@end
