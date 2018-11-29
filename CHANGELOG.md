# Change Log

All notable changes to this project will be documented in this file.

## [Unreleased]

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
[5.0.1]: https://github.com/line/line-sdk-ios-swift/releases/compare/5.0.0...5.0.1
