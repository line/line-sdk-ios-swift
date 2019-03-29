//
//  ShareViewController.swift
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

public class ShareViewController: UINavigationController {

    private lazy var selectedTargetView = SelectedTargetView()

    public init() {
        let v1 = UIViewController()
        v1.view.backgroundColor = .red
        let page1 = PageViewController.Page(viewController: v1, title: "A")
        let v2 = UIViewController()
        v2.view.backgroundColor = .yellow
        let page2 = PageViewController.Page(viewController: v2, title: "BB")
        let v3 = UIViewController()
        v3.view.backgroundColor = .blue
        let page3 = PageViewController.Page(viewController: v3, title: "CCC")

        let root = PageViewController(pages: [page1, page2, page3])
        root.pages.forEach { page in
            let label = UILabel()
            label.text = page.title
            label.sizeToFit()
            label.center = page.viewController.view.center
            page.viewController.view.addSubview(label)
        }
        super.init(rootViewController: root)
    }

    @objc
    func foo() {
        selectedTargetView.mode = (selectedTargetView.mode == .show) ? .hide : .show
        selectedTargetView.updateLayout(animated: true)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lift Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()

        setupLayouts()

        // default
        selectedTargetView.mode = .hide
        selectedTargetView.updateLayout(animated: false)

        // TODO: Remove this mocked entry
        let btn = UIButton(type: .system)
        btn.setTitleColor(.black, for: .normal)
        btn.setTitle("toggle SelectedTargetView", for: .normal)
        btn.addTarget(self, action: #selector(foo), for: .touchUpInside)
        btn.sizeToFit()
        btn.center = view.center
        self.view.addSubview(btn)
        //
    }

    private func setupSubviews() {
        view.addSubview(selectedTargetView)
    }

    private func setupLayouts() {
        selectedTargetView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedTargetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectedTargetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            selectedTargetView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectedTargetView.topAnchor.constraint(equalTo: safeBottomAnchor,
                                                    constant: -SelectedTargetView.Design.height)
            ])
    }
}
