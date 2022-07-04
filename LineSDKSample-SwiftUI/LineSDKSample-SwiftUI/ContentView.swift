//
//  ContentView.swift
//  LineSDKSwiftUISample
//
//  Created by mrfour on 2022/6/21.
//

import LineSDK
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authorizationStore: AuthorizationStore

    var body: some View {
        NavigationView {
            if authorizationStore.isAuthorized {
                ProfileView()
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
