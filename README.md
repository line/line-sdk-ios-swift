<img src="https://raw.githubusercontent.com/line/line-sdk-ios-swift/assets/assets/sdklogo.png" width="355" height="97">

[![Build Status](https://travis-ci.org/line/line-sdk-ios-swift.svg?branch=master)](https://travis-ci.org/line/line-sdk-ios-swift)
[![codecov](https://codecov.io/gh/line/line-sdk-ios-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/line/line-sdk-ios-swift)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/LineSDKSwift.svg)](https://cocoapods.org/pods/LineSDKSwift)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# LINE SDK for iOS Swift

## Overview

Developed in Swift, the LINE SDK for iOS Swift provides a modern way of implementing LINE APIs. The features included in this SDK will help you develop an iOS app with engaging and personalized user experience.

## Features

The LINE SDK for iOS Swift provides the following features.

### User authentication

This feature allows users to log in to your service with their LINE accounts. With the help of the LINE SDK for iOS Swift, it has never been easier to integrate LINE Login into your app. Your users will automatically log in to your app without entering their LINE credentials if they are already logged in to LINE on their iOS devices. This offers a great way for users to get started with your app without having to go through a registration process.

### Utilizing user data with OpenID support

Once the user authorizes, you can get the user’s LINE profile. You can utilize the user's information registered in LINE without building your user system.

The LINE SDK supports the OpenID Connect 1.0 specification. You can get ID tokens that contain the user’s LINE profile when you retrieve the access token.

## Using the SDK

### Prerequisites

* iOS 10.0 or later as the deployment target.
* Xcode 10 or later.

To use the LINE SDK with your iOS app, follow the steps below.

* Create a channel. 
* Integrate LINE Login into your iOS app using the SDK. 
* Make API calls from your app using the SDK or from server-side through the Social API. 

For more information, refer to the [LINE SDK for iOS Swift guide](https://developers.line.biz/en/docs/ios-sdk/) on the [LINE Developers site](https://developers.line.biz).

### Trying the starter app

To have a quick look at the features of the LINE SDK, try our starter app by following the steps below:

1. Clone the repository.

    ```git clone https://github.com/line/line-sdk-ios-swift.git```

2. Open the `LineSDK.xcworkspace` file in Xcode.

3. Build and run the `LineSDKSample` scheme.

The starter app should launch.

## Contributing

If you believe you have discovered a vulnerability or have an issue related to security, please **DO NOT** open a public issue. Instead, send us a mail to [dl_oss_dev@linecorp.com](mailto:dl_oss_dev@linecorp.com).

For contributing to this project, please see [CONTRIBUTING.md](https://github.com/line/line-sdk-ios-swift/blob/master/CONTRIBUTING.md).

