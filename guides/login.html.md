---
title: "Integrating LINE Login"
description: "Using LINE Login to get authorized from your potential users"
---

As soon as you [installed LINE SDK Swift][installation], you could start to use it for user login with LINE.

## Importing LineSDK and Channel ID Setup

To post-process the results from login actions, you need to setup LINE SDK Swift in your `AppDelegate.swift`.

1. Importing LineSDK

    At the head of your `AppDelegate.swift`, import `LineSDK`:
    
    ```swift
    // AppDelegate.swift
    import LineSDK
    ```
    
    You will need also import LineSDK if you want to use it in other files.

2. Calling `LoginManager.setup`

    The first thing you need to do is calling `LoginManager.setup` method as soon as your app launched:
    
    ```swift
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Add this to your "didFinishLaunching" delegate method.
        LoginManager.shared.setup(channelID: "YOUR_CHANNEL_ID", universalLinkURL: nil)
        
        return true
    }
    ```
    
    If you setup universal link in LINE Developers console, you also need to call `setup` with the `universalLinkURL` parameter. This will enable LINE iOS app to open your app with your own universal link, which make your login process much safer. For example, if you set "https://yourdomain.com/line-auth" as your universal callback link, you need to call:
    
    ```swift
    let link = URL(string: "https://yourdomain.com/line-auth")
    LoginManager.shared.setup(channelID: "YOUR_CHANNEL_ID", universalLinkURL: link)
    ```
    
    > For more information on how to adapt to login with universal link, see the "Universal Link Support" section below.
    
    <div class="Md108FrameNote">
    <p><span class="Md07TextBold">Note: </span>You should make sure to call the setup method <b>before</b> you access any other properties or call any other methods in LINE SDK Swift.</p>
    </div>
    
3. Handling Login Result

    To handle the returned result of the authentication process from LINE, add this to your `application(_:open:options:)` delegate method in `AppDelegate.swift`:

    ```swift
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return LoginManager.shared.application(app, open: url, options: options)
    }
    ```
    
## Performing Login

To perform a login process, call `LoginManager.login` method with proper parameters. A typical login process might happen in a view controller:

```swift
// LoginViewController.swift

import LineSDK

class LoginViewController: UIViewController {
    override func viewDidLoad() {
        //...
    }
    
    func login() {
        LoginManager.shared.login(permissions: [.profile], in: self) {
            result in
            switch result {
            case .success(let loginResult):
                print(loginResult.accessToken.value)
                // Do other things you need with the login result
            case .failure(let error):
                print(error)
            }
        }
    }
}
```

LINE SDK Swift chooses the most convenient and safe way to let your users login with LINE. Once they have done with login, regardless of succeeded or not, the `completion` handler will be called with the result. You could switch on the result for login details.

If everything goes fine, you could get a `LoginResult` object, in which some common login information is contained. The authorized session will be kept for you, and you could use `LoginManager.shared.isAuthorized` to check it.

> You could access the APIs with issued token with correct permissions. All tokens has an expiration date. LINE SDK Swift will handle the token refreshing for you when necessary. If the token expires AND the refreshing fails (due to the `refreshToken` also expires), you have to ask your user to login again to get authorization.

If an error happens during login process, the `result` will be `.failure`, associated with an `LineSDKError`. Check [Error Handling Guide][error-handling] to know how to get detail information with the errors from SDK, as well as how to handle them correctly.

### Login Button

Besides of creating your own login UI and calling `LoginManager.login` method yourself, LINE SDK Swift also provide a pre-defined login button. `LoginButton` is a subclass of `UIButton`, which follows [LINE Login button design guidelines][login-button-guideline] to style itself. You could add a login button to your app's UI to provide a quick way for user login:

```swift
// In your view controller
override func viewDidLoad() {
    super.viewDidLoad()

    // Create Login Button.
    let loginBtn = LoginButton()
    loginBtn.delegate = self
    
    // Configuration for permissions and presenting.
    loginBtn.permissions = [.profile]
    loginBtn.presentingViewController = self
    
    // Add button to view and layout it.
    view.addSubview(loginBtn)
    oginBtn.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint(item: loginBtn,
                       attribute: .centerX,
                       relatedBy: .equal,
                       toItem: view,
                       attribute: .centerX,
                       multiplier: 1,
                       constant: 0).isActive = true
    NSLayoutConstraint(item: loginBtn,
                       attribute: .centerY,
                       relatedBy: .equal,
                       toItem: view,
                       attribute: .centerY,
                       multiplier: 1,
                       constant: 0).isActive = true
}
```

Then you need to implement related delegate methods from `LoginButtonDelegate`:

```swift
extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        hideIndicator()
        print("Login Successd.")
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: Error) {
        hideIndicator()
        print("Error: \(error)")
    }
    
    func loginButtonDidStartLogin(_ button: LoginButton) {
        showIndicator()
        print("Login Started.")
    }
}
```

## Using Login Result

### Token Permissions

Although you could specify what the permissions you want your user authorize to you when you call `LoginManager.login` method, it is possible that your channel does not contain the required permissions. In this case, the `permissions` inside `loginResult` may be different from what you requested.

You could check the authorized permissions associated to the access token by accessing the `permissions` property. For example, checking whether a `.profile` permission is contained in the token:

```swift
case .success(let loginResult):
    let profileEnabled = loginResult.permissions.contains(.profile)
```

Calling an API without enough permission will result an error. See [Error Handling Guide][error-handling] for more about this topic.

### User Profile

If you contains `.profile` in the login permissions, a `userProfile` object will be contained in the login result. By accessing information like user ID, user name and avatar picture URL from the profile, you can construct your own user system:

```swift
LoginManager.shared.login(permissions: [.profile], in: self) { 
    result in
    switch result {
    case .success(let loginResult):
        if let profile = loginResult.userProfile {
            print("User ID: \(profile.userID)")
            print("User Display Name: \(profile.displayName)")
            print("User Icon: \(String(describing: profile.pictureURL))")
        }
    case .failure(let error):
        print(error)
    }
}
```

Feel free to store things from user profile for later use. The user ID is a per-channel encrypted ID. It would be different in another channel even when the same user authorizes. So do not try to use it to identify users across different channels.

## Universal Link Support

Universal link is a unique, secure and private way to communicate information between apps. LINE Login supports to open your app from a predefined universal link when login with LINE client. If you setup your universal link, the LINE app will try to open the universal link first. If the universal link failed due to some reason, custom URL scheme will be used as a fallback.

> Universal Link Opening for your app only works when login with the latest LINE app, and it is an opt-in feature to improve the security of your app.

Adding universal link opening is easy, you need several steps:

1. Create an `apple-app-site-association` file that contains JSON data about the URLs that your app can handle and put it in your HTTPS server.
2. Enable "Associated Domain" for your app and contain the entitlement to your app.
3. Setup universal link on LINE Developer Console.
4. Handle universal link opening in your app and resume login when universal link URL received.

For Step 1 and Step 2, please refer to Apple's documentation on [Support Universal Links][support-universal-links]. Below, we assume that you have already configured the support for universal links in your app, and you want to use "https://yourdomain.com/line-auth/" as the app link of handling LINE authorization response.

> That means at least you need to contain "/line-auth/*" in the "paths" of your `apple-app-site-association` file. An example valid JSON file looks like:
>
> ```json
> {
>     "applinks": {
>         "apps": [],
>         "details": [
>             {
>                 "appID": "YOUR_TEAM_ID.com.yourcompant.yourapp",
>                 "paths": [ "/line-auth/*" ]
>             }
>         ]
>     }
> }
> ```
>
> Please note that you can only test the universal link on a real iOS device. So you need to setup your app ID and profile correctly. If you thought you have set up universal links, but they don’t seem to be working, we suggest you check this [Debugging Universal Links][debug-universal-link] article. Before you start the next step, please make sure your universal link is working.

Navigate to the [LINE Developer Console][console] and find your channel page. In the "App settings" Tab, set "iOS universal link" to the value you want. In this case, we set it to "https://yourdomain.com/line-auth/".

Then, you need to pass this link to LINE SDK Swift when you call `LoginManager.setup` method. This will give LINE Login a chance to verify it is correctly setup on both Developer Console and your app, to prevent abusing of the universal link:

```swift
let link = URL(string: "https://yourdomain.com/line-auth")
LoginManager.shared.setup(channelID: "YOUR_CHANNEL_ID", universalLinkURL: link)
```

Finally, you need to handle the login result when your app is opened by a universal link. In the `AppDelegate.swift`, add code below:

```swift
func application(
    _ app: UIApplication, 
    continue userActivity: NSUserActivity, 
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool 
{
    if LoginManager.shared.application(app, open: userActivity.webpageURL) {
        return true
    }
    // Your other code to handle universal links and/or user activities.
}
```

Now, your app should be adapted to LINE Login universal link. LINE client will prefer to open your app with universal link.

## Next Step

LINE Login supports [OpenID Connect][open-id] protocol and allows you to retrieve user information with ID tokens. You may also need to logout your users as soon as you do not need the authorization anymore. To know more about these topics, check the [Managing User Identifier and Token Guide][managing-access-tokens].

[installation]: /docs/ios-sdk-swift/installation
[error-handling]: /docs/ios-sdk-swift/error-handling
[support-universal-links]: https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/UniversalLinks.html
[debug-universal-link]: http://building.usebutton.com/debugging/ios/deep-linking/links/universal-links/2016/03/31/debugging-universal-links/
[console]: /console/
[open-id]: http://openid.net/connect/
[managing-access-tokens]: /docs/ios-sdk-swift/managing-access-tokens
[login-button-guideline]: /docs/line-login/login-button
