//
//  LoadingIndicator.swift
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

class LoadingIndicator {

    static var indicators = NSMapTable<UIView, LoadingIndicator>.weakToStrongObjects()

    var count: Int
    let container: UIView
    let indicator: UIActivityIndicatorView

    weak var ownerView: UIView?

    static func add(to view: UIView) -> LoadingIndicator {
        if let indicator = indicators.object(forKey: view) {
            indicator.count += 1
            return indicator
        } else {
            let indicator = LoadingIndicator()
            indicator.add(to: view)
            indicators.setObject(indicator, forKey: view)
            return indicator
        }
    }

    init() {
        count = 1
        container = UIView()
        indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .gray
    }

    func add(to view: UIView) {

        indicator.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            ])

        view.addChildSubview(container)
        indicator.startAnimating()

        ownerView = view
    }

    func remove() {
        guard let ownerView = ownerView,
              let indicator = LoadingIndicator.indicators.object(forKey: ownerView) else
        {
            return
        }

        indicator.count -= 1
        if indicator.count <= 0 {
            container.removeFromSuperview()
            LoadingIndicator.indicators.removeObject(forKey: ownerView)
        }
    }
}
