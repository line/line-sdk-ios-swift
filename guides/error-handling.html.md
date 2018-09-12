---
title: "Error Handling"
description: "LINE SDK Swift was built with fully error-friendly. It reports errors as detailed as possible. Handling the reported errors to let your user understands what is happening in SDK."
---

## Overview

When we built LINE SDK Swift, we took the consideration of error handling from the first second. The SDK reports all its potential errors with enough information to you, so you have a chance to implement elegant error handling in your final product.

All of APIs in LINE SDK Swift have a `Result` enum as its response, in which there might be the `.failure` case with an associated error:

```swift
API.getProfile { result in
    switch result {
    case .success(let profile):
        print(profile.displayName)
    case .failure(let error):
        print(error)
        // Handle the error
    }
}
```

In the sample code of the documentation, we just print out the error. The printed log indicates the reason of the error with a human-readable sentence. It is a good starting point for us to know what happens quickly, but it is not enough if you are implementing a final product. We need more information and more actions to handle the error.

## Error Type and Error Reason

Any error reported by LINE SDK Swift is an instance of `LineSDKError`, which is an enum conforming to `Swift.Error`. The enum member represents a reason category to indicate in which phase and for what reason the error happens. Currently, there are four categories of error reason:

- `.requestFailed(reason: RequestErrorReason)`: Errors happening while creating an API request. It might be invalid parameters or lack of access token.
- `.responseFailed(reason: ResponseErrorReason)`: Errors happening after receiving the server response. It might be incorrect response or networking errors.
- `.authorizeFailed(reason: AuthorizeErrorReason)`: Errors happening during authorization process. For example user cancels the process or ID token verification fails.
- `.generalError(reason: GeneralErrorReason)`: Other general error reasons, like data-string conversion fails or parameter does not meet precondition.

Each error reason category is associated with a detail reason (`RequestErrorReason`, `ResponseErrorReason`, `AuthorizeErrorReason` or `GeneralErrorReason`), which in turn is an `enum` as well. In these reasons enums, a detailed reason member is contained with necessary information or underlying `Error` from system.

To help you have an intuitive impression of what a reason look like, below we paste the snippet of `ResponseErrorReason`:

```swift
public enum ResponseErrorReason {
    // Error happens in the underlying `URLSession`. Code 2001.
    case URLSessionError(Error)
    // The response is not a valid `HTTPURLResponse`. Code 2002.
    case nonHTTPURLResponse
    // Cannot parse received data to an instance of target type. Code 2003.
    case dataParsingFailed(Any.Type, Data, Error)
    // Received response contains an invalid HTTP status code. Code 2004.
    case invalidHTTPStatusAPIError(code: Int, error: APIError?, raw: String?)
}
```

> It is just for demonstrating purpose, the final code may not be the same as above.

## Getting Error Data

To get the detail information from the top level `LineSDKError`, you can use Swift pattern match to extract associated data from an error. As an example, we check if an error is an invalid HTTP status code from server:

```swift
case .failure(let error):
    if let sdkError = error as? LineSDKError,
       case .responseFailed(
        reason: .invalidHTTPStatusAPIError(
            code: let code, error: let apiError, raw: let raw)) = sdkError
    {
        print("HTTP Status Code: \(code)")
        print("API Error Detail: \(apiError?.detail ?? "nil")")
        print("Raw Response: \(raw ?? "nil")")
    }
```

You should determine what to do based on error type and reason. For example, if an `.invalidHTTPStatusAPIError` happens, you need to check its `code`. If it is `500`, it means a server error and you might have little to do expect for showing some pop-up. However, if it is `403`, it means your current token has no enough permission to access current API. In this case, you will need to prompt your user to login again with proper required login permission for that failing API:

```swift
case .failure(let error):
    if let sdkError = error as? LineSDKError,
       case .responseFailed(
        reason: .invalidHTTPStatusAPIError(
            code: let code, error: let apiError, raw: let raw)) = sdkError
    {
        if code == 500 {
            showAlert("LINE API Server Error: \(raw ?? "nil")")
        } else if code == 403 {
            showAlert("Not enough permission. Login again?") {
                self.navigateToLoginViewController()
            }
        }
    }
```

## Using Shortcut to Handle Common Errors

There are quite a few common errors might happen in LINE SDK Swift. We prepared several shortcuts for you to identify them quickly. Call them on the error to reduce your work on pattern matching the returned error:

```swift
case .failure(let error):
    if let sdkError = error as? LineSDKError {
        if sdkError.isUserCancelled {
            // User cancelled the login process himself/herself.
            
        } else if sdkError.isPermissionError {
            // Equivalent to checking .responseFailed.invalidHTTPStatusAPIError 
            // with code 403. Should login again.
            
        } else if sdkError.isURLSessionTimeout {
            // Underlying request timeout in URL session. Should try again later.
            
        } else if /* other condition */ {
            // You could also extend LineSDKError to make your own shortcuts.
            
        } else {
            // Any other errors.
            showAlert("\(sdkError)")
        }
    }
```

> By using shortcuts to handle common errors, it will be easier for you to abstract your error handling code to the same place. It depends on your app architecture to decide how to make error handling simpler. A common and widely accepted idea is, do not repeat it here and there. A concentrated code path for all error handling is proved usually a better approach.

## Error Code and User Info

`LineSDKError` conforms to `CustomNSError` and `LocalizedError`. Each error reason has its own `errorCode` and `errorUserInfo`, to help you identify the error type and important values contained.

All errors from LINE SDK Swift are under the domain `LineSDKError.errorDomain` value. It is useful when you want to handle `LineSDKError` outside of the scope of LINE SDK Swift, since it is fully compatible with `NSError`.

## Conclusion

Error handling is never an easy thing, but it definitely worth your time on it, to provide an excellent experience for your user to use both your app and LINE SDK Swift.

Remember to check [API reference on `LineSDKError`][error-api-reference] and its reason cases to know the error code of each error. Please note that with evolution of LINE SDK Swift, more errors might be added to the SDK. For any noticeable changes, we will list them in the [release notes][release-note]. Make sure to check it before you upgrade to see whether you need to upgrade your error handling methods or not.

<!--TODO onevcat: Update error api reference link-->
[error-api-reference]: #
[release-note]: /docs/ios-sdk-swift/release-notes