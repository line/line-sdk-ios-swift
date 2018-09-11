---
title: "Managing User Identifier and Token"
description: "Getting user profile and ID Tokens after login with LINE SDK Swift."
---

When you user login with `.profile` permission, you could get a `userProfile` object in the login result. This topic was covered in the [Integrating LINE Login Guide][login-guide]. In this guide, we will discuss on how to identify your user after login, as well as using of [OpenID Connect][open-id] to verify user login in a safer way. At last, we will cover on topic of managing the access tokens.

## User Profile

If you have `.profile` permission, and need to retrieve the latest user profile again, you could invoke the `API.getProfile`:

```swift
API.getProfile { result in
    switch result {
    case .success(let profile):
        print("User ID: \(profile.userID)")
        print("User Display Name: \(profile.displayName)")
        print("User Icon: \(String(describing: profile.pictureURL))")
    case .failure(let error):
        print(error)
    }
}
```

> `displayName`, `pictureURL` and `statusMessage` may vary from what they were when user login, since your user could change it inside LINE app. If you want to identify your user, use `userID`, which is guaranteed to be the same.

## ID Token

[OpenID Connect][open-id] is an identity layer on top of the OAuth 2.0 protocol. It allows you and LINE exchange information in a much more secure way. Currently, LINE API will deliver some user information like `email` by issuing an ID Token under OpenID Connect protocol.

To get permission

An ID Token itself is a signed [JSON Web Token][jwt]. LINE SDK Swift will check 

[login-guide]: /docs/ios-sdk-swift/login
[open-id]: http://openid.net/connect/
[jwt]: https://jwt.io