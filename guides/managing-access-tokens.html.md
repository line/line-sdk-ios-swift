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

### Applying for Email Permission

You can request users who log in using LINE Login to grant your app the permission to get their email address. To do so, you first need to apply for the permission in the developers [console][console].

1. Click "Submit" next to "Email" in the "OpenID Connect" section in the "Channel settings" page. Applying for email permission

  ![apply email permission](/media/line-login/integrate-login-web/apply-email.png)

2. Agree to the application terms and upload a screenshot of the screen that explains to the user why you need to obtain their email address and what you will use it for.

Once your application is accepted, "Applied" is displayed under "Email".

### Login with OpenID & Email permission

With email permission applied, you could login with `.openid` and `.email` permissions to get user's email account from ID Token:

```swift
LoginManager.shared.login(permissions: [.openID, .email], in: self) {
    result in
    switch result {
    case .success(let loginResult):
        if let email = loginResult.accessToken.IDToken?.payload.email {
            print("User Email: \(email)")
        }
    case .failure(let error):
        print(error)
    }
}
```

An ID Token itself is a signed [JSON Web Token][jwt]. LINE SDK Swift will validate the token by checking its signature and expiration date for you, to prevent any malformed data in it.

### Treating Users' Data Carefully

You should **never** save any user's sensitive data in plain text in your app or server, or transit them through non-secured HTTP. These data include access token, user ID, user name, and any information in the ID Token. LINE SDK Swift will store user's access token in the keychain. If needed, you could access it after authorized:

```swift
if let tokenPayload = AccessTokenStore.shared.current?.IDToken?.payload {
    // If you have `.email` permission.
    print("User Email: \(tokenPayload.email ?? "nil")")
    // If you have `.profile` permission.
    print("User Name: \(tokenPayload.name ?? "nil")")
}
```

ID Token will be only issued when login. If you need to upgrade the ID Token, you have to ask your user authorize again. However, if you have `.profile` permission, you could call `API.getProfile` to update user's basic information.

## Token Refresh

A valid token will be stored in keychain after a successful authorization. It would be used by LINE SDK Swift to make other API requests if needed. Every token has an expiration date. You could confirm it by:

```swift
if let token = AccessTokenStore.shared.current {
    print("Token expires at:\(token.expiresAt)")
}
```

When making an API request, LINE SDK Swift is smart enough to refresh the token if it finds the token has expired automatically. That means usually you do not need to worry about the token expiration. However, the refresh will fail if the token has expired for a long time. In that case, you will get an error and you cannot use LINE APIs until your user login again.

You can also manually refresh the token by invoking:

```swift
API.refreshAccessToken { result in
    switch result {
    case .success(let token):
        print("Token Refreshed: \(token)")
    case .failure(let error):
        print(error)
    }
}
```

However, we **do not recommend** you to do this yourself. Let LINE SDK Swift to manage your token lifetime would be easier and safer for future upgrading.

## Logout

As soon as you do not need the authorization (for example, your user logs out from your service, or you have finished to build your own user management system and will not use LINE API anymore in client), you should logout your from LINE as well. To do so, you need to call this to revoke current token and clean the user state:

```swift
LoginManager.shared.logout { result in
    switch result {
    case .success:
        print("Logout from LINE")
    case .failure(let error):
        print(error)
    }
}
```

## Next Step

We also have some additional features like [Graph APIs][graph-apis] and [Sending Messages][sending-messages]. However, they are now still in closed alpha, only for internal parter using. They are not yet prepared for public and we do not accept apply for them yet. Please keep an eye on it and we will inform if the state changes in future.

Remember to check the [Error Handling Guide][error-handling] to make sure you provide a good experience to your users when something wrong happens. We provide some guidelines and steps there to describe the best practice of handling errors from LINE SDK Swift.

If you want to use LINE SDK Swift in Objective-C, read the [Using with Objective-C Guide][using-objc].

There are also some other great resources for you to use LINE SDK Swift better in your app:

- Have some questions: [LINE SDK Swift FAQ][faq]
- More detail of SDK API: [API Reference][api-ref]
- Want to upgrade to LINE SDK Swift from a previous version: [Migration Guide][migration-guide]
- What happens in each version: [Release Notes][release-notes]

[login-guide]: /docs/ios-sdk-swift/login
[open-id]: http://openid.net/connect/
[console]: /console/
[jwt]: https://jwt.io
[graph-apis]: /docs/ios-sdk-swift/graph-apis
[sending-messages]: /docs/ios-sdk-swift/sending-messages
[error-handling]: /docs/ios-sdk-swift/error-handling
[using-objc]: /docs/ios-sdk-swift/using-objc
[faq]: /docs/ios-sdk-swift/faq
[api-ref]: /reference/ios-sdk-swift/
[migration-guide]: /docs/ios-sdk-swift/migration-guide
[release-notes]: /docs/ios-sdk-swift/release-notes