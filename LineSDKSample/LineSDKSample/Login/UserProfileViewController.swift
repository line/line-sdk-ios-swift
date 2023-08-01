//
//  UserProfileViewController.swift
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

extension Notification.Name {
    static let userDidLogout = Notification.Name("com.linecorp.linesdk_sample.userDidLogout")
}

class UserProfileViewController: UIViewController, IndicatorDisplay {

    var userProfile: UserProfile?
    var needsLoadProfile = false
    
    @IBOutlet weak var userAvatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel! {
        didSet { nameLabel.text = "" }
    }
    @IBOutlet weak var statusMessageLabel: UILabel! {
        didSet { statusMessageLabel.text = "" }
    }
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if needsLoadProfile {
            showIndicator()
            API.getProfile { result in
                self.hideIndicator()
                switch result {
                case .success(let profile):
                    self.userProfile = profile
                    self.reloadData()
                case .failure(let error):
                    self.displayErrorMessage(error.localizedDescription)
                    UIAlertController.present(in: self, error: error)
                }
            }
        } else {
            reloadData()
        }
    }
    
    func reloadData() {
        guard let userProfile = userProfile else {
            displayErrorMessage("Cannot get profile due to lack of profile permission.")
            return
        }
        
        if let imageURL = userProfile.pictureURL {
            DispatchQueue(label: "profile_image_download").async {
                if let imageData = try? Data(contentsOf: imageURL),
                   let image = UIImage(data: imageData)
                {
                    DispatchQueue.main.async {
                        self.userAvatarImageView.image = image
                    }
                }
            }
        }
        
        nameLabel.text = userProfile.displayName
        statusMessageLabel.text = userProfile.statusMessage ?? "Status Message: N/A"
    }
    
    func displayErrorMessage(_ message: String) {
        errorMessageLabel.isHidden = false
        errorMessageLabel.text = message
    }
    
    @IBAction func logout(_ sender: Any) {
        UIAlertController.present(
            in: self,
            title: "Logout",
            message: "Do you really want to log out?",
            actions: [
                .init(title: "Cancel", style: .cancel),
                .init(title: "Logout", style: .destructive) { _ in
                    self.logout()
                }
            ])
    }
    
    private func logout() {
        showIndicator()
        LoginManager.shared.logout { result in
            self.hideIndicator()
            switch result {
            case .success:
                UIAlertController.present(in: self, successResult: "Logout Successfully.") {
                    NotificationCenter.default.post(name: .userDidLogout, object: nil)
                }
            case .failure(let error):
                UIAlertController.present(in: self, error: error)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showDetail" {
            let viewController = segue.destination as! UserDetailViewController
            viewController.profile = userProfile
            viewController.token = AccessTokenStore.shared.current
        }
    }
}
