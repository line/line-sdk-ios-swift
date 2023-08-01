//
//  LoginNavigationController.swift
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
import LineSDK

class LoginNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if LoginManager.shared.isAuthorized {
            let viewController = storyboard!
                .instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
            viewController.needsLoadProfile = true
            viewControllers = [viewController]
        }
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(userDidLogin(_:)), name: .userDidLogin, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(userDidLogout(_:)), name: .userDidLogout, object: nil)
    }
    
    @objc func userDidLogin(_ noti: Notification) {
        let viewController = storyboard!
            .instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        let profile = (noti.object as! LoginResult).userProfile
        viewController.userProfile = profile
        viewControllers = [viewController]
    }
    
    @objc func userDidLogout(_ noti: Notification) {
        let viewController = storyboard!
            .instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        viewControllers = [viewController]
    }
}
