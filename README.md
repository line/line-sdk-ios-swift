![](https://git.linecorp.com/LINE-Client/linesdk-ios-swift/raw/assets/assets/sdklogo.png)

# LineSDK Swift

The LineSDK Swift lets you integrate LINE into your iOS app to create a more engaging experience for your users. This framework is written in pure Swift and provides an easy way to integrate LINE login, LINE APIs and other exciting features to your app.

## Features

After installing LINE SDK Swift, you will be provided with the following features.

### Authentication with LINE Login

Allowing your users to log in to your service with their LINE accounts. With the help of LINE SDK Swift, it was never easier to integrate LINE Login into your app. Your users will automatically log in to your app without entering their LINE credentials if they are already logged in to LINE on their iOS devices. This brings you a good way to have users trying your app quickly without registration.

### Getting Better Connection to Users

Once authorized, you could identify your users by accessing your users' profile in LINE. With additional setup, you could request display name, profile image, mail address, and an unique user ID. This saves you the cost of building your own user system since you could trust and rely on LINE's account management.

## Getting Started

For a detail guide on how to use LINE SDK Swift, please refer the links below:

- Official Guide in LINE Developer
- API Reference of LINE SDK Swift

These guides covered most useful topics of LINE SDK Swift, from installation to usage, as well as error handling best practice.

### Sample App

To have a quick and basic impression of LINE SDK Swift, you could check the Sample App in this project. Try to clone this project, build and run "LineSDKSample". If you want to try it with your own channel, please modify the app bundle ID to your app ID, and update the "LINE_CHANNEL_ID" value in `Config.xcconfig` file to your channel ID.

## Project CI Status

| **Build** | **Status** |
|:-----------:|:------------:|
| **Master** | [![Build Status](https://jenkins.linecorp.com/buildStatus/icon?job=com.linecorp.linesdk_swift_master)](https://jenkins.linecorp.com/view/LINE_SDK/job/com.linecorp.linesdk_swift_master/) |
| **Pull Request** | [![Build Status](https://jenkins.linecorp.com/buildStatus/icon?job=com.linecorp.linesdk_swift_pr)](https://jenkins.linecorp.com/view/LINE_SDK/job/com.linecorp.linesdk_swift_pr/) |

