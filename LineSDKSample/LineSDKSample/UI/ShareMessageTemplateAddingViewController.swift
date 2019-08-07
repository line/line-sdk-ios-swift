//
//  ShareMessageTemplateAddingViewController.swift
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

class ShareMessageTemplateAddingViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func done(_ sender: Any) {
        let data = textView.text.data(using: .utf8)!
        do {
            let container = try JSONDecoder().decode(FlexMessageContainer.self, from: data)
            let nameAlert = UIAlertController(
                title: "Name", message: "Specify a name for this message.", preferredStyle: .alert)
            nameAlert.addTextField { t in
                t.placeholder = "Untitled"
            }
            nameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            nameAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                if let name = nameAlert.textFields?.first?.text, !name.isEmpty {
                    let message = FlexMessage(altText: name, container: container).message
                    MessageStore.shared.insert(message, name: name)

                    self.dismiss(animated: true)
                }
            }))
            present(nameAlert, animated: true)
        } catch {
            UIAlertController.present(in: self, error: error)
        }

    }
}
