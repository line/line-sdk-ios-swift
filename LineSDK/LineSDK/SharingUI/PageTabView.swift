//
//  PageTabView.swift
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

protocol PageTabViewDelegate: AnyObject {
    func pageTabView(_ pageTabView: PageTabView, didSelectIndex index: Int)
}

class PageTabView: UIView {

    class TabView: UIControl {
        let index: Int

        let textLabel: UILabel

        init(title: String, index: Int) {
            self.index = index
            self.textLabel = {
                let label = UILabel(frame: .zero)
                label.text = title
                label.textAlignment = .center
                return label
            }()

            super.init(frame: .zero)
            setupViews()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setupViews() {
            addSubview(textLabel)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
                textLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8)
            ])
        }
    }

    class Underline: UIView {

        enum Design {
            static let height: CGFloat = 3
            static let widthMargin: CGFloat = 4
            static func color() -> UIColor { return .black }
        }

        private let underline: UIView = {
            let underline = UIView()
            underline.backgroundColor = Design.color()
            return underline
        }()

        init() {
            super.init(frame: .zero)
            backgroundColor = .clear
            addSubview(underline)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func setup(centerX: CGFloat, width: CGFloat) {
            underline.bounds.size = CGSize(width: width + Design.widthMargin,
                                           height: Design.height)
            underline.center = CGPoint(x: centerX, y: bounds.midY)
        }
    }

    lazy var underline = Underline()

    weak var delegate: PageTabViewDelegate?

    private (set) var selectedIndex = 0 {
        didSet {
            print("Tab selected: \(selectedIndex)")
        }
    }

    private let countOfTabs: Int

    private var tabCenterSpacing: CGFloat {
        return bounds.width / CGFloat(countOfTabs)
    }

    // Used when select index for multiple tabs.
    private var nextSpacingFactor: CGFloat = 1.0

    private var tabs: [TabView] = []

    init(titles: [String]) {

        precondition(!titles.isEmpty, "PageTabView does not accept empty titles.")

        countOfTabs = titles.count

        super.init(frame: .zero)

        var leading = leadingAnchor

        for (i, title) in titles.enumerated() {
            let tabView = TabView(title: title, index: i)
            addSubview(tabView)
            tabView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tabView.leadingAnchor.constraint(equalTo: leading),
                tabView.topAnchor.constraint(equalTo: topAnchor),
                tabView.bottomAnchor.constraint(equalTo: bottomAnchor),
                tabView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0 / CGFloat(titles.count))
            ])

            tabView.addTarget(self, action: #selector(tabViewTouchUpInside), for: .touchUpInside)
            tabs.append(tabView)
            
            leading = tabView.trailingAnchor
        }

        addSubview(underline)
        underline.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            underline.leadingAnchor.constraint(equalTo: leadingAnchor),
            underline.trailingAnchor.constraint(equalTo: trailingAnchor),
            underline.heightAnchor.constraint(equalToConstant: Underline.Design.height),
            underline.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }

    // Select a certain index.
    func selectIndex(_ index: Int) {
        if selectedIndex == index { return }
        nextSpacingFactor = abs(CGFloat(index) - CGFloat(selectedIndex))
        updateSelectedIndex(index)

        delegate?.pageTabView(self, didSelectIndex: index)
    }

    // This only update the `selectedIndex` property and update style when neccessary.
    func updateSelectedIndex(_ index: Int) {
        selectedIndex = index
    }

    func updateScrollingProgress(_ progress: CGFloat) {
        // UIPageViewController resets the content offset when new page displayed.
        // In this case, the `progress` is 0 and we fix it by using diff
        let diff = currentProgress - progress * nextSpacingFactor - currentDiff
        if abs(diff) > 0.5 { // process normally continuous
            currentDiff += diff.rounded()
        }
        currentProgress = progress * nextSpacingFactor + currentDiff

        let centerX = (0.5 + currentProgress) * (tabs.first?.frame.width ?? 0)
        let proportionalWidth: CGFloat = tabs
            .map { $0.textLabel.bounds.width }
            .enumerated()
            .reduce(0) { (res, arg) in
                let (index, w) = arg
                return res + w * (1 - min(1, abs(currentProgress - CGFloat(index))))
        }
        underline.setup(centerX: centerX, width: proportionalWidth)
    }

    private var currentProgress: CGFloat = 0

    private var currentDiff: CGFloat = 0

    func resetUnderline() {
        currentProgress = 0
        currentDiff = 0
        selectedIndex = 0
        updateScrollingProgress(0)
    }

    @objc func tabViewTouchUpInside(_ sender: TabView) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isUserInteractionEnabled = true
        }

        selectIndex(sender.index)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func resetSpacingFactor() {
        nextSpacingFactor = 1.0
    }
}
