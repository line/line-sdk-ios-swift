# Change Log

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Swift 6 and Swift Concurrency support. Now the project is compatible with Swift 6 and takes advantage of Swift Concurrency features. [#224](https://github.com/line/line-sdk-ios-swift/pull/224)
- Some APIs are converted to the async signature, so you can use the async/await syntax to call these APIs. Check the API reference for more.

### Fixed

- Some outdated usage and compiler version checks are removed due to new iOS SDK requirements. [#222](https://github.com/line/line-sdk-ios-swift/pull/222)

## [5.12.0] - 2025-01-15

### Added

- A new `initialWebAuthenticationMethod` option in the login parameters allows specifying the initial web authentication method. Setting this to `.qrCode` displays the QR code login as the default authentication method on the login page. [#219](https://github.com/line/line-sdk-ios-swift/pull/219)
- The `LoginProcess` object now includes a `loginRoute` value, indicating the path taken during login. This helps track whether the user logged in via the LINE app or through a web page. [#215](https://github.com/line/line-sdk-ios-swift/pull/215)

### Fixed

- An issue where SPM build for iOS was not working. We have also updated the project settings to the latest Xcode and Swift versions. [#216](https://github.com/line/line-sdk-ios-swift/pull/216)

## [5.11.2] - 2024-09-26

### Fixed

- Some compiler warning when building with Xcode 16.0. [#214](https://github.com/line/line-sdk-ios-swift/pull/214)

## [5.11.1] - 2024-05-22

### Fixed

- Now the `xcframework` binaries do not contain bit code anymore. [#210](https://github.com/line/line-sdk-ios-swift/pull/210)

## [5.11.0] - 2023-11-01

### Added

- Add digital signature to the xcframework artifacts. Now the xcframework binaries are signed with certificate of LINE Developer team. [#199](https://github.com/line/line-sdk-ios-swift/pull/199)
- Add the privacy manifest file to the resource bundle. [#200](https://github.com/line/line-sdk-ios-swift/pull/200)

## [5.10.1] - 2023-10-02

### Fixed

- Update license holder name in all source code files. Now LY Corporation is the license holder of LINE SDK Swift. The license content and terms itself is not changed so you can still use the SDK under the same condition as before. [#193](https://github.com/line/line-sdk-ios-swift/pull/193)
- As the removal of general support of iOS 12 and earlier in Xcode, now LINE SDK Swift also drops support for iOS 12 and earlier. [#190](https://github.com/line/line-sdk-ios-swift/pull/190)

## [5.10.0] - 2023-07-19

### Added

- An option `promptBotID` to append related query for internal partner use. [#188](https://github.com/line/line-sdk-ios-swift/pull/188).

## [5.9.1] - 2023-06-08

### Fixed

- Append `IDTokenRaw` property to ObjC's `LineSDKAccessToken` class. This allows retrieve the raw value of the received ID token when using the Objective-C wrapper. [#185](https://github.com/line/line-sdk-ios-swift/issues/185)

## [5.9.0] - 2022-09-20

This version drops supports for iOS 10 since Xcode 14 is not supporting 32-bit devices anymore. For more information, please refer to [32-bit app support has been discontinued in Xcode 14](https://developer.apple.com/news/upcoming-requirements/?id=06062022a).

### Added

- SwiftUI sample app. If you are using SwiftUI and want to integrate LINE SDK Swift into your SwiftUI project, please refer to the SwiftUI sample app to get started. [#177](https://github.com/line/line-sdk-ios-swift/pull/177)
- Support for Xcode 14 and iOS 16. [#178](https://github.com/line/line-sdk-ios-swift/pull/178)

### Fixed

- Drops iOS 10 support. Now LINE SDK Swift requires iOS 11 or later. If you have to continue to support iOS 10, use LINE SDK Swift 5.8.2.

## [5.8.2] - 2022-05-24

### Fixed

- Xcode 13.4 support. Fixed an issue that when built with Xcode 13.4, there is a chance that linking fails due to reference cycle. [#174](https://github.com/line/line-sdk-ios-swift/pull/174)
- Modernize the project to the latest Xcode and Swift version. 
- Now the xcframework contains debug symbols (dSYMs and bitcode map) in the framework. Integrating LINE SDK by xcframework now provides easier setup steps. [#175](https://github.com/line/line-sdk-ios-swift/pull/175)

## [5.8.1] - 2021-11-17

### Fixed

- Upgrade project settings for Xcode 13 and other tool dependencies. [#170](https://github.com/line/line-sdk-ios-swift/pull/170)

## [5.8.0] - 2021-08-19

### Added

- New permissions in `LoginPermission` for Open Chat Plug features. [#168](https://github.com/line/line-sdk-ios-swift/pull/168)

## [5.7.0] - 2020-09-16

### Added

- Xcode 12 support. The new Swift Package Manager support. Now the built-in UI of LINE SDK is also available when integrated with SPM. [#161](https://github.com/line/line-sdk-ios-swift/pull/161)

## [5.6.2] - 2020-08-14

### Fixed

- Auto retry `NSURLErrorNetworkConnectionLost` error once when exchanging token. This is a workaround for a long-last iOS bug [discussed here](https://github.com/line/line-sdk-ios-swift/blob/18b713af91f8b46c5aa4674e0af9c424339b96ae/LineSDK/LineSDK/Login/LoginProcess.swift#L246-L261). [#159](https://github.com/line/line-sdk-ios-swift/pull/159)

## [5.6.1] - 2020-08-05

### Fixed

- The completion handler for logging out was not called for HTTP status code 400. It now should be always called and not causing a hanging. [#158](https://github.com/line/line-sdk-ios-swift/pull/158)

## [5.6.0] - 2020-06-11

### Added

- Open Chat support. You can create an Open Chat room with LINE SDK for Swift now. There are also some other public APIs to help checking room availability or user's memebership for a given Open Chat room. Check the [official documentation](https://developers.line.biz/en/docs/ios-sdk/swift/overview/) and [API reference](https://developers.line.biz/en/reference/ios-sdk-swift/) of `OpenChatCreatingController` for more information. [#132](https://github.com/line/line-sdk-ios-swift/pull/132)

### Fixed

- Lots of improvement of reference and documentation comment.

## [5.5.2] - 2020-04-30

### Fixed

- Now explicitly log in with web view does not trigger the "LINE is not installed" warning on the login screen page.

## [5.5.1] - 2020-02-27

### Fixed

- Use standard parameter names from [PKCE for OAuth 2.0](https://oauth.net/2/pkce/) to replace the original One-Time-Password mechanism. [#133](https://github.com/line/line-sdk-ios-swift/pull/133)
- An issue that some symbols cannot be found in XCFramework binary for Objective-C wrapper. [#140](https://github.com/line/line-sdk-ios-swift/pull/140)
- Fix several dangling pointer warning for Xcode 11.4. [#141](https://github.com/line/line-sdk-ios-swift/pull/141)
- Improve security for `state` and `nonce` generating to use a better random generator from Security.framework. [#137](https://github.com/line/line-sdk-ios-swift/pull/137)

## [5.5.0] - 2019-12-17

### Added

- Add the `displayNameOverridden` and `displayNameOriginal` properties to `User` when getting friends list. Currently the `User.displayName` is a combination of `displayNameOverridden` and `displayNameOriginal`. It is a preferred version of user's name for displaying and searching. [#125](https://github.com/line/line-sdk-ios-swift/pull/125)
- Support for `xcframework`. Now you can download binary format of LINE SDK and LINE SDK Objective-C wrapper as `xcframework`, as well as the related dSYMs and symbol map files from the release page. To implement this feature, we modified a bit for the exposed Objective-C wrapper module, to make sure the binary compatibility not broken in future releases. [#126](https://github.com/line/line-sdk-ios-swift/pull/126)

### Fixed

- A missing localization for pt-BR when searching in sharing list panel. [#127](https://github.com/line/line-sdk-ios-swift/pull/127)

## [5.4.0] - 2019-11-29

### Added

- Sharing UI support. Now you can request `.oneTimeShare` permission and present a `ShareViewController` to let users select messages and share these messages to their friends or groups. LINE SDK provides a pre-defined UI for sharing messages. You can also build your own UI based on public methods in the SDK. [#79](https://github.com/line/line-sdk-ios-swift/pull/79)
- Properties in `Friend` and `Group` to retrieve the "large" version and "small" version of a profile image. [#30](https://github.com/line/line-sdk-ios-swift/pull/30)
- A new `relation` sort option to get graph list sorted by relationship between current user and friends. [#30](https://github.com/line/line-sdk-ios-swift/pull/30)
- Support for macCatalyst as a build target. [#123](https://github.com/line/line-sdk-ios-swift/pull/123)
- Support for building against Swift Package Manager. Currently SPM does not support adding resource, so all UI related parts (such as `LoginButton` and `ShareViewController`) are eliminated from SPM build. [#70](https://github.com/line/line-sdk-ios-swift/pull/70)
- Replace `LoginManagerOptions` with `LoginManager.Parameters` for flexible parameter configuration while login. [#119](https://github.com/line/line-sdk-ios-swift/pull/119)
- Provide a way to set customized `IDTokenNonce` as the `nonce` value in ID Token. [#119](https://github.com/line/line-sdk-ios-swift/pull/119)
- Now message payload setting provides more public setter. You can create a customized message payload much easier. [#90](https://github.com/line/line-sdk-ios-swift/pull/90)
- `APIErrorDetail` is now public, so you can get the detail error information when a `.invalidHTTPStatusAPIError` error happens. [#115](https://github.com/line/line-sdk-ios-swift/pull/115)
- Dark mode is supported now for iOS 13 or later. Although all parts of LINE SDK is compatible with the dark mode, the login page and consent pages are not yet. They will be prepared eventually without a native SDK release. [#105](https://github.com/line/line-sdk-ios-swift/pull/105) 

### Fixed

- Now `resource_bundles` is used instead of `resources` when integrated by CocoaPods. [#77](https://github.com/line/line-sdk-ios-swift/pull/77)

### Deprecated

- `LoginManagerOptions` and the related login method is deprecated. Use `LoginManager.Parameters` instead. [#119](https://github.com/line/line-sdk-ios-swift/pull/119/files#diff-f055b8fa041c67b8c8f2bd173ba83669)
- `preferredWebPageLanguage` is deprecated. Use the property with the same name in `LoginManager.Parameters` instead. [#119](https://github.com/line/line-sdk-ios-swift/pull/119/files#diff-f055b8fa041c67b8c8f2bd173ba83669)
- The general error type (`Error`) version of error handling delegate method in `LoginButtonDelegate` is deprecated. Use the specific `LineSDKError` version instead. [#120](https://github.com/line/line-sdk-ios-swift/pull/120)
- All token related APIs in `API` are now deprecated. They are moved to `API.Auth` to distinguish from the normal public APIs. Not like `API`, methods in `API.Auth` will not try to automatically refresh your access token. [#118](https://github.com/line/line-sdk-ios-swift/pull/118)


## [5.3.1] - 2019-10-25

### Fixed

- Web page preference language for Japanese now works properly with correct language code. [#113](https://github.com/line/line-sdk-ios-swift/pull/113)

## [5.3.0] - 2019-09-17

### Added

- Add `IDTokenNonce` to `LoginResult`. This value can be used against the ID token verification API as a parameter.

### Fixed

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
[5.3.1]: https://github.com/line/line-sdk-ios-swift/compare/5.3.0...5.3.1
[5.4.0]: https://github.com/line/line-sdk-ios-swift/compare/5.3.1...5.4.0
[5.5.0]: https://github.com/line/line-sdk-ios-swift/compare/5.4.0...5.5.0
[5.5.1]: https://github.com/line/line-sdk-ios-swift/compare/5.5.0...5.5.1
[5.5.2]: https://github.com/line/line-sdk-ios-swift/compare/5.5.1...5.5.2
[5.6.0]: https://github.com/line/line-sdk-ios-swift/compare/5.5.2...5.6.0
[5.6.1]: https://github.com/line/line-sdk-ios-swift/compare/5.6.0...5.6.1
[5.6.2]: https://github.com/line/line-sdk-ios-swift/compare/5.6.1...5.6.2
[5.7.0]: https://github.com/line/line-sdk-ios-swift/compare/5.6.2...5.7.0
[5.8.0]: https://github.com/line/line-sdk-ios-swift/compare/5.7.0...5.8.0
[5.8.1]: https://github.com/line/line-sdk-ios-swift/compare/5.8.0...5.8.1
[5.8.2]: https://github.com/line/line-sdk-ios-swift/compare/5.8.1...5.8.2
[5.9.0]: https://github.com/line/line-sdk-ios-swift/compare/5.8.2...5.9.0
[5.9.1]: https://github.com/line/line-sdk-ios-swift/compare/5.9.0...5.9.1
[5.9.1]: https://github.com/line/line-sdk-ios-swift/compare/5.9.1...5.10.0
[5.10.1]: https://github.com/line/line-sdk-ios-swift/compare/5.10.0...5.10.1
[5.11.0]: https://github.com/line/line-sdk-ios-swift/compare/5.10.1...5.11.0
[5.11.1]: https://github.com/line/line-sdk-ios-swift/compare/5.11.0...5.11.1
[5.11.2]: https://github.com/line/line-sdk-ios-swift/compare/5.11.1...5.11.2
[5.12.0]: https://github.com/line/line-sdk-ios-swift/compare/5.11.2...5.12.0
