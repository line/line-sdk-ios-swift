---
title: "Using with Objective-C"
description: "Although LINE SDK Swift is written in pure Swift, you could still use it in your Objective-C project without any knowledge of Swift. Follow this guide to know how to integrate LINE SDK Swift into an Objective-C project."
---

## Overview

Although LINE SDK Swift is written in pure Swift, you could still use it in your Objective-C project. For projects still using Objective-C as its programming language, there are two options to use LINE SDK Swift in their project.

## Option 1: Mixed Project to Use Swift SDK

If you have some experience on Swift, it is our recommend way to integrate LINE SDK Swift into your project.

Any existing Objective-C project could be turned to a mixed project of Objective-C and Swift. That means, you could add a Swift file to your project, and interact with LINE SDK Swift with its pure Swift APIs from that file. By doing this, you could follow all the documentation of Swift version like installation, API using and error handling.

Finally, you could expose necessary methods and types from your Swift files by adding `@objc` or `@objcMembers` to them. When you import Swift code into Objective-C, you rely on an Xcode-generated header file to expose those files to Objective-C. This automatically generated file is an Objective-C header that declares the Swift interfaces in your target. It can be thought of as an umbrella header for your Swift code. The name of this header is your product module name followed by adding "-Swift.h".

Import the Swift code from that target into any Objective-C .m file within that target using this syntax and substituting the appropriate name:

```objc
#import "ProductModuleName-Swift.h"
```

For more information on how to turn on mixed project in an Objective-C project, we recommend  this [Setting up Swift and Objective-C Interoperability][interoperability] tutorial. Please check the "Make a Swift Class available to Objective-C Files" section. The guide about [Migrating Your Objective-C Code to Swift][apple-migration-doc] from Apple may also help you to understand the whole process.

> If you decide to use a mixed project and successfully set it up, you can stop reading now.  All contents below are prepared for users who want to use Objective-C to access LINE SDK APIs.

## Option 2: Using the ObjC Wrapper

If you do not want to turn your existing Objective-C project to a mixed one for some reasons, another approach is using the provided ObjC wrapper from LINE SDK Swift. We will cover basic ideas, installation and common use of the ObjC Wrapper.

The LINE SDK Swift is only Swift compatible. The ObjC Wrapper is in turn an Objective-C compatible wrapper implementation over the core SDK. It provides most of the core functionality from original Swift SDK, allowing you to use it with Objective-C directly.

However, the type names and most SDK APIs have to be prefixed with "LineSDK", to avoid potential naming conflicting with original SDK. It also requires additional setup steps. Some features cannot be provided due to language specification, compared to the Swift version.

Please keep in mind this is a temporary way to use LINE SDK Swift. We strongly suggest you to migrate to our Swift version to get full support in future.

### Installation

#### Requirements

To build and use LINE SDK Swift with ObjC Wrapper, you need:

- iOS 10.0 or later as Deployment Target.
- Xcode 10 or later.

It is the same as you use LINE SDK Swift in Swift language.

#### CocoaPods

Instead of `LineSDKSwift`, you now need to install a sub pod called `LineSDKSwift/ObjC`. In your Podfile:

```ruby
platform :ios, '10.0'
use_frameworks!

target '<Your App Target Name>' do
    pod 'LineSDKSwift', '~> 5.0'
end
```

When installed with CocoaPods, you use `@import LineSDK;` to import LINE SDK Swift with ObjC Wrapper to your Objective-C project:

```objc
#import "ViewController.h"
@import LineSDK;

@implementation ViewController
// ...
@end
```

#### Carthage

You could use the same Cartfile if you install with Carthage:

<!--TODO onevcat: Update the github repo name-->

```
github "line/linesdk-swift" ~> 5.0
```

Carthage will build both "LineSDK.framework" and "LineSDKObjC.framework" under "Carthage/Build/iOS" folder in your project. You need to add both to your "Link Binary With Libraries" section in your build setting, as well as add them to the Carthage Copy Framework build phase. A correctly configured Build Phase tab should be like:

![iOS SDK Swift ObjC Link](/media/ios-sdk-swift/install-carthage-objc.png)

Then you need to set the "Always Embed Swift Standard Libraries" (`ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES`) in your Build Settings to "YES" to contain Swift standard libraries in your final app bundle.

When installed with Carthage, instead of `LineSDK`, you need to use `@import LineSDKObjC;` to import the wrapper in your Objective-C files:

```objc
#import "ViewController.h"
@import LineSDKObjC;

@implementation ViewController
// ...
@end
```

### Name Conventions

Compared to Swift version, almost all types are prefixed with "LineSDK". Here is some sample of how to handle common tasks in Objective-C:

#### Login with Some Permissions

```objc
NSSet *permissions = [NSSet setWithObjects:
                          [LineSDKLoginPermission profile],
                          [LineSDKLoginPermission openID],
                          nil];
[[LineSDKLoginManager sharedManager]
    loginWithPermissions:permissions
        inViewController:self
                 options:nil
       completionHandler:^(LineSDKLoginResult *result, NSError *error) {
           if (result) {
               NSLog(@"User Name: %@", result.userProfile.displayName);
           } else {
               NSLog(@"Error: %@", error);
           }
       }
 ];
```

#### Getting User Profile

```objc
[LineSDKAPI getProfileWithCompletionHandler:
    ^(LineSDKUserProfile * _Nullable profile, NSError * _Nullable error)
{
    if (profile) {
        NSLog(@"User Name: %@", profile.displayName);
    } else {
        NSLog(@"Error: %@", error);
    }
}];
```

### Error Handling in ObjC Wrapper

To make it compatible with Objective-C convention, `NSError`s are thrown from the ObjC Wrapper. Use `[LineSDKErrorConstant errorDomain]` to check whether an error is a LINE SDK related error:

```objc
NSError *error = // ... An error from LINE SDK ObjC Wrapper
if ([error.domain isEqualToString:[LineSDKErrorConstant errorDomain]]) {
    // SDK Error
}
```

All the SDK errors have the same `code` and `userInfo` properties with the LINE SDK Swift. You could use them to know the reason of an error.

```objc
if (error.code == 2004) {
    // invalidHTTPStatusAPIError
    NSNumber *statusCode = error.userInfo[[LineSDKErrorConstant userInfoKeyStatusCode]];
    if ([statusCode integerValue] == 403) {
        // Permission granting issue. Ask for authorization with enough permission again.
    }
}
```

See [Error Handling Guide][error-handling] to check how to identify an error and handle it in an elegant way.

[interoperability]: https://medium.com/ios-os-x-development/swift-and-objective-c-interoperability-2add8e6d6887
[apple-migration-doc]: https://developer.apple.com/documentation/swift/migrating_your_objective-c_code_to_swift
[error-handling]: /docs/ios-sdk-swift/error-handling 