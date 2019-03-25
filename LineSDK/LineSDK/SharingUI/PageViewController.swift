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

    struct Page {
        let viewController: UIViewController
        let title: String
    }

    private lazy var pageContainerView: UIView = {
        let pageContainerView = UIView()
        return pageContainerView
    }()

    private lazy var pageTabView: PageTabView = {
        let pageTabView = PageTabView(titles: pages.map { $0.title })
        view.addSubview(pageTabView)
        pageTabView.delegate = self

        return pageTabView
    }()

    let pages: [Page]

    private lazy var pageViewController: UIPageViewController = {
        return UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }()

    private lazy var pageScrollView: UIScrollView? = {
        let scrollView = (pageViewController.view.subviews.first { $0 is UIScrollView }) as? UIScrollView
        scrollView?.delegate = self
        return scrollView
    }()

    private var pageScrollViewObserver: NSKeyValueObservation?

    init(pages: [Page]) {
        self.pages = pages
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupPageViewController()
        setupSubviews()
        setupLayouts()

        pageTabView.resetUnderline()

        pageScrollViewObserver = pageScrollView?.observe(\.contentOffset, options: [.new]) { [weak self] scrollView, change in
            guard let self = self else { return }
            guard let newValue = change.newValue else { return }
            let width = self.pageViewController.view.bounds.width
            let progress = (newValue.x - width) / width
            self.pageTabView.updateScrollingProgress(progress)
        }
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
        pageViewController.delegate = self

        addChild(pageViewController, to: pageContainerView)
    }

    private func setupSubviews() {
        view.addSubview(pageContainerView)
        view.addSubview(pageTabView)
    }

    private func setupLayouts() {

        pageContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageContainerView.topAnchor     .constraint(equalTo: pageTabView.bottomAnchor),
            pageContainerView.leadingAnchor .constraint(equalTo: view.leadingAnchor),
            pageContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageContainerView.bottomAnchor  .constraint(equalTo: view.bottomAnchor)
            ])

        pageTabView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageTabView.heightAnchor  .constraint(equalToConstant: 45),
            pageTabView.leadingAnchor .constraint(equalTo: view.leadingAnchor),
            pageTabView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageTabView.topAnchor     .constraint(equalTo: safeTopAnchor)
            ])

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

extension PageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let index = currentViewControllerIndex else {
            return
        }
        pageTabView.updateSelectedIndex(index)
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

        pageViewController.setViewControllers([pages[index].viewController], direction: direction, animated: true)
    }
}

extension PageViewController: UIScrollViewDelegate {
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageTabView.resetSpacingFactor()
    }
}
