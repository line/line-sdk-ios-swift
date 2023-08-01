//
//  IndicatorDisplay.swift
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

import UIKit

protocol IndicatorDisplay {
    func showIndicator(in view: UIView)
    func hideIndicator(from view: UIView)
}

class IndicatorHolderView: UIView {}

extension IndicatorDisplay where Self: UIViewController {
    func showIndicator() {
        showIndicator(in: view)
    }

    func showIndicatorOnWindow() {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        showIndicator(in: keyWindow ?? view)
    }
    
    func hideIndicator() {
        hideIndicator(from: view)
    }

    func hideIndicatorFromWindow() {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        hideIndicator(from: keyWindow ?? view)
    }
    
    func showIndicator(in view: UIView) {
        
        let holderView = IndicatorHolderView()
        
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        holderView.addSubview(indicator)
        
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.centerXAnchor.constraint(equalTo: holderView.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: holderView.centerYAnchor).isActive = true
        indicator.startAnimating()
        
        holderView.backgroundColor = .clear
        view.addSubview(holderView)
        
        holderView.translatesAutoresizingMaskIntoConstraints = false
        holderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        holderView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        holderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        holderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func hideIndicator(from view: UIView) {
        let holder = view.subviews.first { $0 is IndicatorHolderView }
        holder?.removeFromSuperview()
    }
}
