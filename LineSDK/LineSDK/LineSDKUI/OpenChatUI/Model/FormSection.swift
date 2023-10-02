//
//  FormSection.swift
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

struct FormSection {
    let formEntries: [FormEntry]
    let footerText: String?
    
    var renderer: FormSectionRenderer!
    
    init(entries: [FormEntry], footerText: String?) {
        self.formEntries = entries
        self.footerText = footerText
        
        self.renderer = FormSectionRenderer(section: self)
    }
}

class FormSectionRenderer {
    
    let section: FormSection
    var footerContentInsets = UIEdgeInsets(top: 7, left: 15, bottom: 24, right: 15)
    lazy var footerView = renderFooterView()
    
    private lazy var footerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = self.section.footerText
        return label
    }()
    
    init(section: FormSection) {
        self.section = section
    }
    
    private func renderFooterView() -> UIView {
        let footerView = UIView()
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        footerView.addSubview(footerLabel)
        NSLayoutConstraint.activate([
            footerLabel.topAnchor
                .constraint(equalTo: footerView.topAnchor, constant: footerContentInsets.top),
            footerLabel.bottomAnchor
                .constraint(equalTo: footerView.bottomAnchor, constant: -footerContentInsets.bottom),
            footerLabel.leadingAnchor
                .constraint(equalTo: footerView.safeLeadingAnchor, constant: footerContentInsets.left),
            footerLabel.trailingAnchor
                .constraint(equalTo: footerView.safeTrailingAnchor,constant: -footerContentInsets.right)
        ])
        
        return footerView
    }
    
    func heightOfFooterView(in width: CGFloat) -> CGFloat {
        
        let heightMargin = footerContentInsets.top + footerContentInsets.bottom
        if section.footerText == nil {
            return heightMargin
        }
        
        let widthMargin = footerContentInsets.left + footerContentInsets.right

        let size = footerLabel.sizeThatFits(.init(width: width - widthMargin, height: .greatestFiniteMagnitude))
        return size.height + heightMargin
    }
}
