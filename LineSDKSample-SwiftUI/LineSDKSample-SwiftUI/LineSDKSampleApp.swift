//
//  LineSDKSwiftUISampleApp.swift
//  LineSDKSwiftUISample
//
//  Created by mrfour on 2022/6/21.
//

import LineSDK
import SwiftUI

@main
struct LineSDKSampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthorizationStore())
                .onOpenURL { url in
                    let _ = LoginManager.shared.application(.shared, open: url)
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Modify Config.xcconfig to setup your LINE channel ID.
        if let channelID = Bundle.main.infoDictionary?["LINE Channel ID"] as? String,
           let _ = Int(channelID)
        {
            LoginManager.shared.setup(channelID: channelID, universalLinkURL: nil)
        } else {
            fatalError("Please set correct channel ID in Config.xcconfig file.")
        }

        return true
    }

    func application(
        _ application: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {
        return LoginManager.shared.application(application, open: url, options: options)
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        return LoginManager.shared.application(application, open: userActivity.webpageURL)
    }
}
