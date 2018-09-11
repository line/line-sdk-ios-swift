---
title: "Installation"
description: "How to integrate LINE SDK Swift into your project"
---

<!--TODO onevcat: Update repo URL-->

This guide explains how to install LINE SDK Swift into your iOS project and make necessary configuration. To make your app compatible with latest iOS and get full support, we strongly suggest you follow this installation guide and use the latest version of LINE SDK Swift.

## Requirements

To build and use LINE SDK Swift, you need:

- iOS 10.0 or later as Deployment Target.
- Xcode 10 or later.

You could use this SDK with either Swift or Objective-C. This guide assumes you are using Swift to interact with LINE SDK Swift. For Objective-C users, please refer to [Using with Objective-C Guide][using-objc] for more information.

## Installation

LINE SDK Swift is **not compatible** with previous LINE SDK versions in Objective-C. If you are upgrading your integration of LINE SDK, please read the [Migration Guide][migration-guide] first before you make a decision.

### CocoaPods

If you are not familiar with CocoaPods, see the [CocoaPods Getting Started Guide][cocoa-pods-guide]. You need CocoaPods gem installed on your machine before attempting to integrate LINE SDK Swift to your app through CocoaPods.

Once you prepared your Podfile, add the pod command below to your target:

```ruby
platform :ios, '10.0'
use_frameworks!

target '<Your App Target Name>' do
    pod 'LineSDKSwift', '~> 5.0'
end
```

Then, run the following command:

```bash
$ pod install
```

LINE SDK Swift should be downloaded and integrated into an Xcode workspace.

### Carthage

[Carthage][carthage-home] is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To install the carthage tool, you can use [Homebrew][homebrew-home].

```bash
$ brew update
$ brew install carthage
```

To integrate LINE SDK Swift into your Xcode project using Carthage, specify it in your Cartfile:

<!--TODO onevcat: Update the github repo name-->

```
github "line/linesdk-swift" ~> 5.0
```

Then, run the following command to build the LINE SDK Swift:

<!--TODO onevcat: Update the github repo name-->

```
$ carthage update linesdk-swift
```

At last, you need to set up your Xcode project manually to add the LINE SDK Swift.

1. Link LineSDK.framework

    On your application targets’ “General” settings tab, in the "Linked Frameworks and Libraries" section, drag and drop LineSDK.framework from the Carthage/Build folder on disk.

    ![iOS SDK Swift Link](/media/ios-sdk-swift/install-link.png)


2. Copy framework on Build

    On your application targets’ “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script with the following content:
    
    ```
    /usr/local/bin/carthage copy-frameworks
    ```
    
    Add the paths to LineSDK.framework to use under "Input Files":
    
    ```
    $(SRCROOT)/Carthage/Build/iOS/LineSDK.framework
    ```
    
    Add the paths to the copied LineSDK.framework to the "Output Files":
    
    ```
    $(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/LineSDK.framework
    ```
    
    After you add them, the run script should look like this:
    
    ![iOS SDK Swift Link](/media/ios-sdk-swift/install-carthage-copy.png)
    
## Linking Channel to Your App

You need to config your channel before you can link your app to a LINE channel. If you didn't create your channel in LINE Developers site yet, please follow the ["Creating a channel" Guide][create-channel] to get started. Once you have a channel, follow the next steps to config it for your iOS app.

### Configuring Channel in Developer Console

To link your app with your channel, complete the following fields in the "App settings" page of the [console][console].

- **iOS bundle ID:** Bundle identifier of your app found in the “General” tab in your Xcode project settings. Must be lowercase. For example, `com.example.app`. You can specify multiple bundle identifiers by entering each one on a new line.
- **iOS scheme:** Set as `line3rdp.` followed by the bundle identifier. For example, if your bundle identifier is `com.example.app`, set the iOS scheme as `line3rdp.com.example.app`. Only one iOS scheme can be specified.

<img class="Md104ImgBorder Md68ImgMax" alt="iOS app settings" src="/media/line-login/integrate-login-ios/ios-app-settings.png" width="650px">

### Configuring `Info.plist` Settings

In Xcode, right-click your project's Info.plist file and select Open As -> Source Code. Then, insert the following snippet into the body of your file just before the final </dict> element:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>line3rdp.$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>lineauth2</string>
</array>
```

This does two things:

1. Adding a URL scheme `line3rdp.$(PRODUCT_BUNDLE_IDENTIFIER)` which will be used for LINE Login to open your app when there is a result of the login event.
2. Adding a queries scheme for "lineauth2", which will be used to check whether it is possible to log in your user through LINE iOS app.

### Next Step

Once you installed and configured, you are ready to add LINE Login to your app. See the [Integrating LINE Login Guide][login-guide] for more on that topic.

[using-objc]: /docs/ios-sdk-swift/using-objc
[migration-guide]: /docs/ios-sdk-swift/migration-guide
[cocoa-pods-guide]: https://guides.cocoapods.org/using/getting-started.html
[carthage-home]: https://github.com/Carthage/Carthage
[homebrew-home]: http://brew.sh/
[create-channel]: /docs/line-login/getting-started
[console]: /console/
[login-guide]: /docs/ios-sdk-swift/login