//
//  ShareTargetSearchController.swift
//
//  Copyright (c) 2016-present, LINE Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LINE Corporation.
//
//  As with any software that integrates with the LINE Corporation platform, your use of this software
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

import UIKit

class ShareTargetSearchController: UISearchController {

    enum Design {
        static var searchBarTintColor: UIColor {
            return .compatibleColor(light: 0x283145, dark: 0xffffff)
        }
        static var searchBarBackgroundColor: UIColor {
            return .compatibleColor(light: .init(hex6: 0xEAEAEE), dark: .LineSDKSystemBackground)
        }
    }

    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        setupSearchBar()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSearchBar() {
        updateColorAppearance()
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.spellCheckingType = .no
        searchBar.returnKeyType = .done
        searchBar.placeholder = Localization.string("friends.share.search")
    }

    func updateColorAppearance() {
        let searchBarBackgroundImage = Design.searchBarBackgroundColor.image()
        [UIBarPosition.top, .topAttached]     .forEach { position in
        [UIBarMetrics.default, .defaultPrompt].forEach { metrics in
            searchBar.setBackgroundImage(searchBarBackgroundImage, for: position, barMetrics: metrics)
        }}
        searchBar.tintColor = Design.searchBarTintColor
    }
}
