//
//  PageViewController.swift
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

class PageViewController: UIViewController {

    enum Design {
        static var backgroundColor: UIColor { return .LineSDKSystemBackground }
    }

    struct Page {
        let viewController: UIViewController
        let title: String
    }

    let pages: [Page]

    private var pageScrollViewObserver: NSKeyValueObservation?
    private var pageTabHeightConstraint: NSLayoutConstraint?

    private let pageContainerLayout = UILayoutGuide()

    private lazy var pageTabView: PageTabView = {
        let pageTabView = PageTabView(titles: pages.map { $0.title })
        pageTabView.clipsToBounds = true
        pageTabView.delegate = self

        return pageTabView
    }()

    private lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }()

    private lazy var pageScrollView: UIScrollView? = {
        let scrollView = (pageViewController.view.subviews.first { $0 is UIScrollView }) as? UIScrollView
        scrollView?.delegate = self
        return scrollView
    }()

    deinit {
        // https://bugs.swift.org/browse/SR-5752
        if #available(iOS 11.0, *) {} else {
            pageScrollViewObserver = nil
        }
    }

    init(pages: [Page]) {
        self.pages = pages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Design.backgroundColor

        setupSubviews()
        setupPageViewController()
        setupLayouts()

        pageScrollViewObserver = pageScrollView?.observe(\.contentOffset, options: [.new]) {
            [weak self] scrollView, change in

            guard let self = self else { return }
            self.pageTabView.updateScrollingProgress(self.tabProgress)
        }
    }

    private var tabProgress: CGFloat {
        guard let pageScrollView = pageScrollView else {
            return 0
        }
        let width = pageViewController.view.bounds.width
        return (pageScrollView.contentOffset.x - width) / width
    }

    private func setupPageViewController() {
        let initial: [UIViewController]? = {
            guard let firstPage = pages.first?.viewController else {
                return nil
            }
            return [firstPage]
        }()

        pageViewController.setViewControllers(initial, direction: .forward, animated: false)
        pageViewController.dataSource = self

        addChild(pageViewController, to: pageContainerLayout)
    }

    private func setupSubviews() {
        view.addLayoutGuide(pageContainerLayout)
        view.addSubview(pageTabView)
    }

    private func setupLayouts() {

        NSLayoutConstraint.activate([
            pageContainerLayout.topAnchor     .constraint(equalTo: pageTabView.bottomAnchor),
            pageContainerLayout.leadingAnchor .constraint(equalTo: view.leadingAnchor),
            pageContainerLayout.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainerLayout.bottomAnchor  .constraint(equalTo: view.bottomAnchor)
            ])

        pageTabView.translatesAutoresizingMaskIntoConstraints = false
        pageTabHeightConstraint = pageTabView.heightAnchor.constraint(
            equalToConstant: PageTabView.TabView.Design.height)
        NSLayoutConstraint.activate([
            pageTabHeightConstraint!,
            pageTabView.leadingAnchor .constraint(equalTo: view.leadingAnchor),
            pageTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageTabView.topAnchor     .constraint(equalTo: safeTopAnchor)
            ])
    }

    func setPageTabViewHidden(_ hidden: Bool) {
        pageTabHeightConstraint?.constant = hidden ? 0 : PageTabView.TabView.Design.height
        view.layoutIfNeeded()
    }
}

extension PageViewController {
    var currentViewControllerIndex: Int? {
        if let viewControllers = pageViewController.viewControllers,
            let currentViewController = viewControllers.first
        {
            return indexForViewController(currentViewController)
        }
        return nil
    }

    func indexForViewController(_ viewController: UIViewController) -> Int? {
        return pages.firstIndex { $0.viewController === viewController }
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController?
    {
        guard let index = indexForViewController(viewController) else { return nil }
        guard index != 0 else { return nil }
        return pages[index - 1].viewController
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController?
    {
        guard let index = indexForViewController(viewController) else { return nil }
        guard index != pages.count - 1 else { return nil }
        return pages[index + 1].viewController
    }
}

extension PageViewController: PageTabViewDelegate {
    func pageTabView(_ pageTabView: PageTabView, didSelectIndex index: Int) {
        let direction: UIPageViewController.NavigationDirection
        if let currentIndex = currentViewControllerIndex {
            direction = index >= currentIndex ? .forward : .reverse
        } else {
            assertionFailure("Cannot get current index for page view controller. It should not happen.")
            direction = .forward
        }
        // Prevents any interaction while the page is scrolling when triggered by page tab selecting.
        setUserInteractionEnabled(false)
        pageViewController.setViewControllers([pages[index].viewController], direction: direction, animated: true)
    }
}

extension PageViewController: UIScrollViewDelegate {
    // triggered when programmatically set the index of PageViewController and its animation ended
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageTabView.reset()
        setUserInteractionEnabled(true)
    }

    // In some cases, `pageViewController(_:didFinishAnimating:previousViewControllers:transitionCompleted:)` is not
    // called correctly by UIKit. To prevent that case, use `updateSelectedIndexForCurrentProgress` from
    // this delegate method.
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageTabView.updateSelectedIndexForCurrentProgress()
        setUserInteractionEnabled(true)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setUserInteractionEnabled(false)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // In some cases, dragging will not trigger a deceleration.
        // So we need to set interaction enabled immediately.
        // If `willDecelerate`, it is handled in `scrollViewDidEndDecelerating`
        if !decelerate {
            setUserInteractionEnabled(true)
        }
    }

    private func setUserInteractionEnabled(_ enabled: Bool) {
        pages.forEach { $0.viewController.view.isUserInteractionEnabled = enabled }
        view.isUserInteractionEnabled = enabled
        pageTabView.isUserInteractionEnabled = enabled
    }
}
