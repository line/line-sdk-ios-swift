//
//  MessageStore.swift
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
import LineSDK

let sdkTitleImageURL =
    URL(string: "https://repository-images.githubusercontent.com/154433729/773e8080-9e83-11e9-8021-45a46d2d2e4c")!
let sdkLogoImageURL =
    URL(string: "https://raw.githubusercontent.com/line/line-sdk-ios-swift/assets/assets/sdklogo.png")!
let starIconImageURL =
    URL(string: "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png")!
let swiftLogoImageURL =
    URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/Swift_logo.svg/1138px-Swift_logo.svg.png")!

extension MessageConvertible {
    func named(_ name: String) -> MessageStore.StoredMessage {
        return MessageStore.StoredMessage(name: name, message: self.message)
    }
}

extension Notification.Name {
    static let messageStoreMessageInserted =
        Notification.Name(rawValue: "com.linecorp.linesdk.sample.messageStoreMessageInserted")
}

class MessageStore {

    struct StoredMessage: Codable {
        let name: String
        let message: Message
    }

    static let shared = MessageStore()

    let url: URL = {
        let fileManager = FileManager.default
        let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("message_template.json")
        return url
    }()

    var messages: [StoredMessage] {
        didSet {
            save()
        }
    }

    private init() {
        do {
            let data = try Data(contentsOf: url)
            messages = try JSONDecoder().decode([StoredMessage].self, from: data)
        } catch {
            messages = [
                MessageStore.SampleMessage.textMessage,
                MessageStore.SampleMessage.imageMessage,
                MessageStore.SampleMessage.videoMessage,
                MessageStore.SampleMessage.audioMessage,
                MessageStore.SampleMessage.locationMessage,
                MessageStore.SampleMessage.templateButtonsMessage,
                MessageStore.SampleMessage.templateConfirmMessage,
                MessageStore.SampleMessage.flexBubbleMessage,
                MessageStore.SampleMessage.flexCarouselMessage
            ]
            save()
        }
    }

    func save() {
        let data = try! JSONEncoder().encode(messages)
        try! data.write(to: url)
    }

    func insert(_ message: Message, name: String, at index: Int? = nil) {
        let storedMessage = StoredMessage(name: name, message: message)
        if let index = index {
            messages.insert(storedMessage, at: index)
        } else {
            messages.append(storedMessage)
        }
        NotificationCenter.default.post(name: .messageStoreMessageInserted, object: self)
    }

    func remove(at index: Int) {
        messages.remove(at: index)
    }
}

extension MessageStore {
    enum SampleMessage {
        static var textMessage: StoredMessage {
            return TextMessage(text: "Hello From LINE SDK").named("Text Message")
        }

        static var imageMessage: StoredMessage {
            return try! ImageMessage(
                originalContentURL: sdkTitleImageURL,
                previewImageURL: sdkLogoImageURL)
                .named("Image Message")
        }

        static var videoMessage: StoredMessage {
            return try! VideoMessage(
                originalContentURL:
                URL(string: "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4")!,
                previewImageURL:
                URL(string: "https://sample-videos.com/img/Sample-png-image-100kb.png")!)
                .named("Video Message")
        }

        static var audioMessage: StoredMessage {
            return try! AudioMessage(
                originalContentURL: URL(string: "https://sample-videos.com/audio/mp3/crowd-cheering.mp3")!,
                duration: 28)
                .named("Audio Message")
        }

        static var locationMessage: StoredMessage {
            return LocationMessage(
                title: "Current Location",
                address: "JR Shinjuku Miraina Tower 23F, 4-1-6 Shinjuku, Tokyo, Japan",
                latitude: 35.69,
                longitude: 139.70)
                .named("Location Message")
        }

        static var templateButtonsMessage: StoredMessage {
            return TemplateMessage(
                altText: "Template Message (Buttons)",
                payload: TemplateButtonsPayload(
                    title: "Weather",
                    text: "It's a sunny day today!",
                    actions: [
                        MessageURIAction(
                            label: "Yes",
                            uri: URL(string: "https://example.com?action_index=0")!),
                        MessageURIAction(
                            label: "Absolutely",
                            uri: URL(string: "https://example.com?action_index=1")!),
                    ]
                )
            )
            .named("Template Message (Buttons)")
        }

        static var templateConfirmMessage: StoredMessage {
            return TemplateMessage(
                altText: "Template Message (Buttons)",
                payload: TemplateConfirmPayload(
                    text: "Eat outside?",
                    confirmAction: MessageURIAction(
                        label: "Yes",
                        uri: URL(string: "https://example.com?action_index=0")!),
                    cancelAction: MessageURIAction(
                        label: "No",
                        uri: URL(string: "https://example.com?action_index=1")!)
                )
            )
            .named("Template Message (Confirm)")
        }

        static var flexBubbleMessage: StoredMessage {
            return FlexMessage(
                altText: "Flex Message (Bubble)",
                container:FlexBubbleItem.lineSDK.bubbleContainer
            ).named("Flex Message (Bubble)")
        }

        static var flexCarouselMessage: StoredMessage {
            return FlexMessage(
                altText: "Flex Message (Carousel)",
                container: FlexCarouselContainer(
                    contents: [
                        FlexBubbleItem.lineSDK.bubbleContainer,
                        FlexBubbleItem.armeria.bubbleContainer,
                        FlexBubbleItem.promgen.bubbleContainer
                    ]
                )
            ).named("Flex Message (Carousel)")
        }

        struct FlexBubbleItem {
            let heroImageURL: URL
            let repo: String
            let title: String
            let starCount: Int
            let version: String
            let coverage: Int
            let swiftCompatible: Bool

            var repoURL: URL {
                return URL(string: "https://github.com/\(repo)")!
            }

            var bubbleContainer: FlexBubbleContainer {
                return FlexBubbleContainer(
                    hero: try! FlexImageComponent(
                        url: heroImageURL, size: .full,
                        aspectRatio: .ratio_16x9,
                        aspectMode: .fill,
                        action: MessageURIAction(uri: repoURL).action),
                    body: FlexBoxComponent(layout: .vertical, spacing: .md) {
                        var components: [FlexMessageComponentConvertible] = [
                            FlexTextComponent(
                                text: title, size: .xl, gravity: .center, weight: .bold),
                            FlexBoxComponent(layout: .baseline, margin: .md) {
                                return [
                                    try! FlexIconComponent(url: starIconImageURL, size: .md),
                                    FlexTextComponent(
                                        text: "\(starCount)", margin: .md, size: .sm, color: "#999999")
                                ]
                            },
                            FlexBoxComponent(layout: .vertical, spacing: .sm, margin: .lg) {
                                return [
                                    FlexBoxComponent(layout: .baseline, spacing: .sm) {
                                        return [
                                            FlexTextComponent(
                                                text: "Repo", flex: 2, size: .sm, color: "#aaaaaa"),
                                            FlexTextComponent(
                                                text: repo, flex: 4, size: .sm, color: "#666666")
                                        ]
                                    },
                                    FlexBoxComponent(layout: .baseline, spacing: .sm) {
                                        return [
                                            FlexTextComponent(
                                                text: "Version", flex: 2, size: .sm, color: "#aaaaaa"),
                                            FlexTextComponent(
                                                text: version, flex: 4, size: .sm, color: "#666666")
                                        ]
                                    },
                                    FlexBoxComponent(layout: .baseline, spacing: .sm) {
                                        return [
                                            FlexTextComponent(
                                                text: "Coverage", flex: 2, size: .sm, color: "#aaaaaa"),
                                            FlexTextComponent(
                                                text: "\(coverage)%", flex: 4, size: .sm, color: "#666666")
                                        ]
                                    }
                                ]
                            }
                        ]
                        if swiftCompatible {
                            components.append(
                                FlexBoxComponent(layout: .horizontal, margin: .xxl) {
                                    return [
                                        FlexSpacerComponent(size: nil),
                                        try! FlexImageComponent(url: swiftLogoImageURL, size: .sm, aspectMode: .fit),
                                        FlexTextComponent(
                                            text: "Compatible with Swift " +
                                            "(Swift and the Swift logo are trademarks of Apple Inc.)",
                                            margin: .xxl,
                                            size: .xs,
                                            wrapping: true,
                                            color: "#aaaaaa")

                                    ]
                                }
                            )
                        }
                        return components
                    }
                )
            }

            static let lineSDK = FlexBubbleItem(
                heroImageURL: sdkTitleImageURL,
                repo: "line/line-sdk-ios-swift",
                title: "LINE SDK",
                starCount: 607,
                version: "5.3.0",
                coverage: 82,
                swiftCompatible: true)
            static let armeria = FlexBubbleItem(
                heroImageURL: URL(string: "https://pbs.twimg.com/profile_images/1115801670686871552/GdB0P9Dw.jpg")!,
                repo: "line/armeria",
                title: "Armeria",
                starCount: 1997,
                version: "0.89.0",
                coverage: 77,
                swiftCompatible: false)
            static let promgen = FlexBubbleItem(
                heroImageURL: URL(string: "https://line.github.io/centraldogma/_static/central_dogma.png")!,
                repo: "line/centraldogma",
                title: "Central Dogma",
                starCount: 279,
                version: "0.41.0",
                coverage: 63,
                swiftCompatible: false)
        }
    }
}
