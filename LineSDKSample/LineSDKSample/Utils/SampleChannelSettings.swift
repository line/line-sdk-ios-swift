//
//  SampleChannelSettings.swift
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

import Foundation

enum SampleChannelSettings {
    private static let channelStorageKey = "com.linecorp.linesdk.sample.channelID"
    private static var defaults: UserDefaults { .standard }

    static func resolveInitialChannelID(bundle: Bundle = .main) -> String? {
        if let stored = storedChannelID, isValid(channelID: stored) {
            return stored
        }

        guard let bundledID = bundle.infoDictionary?["LINE Channel ID"] as? String,
              isValid(channelID: bundledID)
        else {
            return nil
        }

        updateChannelID(bundledID)
        return bundledID
    }

    static var storedChannelID: String? {
        defaults.string(forKey: channelStorageKey)
    }

    static func updateChannelID(_ channelID: String) {
        defaults.set(channelID.trimmingCharacters(in: .whitespacesAndNewlines), forKey: channelStorageKey)
    }

    static func isValid(channelID: String) -> Bool {
        let trimmed = channelID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return Int(trimmed) != nil
    }
}

