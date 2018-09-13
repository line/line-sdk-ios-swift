---
title: "Migration Guide"
description: "Describes noticeable changes and migration steps from an earlier version of LINE SDK to current version"
---

#### Upgrading to LINE SDK Swift 5.0.0

5.0.0 is the first version of LINE SDK Swift. It is not compatible with the [legacy Objective-C version of LINE SDK][objc-sdk].  If you were using that one, you need to change some of your code to migrate to the latest SDK.

The new LINE SDK Swift is designed for Swift. But it is still possible to use it with Objective-C. Check the [Using with Objective-C Guide][using-objc] and choose your way to use it in an Objective-C project.

Regardless of whether you were using legacy version in Swift or Objective-C, we suggest you to remove everything from the old version and do a clean installation from beginning, by following the [Installation Guide][installation]. However, if you want to make changes based on your current implementation, here is some general steps:

1. Remove the legacy `LineSDK.framework` from your code base. Basically if you used a package manager (like CocoaPods or Carthage), you need to remove the "LineSDK" entry from the package definition file (`Podfile` or `Cartfile`). Then do a clean to remove reference of `LineSDK.framework` from your project. If you used the downloaded binary, just remove it from your project.
2. Clean up your `Info.plist`. `LineSDKConfig` entry is not needed anymore in the `Info.plist` file. You can safely remove it now.
3. Install LINE SDK Swift. This is fully covered in the [Installation Guide][installation]. Please choose a way right for you to integrate and configure the `Info.plist` file of project 
4. Setup channel ID and callback handling in `AppDelegate`.
    Now, you need to call `LoginManager.setup` as soon as you app launches:
    
    ```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Add this to your "didFinishLaunching" delegate method.
        LoginManager.shared.setup(channelID: "YOUR_CHANNEL_ID", universalLinkURL: nil)
        
        return true
    }
    ```
    
    And update the open URL handling to:
    
    ```swift
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return LoginManager.shared.application(app, open: url, options: options)
    }
    ```
    
5. Upgrade legacy APIs to the latest:

    Now, you are ready to upgrade all other APIs from legacy SDK to the ones in LINE SDK Swift. Here is some common examples:
    
    #### Login with LINE
    
    ##### Previous
    
    ```objc
    - (void)login {
        [LineSDKLogin sharedInstance].delegate = self;
        [[LineSDKLogin sharedInstance] startLoginWithPermissions: @[@"profile"]];
    }
    
    
    - (void)didLogin:(LineSDKLogin *)login
          credential:(LineSDKCredential *)credential
             profile:(LineSDKProfile *)profile
               error:(NSError *)error
    {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSString * displayName = profile.displayName;
            NSLog(@"User name: %@", displayName)
        }
    }
    ```
    
    ##### Now
    
    ```swift
    LoginManager.shared.login(permissions: [.profile]) {
        result in
        switch result {
        case .success(let loginResult):
            print("User name: \(loginResult.userProfile?.displayName ?? "nil")")
        case .failure(let error):
            print("Error: \(error)")
        }
    }
    ```
    
    #### Getting User Profile
    
    ##### Previous
    
    ```objc
    LineSDKAPI *apiClient = [[LineSDKAPI alloc] initWithConfiguration:[LineSDKLogin sharedInstance].configuration];
    [apiClient getProfileWithCompletion:^(LineSDKProfile * _Nullable profile, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSString * displayName = profile.displayName;
            NSLog(@"User name: %@", displayName)
        }
    }];
    ```
    
    ##### Now
    
    ```swift
    API.getProfile { result in
        switch result {
        case .success(let profile):
            print("User name: \(profile.displayName)")
        case .failure(let error):
            print("Error: \(error)")
        }
    }
    ```
    
    #### Logout User
    
    ##### Previous
    
    ```objc
    LineSDKAPI *apiClient = [[LineSDKAPI alloc] initWithConfiguration:[LineSDKLogin sharedInstance].configuration];
    [apiClient logoutWithCompletion:^(BOOL success, NSError * _Nullable error){
        if (success){
            // Logout Succeeded
        } else {
            // Logout Failed
            NSLog(@"Logout Failed: %@", error.description);
        }
    }];
    ```
    
    ##### Now
    
    ```swift
    LoginManager.shared.logout { result in
        switch result {
        case .success:            print("Logout Succeeded")
        case .failure(let error): print("Logout Failed: \(error)")
        }
    }
    ```
    
    #### Getting Current Access Token

    ##### Previous
    
    ```objc
    LineSDKAPI *apiClient = [[LineSDKAPI alloc] initWithConfiguration:[LineSDKLogin sharedInstance].configuration];
    LineSDKAccessToken * accessTokenObject = [apiClient currentAccessToken];
    NSString * accessTokenString = accessTokenObject.accessToken;
    ```
    
    ##### Now
    
    ```swift
    let token = AccessTokenStore.shared.current?.value
    ```
    
    #### Verifying Access Token

    ##### Previous
    
    ```objc
    LineSDKAPI *apiClient = [[LineSDKAPI alloc] initWithConfiguration:[LineSDKLogin sharedInstance].configuration];
    [apiClient verifyTokenWithCompletion:^(LineSDKVerifyResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.description);
        } else {
            NSLog(@"Token is valid");
        }
    }];
    ```
    
    ##### Now
    
    ```swift
    API.verifyAccessToken { result in
        switch result {
        case .success: print("Token is valid.")
        case .failure(let error): print("Error: \(error)")
        }
    }
    ```

---

There might be a few other APIs not covered here. However, they should be following the similar conventions and you can easily find the corresponding types in LINE SDK Swift. Upgrade them to latest syntax to make your project compile.

We have a sample app to demonstrate for latest LINE SDK Swift. Please check the [open-sourcerepository][repository] to know the basic integration and usage.

[objc-sdk]: /docs/ios-sdk/
[using-objc]: /docs/ios-sdk-swift/using-objc
[installation]: /docs/ios-sdk-swift/installation
[repository]: https://github.com/line/line-sdk-swift