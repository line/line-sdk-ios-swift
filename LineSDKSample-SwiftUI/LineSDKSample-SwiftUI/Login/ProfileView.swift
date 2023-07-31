//
//  ProfileView.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
//  is subject to the LINE Developers Agreement [http://terms2.line.me/LINE_Developers_Agreement].
//  This copyright notice shall be included in all copies or substantial portions of the software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import LineSDK
import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authorizationStore: AuthorizationStore

    @State var profile: UserProfile?

    @State var logoutResult: Result<Void, LineSDKError>?

    @State var alertMessage: String?

    var body: some View {
        VStack {
            if let profile = profile {
                profileContent(profile)
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .navigationBarItems(leading: logoutButton)
        .onAppear {
            guard profile == nil else { return }

            Task {
                let result = await API.getProfile()
                switch result {
                case .success(let profile):
                    self.profile = profile
                case .failure(let error):
                    alertMessage = error.localizedDescription
                }
            }
        }
    }

    @ViewBuilder
    private func profileContent(_ profile: UserProfile) -> some View {
        AsyncImage(url: profile.pictureURL) { image in
            image.resizable()
        } placeholder: {
            Color.gray.opacity(0.1)
        }
        .frame(width: 150, height: 150)

        Text(profile.displayName)
            .font(.title2)

        Text("Status Message: \(profile.statusMessage ?? "N/A")")
            .font(.subheadline)
    }

    private var logoutButton: some View {
        Button("Logout") {
            Task {
                logoutResult = await LoginManager.shared.logout()
                authorizationStore.isAuthorized = false
            }
        }
    }
}
