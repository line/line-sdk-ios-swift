# Change Log

All notable changes to this project will be documented in this file.

## [Unreleased]

## [5.3.0] - 2019-09-17

### Added

- Add `IDTokenNonce` to `LoginResult`. This value can be used against the ID token verification API as a parameter.

#### Fixed

- Some improvement in documentation spelling and grammar.


## [5.2.4] - 2019-08-23

### Fixed

- Source application validation is removed. Login with LINE app now works correctly on iOS 13. [#97](https://github.com/line/line-sdk-ios-swift/pull/97)

## [5.2.3] - 2019-08-01

### Fixed

- An issue that the stored ID Token will be overwritten when a refreshed token is issued. [#88](https://github.com/line/line-sdk-ios-swift/pull/88)

## [5.2.2] - 2019-07-29

### Fixed

- When verifying token, get the provider metadata `issuer` from open ID discovery document, instead of a fixed value. [#86](https://github.com/line/line-sdk-ios-swift/pull/86)

## [5.2.1] - 2019-07-19

### Fixed

- Align the behavior of `LineSDKLoginButton` (wrapper class) to LoginButton, when user click login, will only return if login process is ongoing. [#78](https://github.com/line/line-sdk-ios-swift/pull/78)

## [5.2.0] - 2019-06-12

### Added

- Support for customizing the language used when login through web page. Set `preferredWebPageLanguage` of `LoginManager` to apply the required language. The default behavior (using the system language on user's device) is not changed. [#61](https://github.com/line/line-sdk-ios-swift/pull/61)
- Support for accessing AMR (Authentication Methods References) value in ID Token. [#63](https://github.com/line/line-sdk-ios-swift/pull/63)
- Now you can use either Swift 4.2 or Swift 5.0 when integrating LINE SDK with CocoaPods. [#60](https://github.com/line/line-sdk-ios-swift/pull/60)

### Fixed

- The `refreshToken` in `AccessToken` is now marked as `private`. We do not encourage you to use or store the refresh token yourself. Instead, always use the refresh token API from client when you want to get a new access token.


## [5.1.2] - 2019-04-15

### Fixed

- Logging out a user now revokes refresh token and its corresponding access tokens, instead of the current access token only. [#45](https://github.com/line/line-sdk-ios-swift/pull/45)

## [5.1.1] - 2019-03-28

### Fixed

- Allow additional application bundle ID of LINE apps to grant authorization code.

## [5.1.0] - 2019-02-26

### Added

- Some model types also support `Encodable` now for easier serialization.
- Support JSON conversion for Objective-C model wrapper classes for future features.
- Now you can get the raw ID Token value for server verification purpose.
- Add compatibility for Swift 5.0 and Xcode 10.2.

## [5.0.3] - 2019-01-17

### Fixed

- Build LineSDKObjC with Carthage now works properly with all targets included. [#13](https://github.com/line/line-sdk-ios-swift/issues/13)

## [5.0.2] - 2018-12-18

### Fixed

- A compiling crash when using Swift 5.0 tool chain to compile LINE SDK. [#6](https://github.com/line/line-sdk-ios-swift/issues/6), [SR-9375](https://bugs.swift.org/browse/SR-9375), [Swift #21296](https://github.com/apple/swift/pull/21296)
- An internal improvement on JWK handling.
- Improvement on documentation spelling and grammar. [#9](https://github.com/line/line-sdk-ios-swift/pull/9)

## [5.0.1] - 2018-11-29

### Fixed

- Improve ID Token signature verifying code to use latest Security framework API. [#4](https://github.com/line/line-sdk-ios-swift/pull/4)
- Hide an implementation detail in the sample app. [#2](https://github.com/line/line-sdk-ios-swift/pull/2)

## [5.0.0] - 2018-11-20

Initial release of LINE SDK Swift. Now the LINE SDK is an open source project.

LINE SDK version 5 is not compatible with version 4.x. To upgrade to version 5, check the [Migration Guide](https://developers.line.me/en/docs/ios-sdk/swift/migration-guide/).

### Added

- Support LINE Login v2.1, which provide a fine-tuned authorization permissions and more safety authorizing flow. See [LINE Login v2.1](https://developers.line.me/en/news/2017/09/28/) for more about it. 
    > Warning: Tokens from LINE Login v2.0 will be invalidated and your users will be logged out once you upgrade your SDK integration from version 4.x or earlier.
- ID Token with ECDSA verification based on OpenID protocol. It provides a secure way to verify user information.
- You can use a predefined login button to let your users login now. The button follows LINE Login button design guideline. It provides a quick way to integrate LINE Login to your app. See `LoginButton` for more.

### Fixed

- A potential issue which causes authorizing from LINE app may fail on devices with iOS 12.
- The automatically token refreshing should now work properly when receives a token expiring error from LINE Login Server.

[5.0.0]: https://github.com/line/line-sdk-ios-swift/releases/tag/5.0.0
[5.0.1]: https://github.com/line/line-sdk-ios-swift/compare/5.0.0...5.0.1
[5.0.2]: https://github.com/line/line-sdk-ios-swift/compare/5.0.1...5.0.2
[5.0.3]: https://github.com/line/line-sdk-ios-swift/compare/5.0.2...5.0.3
[5.1.0]: https://github.com/line/line-sdk-ios-swift/compare/5.0.3...5.1.0
[5.1.1]: https://github.com/line/line-sdk-ios-swift/compare/5.1.0...5.1.1
[5.1.2]: https://github.com/line/line-sdk-ios-swift/compare/5.1.1...5.1.2
[5.2.0]: https://github.com/line/line-sdk-ios-swift/compare/5.1.2...5.2.0
[5.2.1]: https://github.com/line/line-sdk-ios-swift/compare/5.2.0...5.2.1
[5.2.2]: https://github.com/line/line-sdk-ios-swift/compare/5.2.1...5.2.2
[5.2.3]: https://github.com/line/line-sdk-ios-swift/compare/5.2.2...5.2.3
[5.2.4]: https://github.com/line/line-sdk-ios-swift/compare/5.2.3...5.2.4
[5.3.0]: https://github.com/line/line-sdk-ios-swift/compare/5.2.4...5.3.0
