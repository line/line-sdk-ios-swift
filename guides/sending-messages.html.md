---
title: "Sending Messages"
description: "Sending messages on behalf of user by LINE SDK Swift"
---

<div class="Md108FrameNote">
  <p><span class="Md07TextBold">Note: </span>Sending Messages are now <b>still in closed beta</b>, only for the internal partner using. They are not yet prepared for the public and <b>we do not accept applications for them yet</b>. Please keep an eye on it and we will inform you if the state changes in future.</p>
</div>

## Overview

With LINE SDK Swift, you could send messages on behalf of an authorized user, to another user, room or group. The messages will be delivered and displayed in LINE app. Remember when you send some messages to a destination, the message sender is not your channel, but the authorized user. So please use this feature carefully and make sure to get permissions from your users before you send a message on their behalf.

`.messageWrite` permission is required for using the message APIs. You need to specify it and ask your user to authorize it when login:

```swift
LoginManager.shared.login(permissions: [.messageWrite], in: self) { result in
    // Handling the login result...
}
```

Before you sending a message, you need to construct it first. See the ["Messages"][messages] section below to know more about message types and how to create one in LINE SDK Swift. Once you prepared your messages to send, you could call this API to send it out:

```swift
let message = TextMessage(text: "Hello World")
API.sendMessages([message], to: "U12345") { result in
    switch result {
    case .success(let response):
        if response.status.isOK {
            print("Message Sent.")
        } else {
            print("Not accepted: \(response.status)")
        }
    case .failure(let error):
        print(error)
    }
}
```

There are some cases that your sending destination rejects your messages. In this case, `response.status` will contain the detail information. See ["Sending Status"][sending-status] section on this topic for more.

## Messages

To create a message, you could use the types below to initialize a value. See the API reference for more on consisting of a message. Generally, LINE SDK Swift provides beautiful initializers or settable properties for all message types. It aids you to organize messages in a safe way.

### Simple Messages

A simple message is a message with fixed layout, and belongs to a certain category. It is the easiest way to construct a message. Simple messages include:

- `TextMessage`: A message contains only plain text. You could also specify an agent (usually it is the channel provider, or say, yourself) who sends this message on behalf of the user.
- `ImageMessage`: A message contains only an image. You could also provide a sending agent information.
- `VideoMessage`: A message contains a video URL and its preview image.
- `AudioMessage`: A message contains an audio URL.
- `LocationMessage`: A message contains a location information with latitude and longitude, as well as location title and address.

Creating a simple message is very easy. You just call the initializer directly. For example:

```swift
let sender = MessageSender(
                label: "Your Company Name",
                iconURL: yourChannelIconURL,
                linkURL: yourLink)
let textMessage = TextMessage(
                text: "Let's play it together!",
                sender: sender)
    
let locationMessage = LocationMessage(
                title: "Meet Here",
                address: "Some Address, 1-1",
                latitude: 35.689,
                longitude: 139.702)
API.sendMessages([textMessage, locationMessage], to: "U12345") { result in  /* */ }
```

### Template Messages

A template message is also layout-fixed. However, it provides you some choice between a set of predefined template payloads. They are:

- `TemplateButtonsPayload`: A payload represents an image, title, text and multiple action buttons.
- `TemplateConfirmPayload`: A payload represents a confirm chat pop, containing two buttons (usually a positive button and a negative one).
- `TemplateCarouselPayload`: A payload represents multiple columns that users can cycle through.
- `TemplateImageCarouselPayload`: Similar to `TemplateCarouselPayload`, but contains multiple images instead.

To get an intuitive impression of how each payload looks like, check the  ["Template messages"][template-messages] documentation for more.

To construct a template message, you firstly create a payload object, setup its properties as needed, then create a `TemplateMessage` which is ready to be sent. The example below creates a template message with buttons payload:

```swift
let buttonsPayload = TemplateButtonsPayload(
    title: "Tap Me",
    text: "Some content",
    actions: [
        MessageURIAction(label: "Option 1", uri: URL(string: "https://yourdomain.com/option1")!),
        MessageURIAction(label: "Option 1", uri: URL(string: "https://yourdomain.com/option2")!)
    ])
buttonsPayload.thumbnailImageURL = URL(string: "https://yourdomain.com/thumbnail.png")

let templateMessage = TemplateMessage(
    altText: "Alternative text to fall back",
    payload: buttonsPayload)
    
API.sendMessages([templateMessage], to: "U12345") { result in  /* */ }
```

### Flexible Messages

Flexible message, or so-called Flex message, is a kind of customizable message type you could construct by combining different building blocks or elements. It's up to you to decide the message layout, style, content and interaction. 

In the top level of a flex message, a container will be present to hold its blocks. Each block in turn is consisted of components. Below we will give a brief introduction on supported containers and components in LINE SDK Swift. For more information about flex message, read [Using Flex Messages Guide][using-flex-message].

#### Flex Message Container

A container defines the top-level structure of a Flex Message.

- `FlexBubbleContainer`: A container contains a header section, a main image ([hero image][hero-image]), a body section and footer section. Each section is a certain type of component, you can also set a nested component, or even skip the section as you need.
- `FlexCarouselContainer`: A carousel container contains multiple bubble container. These bubbles will be shown in order by scrolling horizontally.

A `FlexBubbleContainer` also defines the common styles inside it, as well as content direction.

#### Flex Message Component

A flex message component is the fundamental building block of a flex message. LINE SDK Swift supports eight kinds of types:

##### Components for Content

- `FlexTextComponent`: A label with some formatted text. You could specify text color, font weight, size, alignment and some other properties for it.
- `FlexImageComponent`: A component represents an image from URL.
- `FlexButtonComponent`: A component represents a button with an action bound.
- `FlexIconComponent`: A component of icon, which is used to embed into a baseline layout.

##### Components for Layout

There are also some components just for layout or visual effect:

- `FlexBoxComponent`: A container component. It could hold other components (including another `FlexBoxComponent`), to build a nested component. A box component also defines spacing between its children and their distribution rule.
- `FlexFillerComponent`: A component represents an invisible component to fill extra space between components.
- `FlexSeparatorComponent`: A component represents a separator (horizontal or vertical line) between components in the parent box.
- `FlexSpacerComponent`: A component represents some fixed-size space at the beginning or end of in a box component.

#### Building a Flex Message

To build a flex message, usually you could follow the steps below:

1. Pick up necessary components, choose styles for each one, and build them into a proper component. For hero image, you need a `FlexImageComponent`. For other sections, you need to put components into a `FlexBoxComponent`.
2. Create a bubble container and set its `header`, `hero`, `body` and `footer` to the component you need. If you need a `FlexCarouselContainer`, create multiple `FlexBubbleContainer` and make them a bundle.
3. Create the final `FlexMessage` object.

Below is an example of creating a flex message:

```swift
do {
    // 1. Create components
    
    // 1.1 Header
    var title = FlexTextComponent(text: "Welcome")
    title.color = .init(.red)
    let header = FlexBoxComponent(layout: .horizontal, contents: [title])

    // 1.2 Hero Image
    let hero = try FlexImageComponent(url: URL(string: "https://sample.com/hero-image.png")!)
    
    // 1.3 Body
    var bodyImage = try FlexImageComponent(url: URL(string: "https://sample.com/body-image.png")!)
    bodyImage.aspectMode = .fill
    let separator = FlexSeparatorComponent(margin: .lg, color: .init(.blue))
    let bodyText = FlexTextComponent(text: "This is my picture!")
    let body = FlexBoxComponent(layout: .vertical, contents: [bodyImage, separator, bodyText])
    
    // 1.4 Footer
    var footerText = FlexTextComponent(text: "Message From Your Channel")
    footerText.alignment = .center
    footerText.size = .sm
    let footer = FlexBoxComponent(layout: .horizontal, contents: [footerText])
    
    // 2. Create container
    var bubbleContainer = FlexBubbleContainer()
    bubbleContainer.header = header
    bubbleContainer.hero = hero
    bubbleContainer.body = body
    bubbleContainer.footer = footer
    
    // 3. Create flex message
    let flexMessage = FlexMessage(altText: "Alternative text as fallback", container: bubbleContainer)
    API.sendMessages([flexMessage], to: "U12345") { result in /* */ }
} catch {
    print(error)
}
```

#### Previewing Your Flex Message

You could find a Flex Message Simulator on [this page][flex-simulator]. Underlying the flex message is constructed with a [JSON specification][using-flex-message], so you could preview your flex message if correct representing JSON object provided.

To get the underlying JSON string from a `FlexMessage`, call its `jsonString()` on its `contents`:

```swift
let flexMessage = FlexMessage(altText: "Alternative text as fallback", container: bubbleContainer)
do {
    if let json = try flexMessage.contents.jsonString() {
        print(json)
    }
} catch {
    print(error)
}
```

A human-readable JSON representation for the flex message container will be printed to your console. Copy and paste it into the [Flex Message Simulator][flex-simulator] to check the appearance without actually sending it out.

Once you prepared and confirmed the flex message, you could send it with the same API as you sending any other messages:

```swift
let flexMessage = FlexMessage(altText: "Alternative text as fallback", container: bubbleContainer)
API.sendMessages([flexMessage], to: "U12345") { result in  /* */ }
```

> The same Flex Message may be rendered differently depending on the environment of the receiving device. Elements that may affect drawing include the device OS (iOS, Android, MacOS or PC), LINE version, device resolution, language setting, and font.

## Sending Status

Your messages might be rejected by the destination. For example, a target user might choose not to receive any messages from the sender or from your channel. In this case, the message sending API still successes, but with a status code other than `.ok`:

```swift
API.sendMessages([flexMessage], to: "U12345") {
    result in
    switch result {
    case .success(let response):
        switch response.status {
        case .ok:
            print("Message sent and received.")
        case .discarded:
            print("Message sent but discarded by destination")
        case .unknown(let code):
            print("Message sent but server returns an unknown status code: \(code)")
        }
    case .failure(let error):
        print(error)
    }
}
```

The `.unknown` case should be recognized as message not received properly. To avoid the nested `switch` statement and make it simpler, you could use `.isOK` to check the sending status:

```swift
if response.status.isOK {
    print("Message sent and received.")
} else {
    print("Message sent but not accepted by destination.")
}
```

If the API fails itself, the `.failure` case will be executed as all other APIs. Check [Error Handling Guide][error-handling] for best practice on handling errors in LINE SDK Swift.

## Sending Messages to Multiple Destination

You could also send some messages to multiple destination at a time.

```swift
API.multiSendMessages([message], to: ["U12345", "U67890"]) {
    result in
    switch result {
    case .success(let response):
        let sendingResults = response.results // sendingResult: [SendingResult]
        for r in sendingResults {
            let destination = r.to // destination: String, usually the user ID.
            let isOK = r.status.isOK // isOK: Bool, whether the message sent and accepted.
        }
    case .failure(let error):
        print(error)
    }
}
```

[messages]: #spy-messages
[sending-status]: #sending-status
[template-messages]: /docs/messaging-api/message-types/#template-messages
[using-flex-message]: /docs/messaging-api/using-flex-messages/
[hero-image]: https://en.wikipedia.org/wiki/Hero_image
[flex-simulator]: /console/fx/
[error-handling]: /docs/ios-sdk-swift/error-handling 