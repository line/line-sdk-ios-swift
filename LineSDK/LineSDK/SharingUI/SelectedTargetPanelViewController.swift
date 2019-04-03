//
//  ShareTargetDisplayViewController.swift
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

class SelectedTargetPanelViewController: UIViewController {
    enum Design {
        static var height: CGFloat { return 79 }
        static var bgColor: UIColor { return .init(hex6: 0xF7F8FA) }
        static var borderColor: UIColor { return .init(hex6: 0xE6E7EA) }
        static var borderWidth: CGFloat { return 0.5 }
    }

    private var slideAnimationViewTopConstraint: NSLayoutConstraint!

    private let slideAnimationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = Design.bgColor
        view.layer.borderWidth = Design.borderWidth
        view.layer.borderColor = Design.borderColor.cgColor
        return view
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .horizontal
        layout.itemSize = SelectedTargetPanelCell.Design.size

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Design.bgColor
        collectionView.alwaysBounceHorizontal = true
        collectionView.scrollsToTop = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionView.register(
            SelectedTargetPanelCell.self,
            forCellWithReuseIdentifier: SelectedTargetPanelCell.reuseIdentifier
        )
        return collectionView
    }()

    // Observers
    private var selectingObserver: NotificationToken!
    private var deselectingObserver: NotificationToken!
    private let store: ColumnDataStore<ShareTarget>

    deinit {
        print(#file, #function)
    }

    init(store: ColumnDataStore<ShareTarget>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupSubviews()
        setupLayouts()
        setupObservers()
        setMode(.hide, animated: false)
    }

    private func setupSubviews() {
        view.addSubview(slideAnimationView)

        collectionView.dataSource = self
        collectionView.delegate = self
        slideAnimationView.addSubview(collectionView)
    }

    private func setupLayouts() {
        slideAnimationView.translatesAutoresizingMaskIntoConstraints = false
        slideAnimationViewTopConstraint = slideAnimationView.topAnchor.constraint(equalTo: view.topAnchor)
        slideAnimationViewTopConstraint.isActive = true
        NSLayoutConstraint.activate([
            slideAnimationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            slideAnimationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            slideAnimationView.heightAnchor.constraint(equalTo: view.heightAnchor)
            ])

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: slideAnimationView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: slideAnimationView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: slideAnimationView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: Design.height)
            ])
    }

    private func setupObservers() {
        selectingObserver = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidSelect, object: store, queue: nil)
        {
            [unowned self] noti in
            self.handleSelectingChange(noti)
        }

        deselectingObserver = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidDeselect, object: store, queue: nil)
        {
            [unowned self] noti in
            self.handleSelectingChange(noti)
        }
    }

    private func handleSelectingChange(_ notification: Notification) {
        if store.selected.isEmpty {
            setMode(.hide, animated: true)
        } else {
            setMode(.show, animated: true)
        }
    }

    enum Mode {
        case show
        case hide
    }

    private func setMode(_ mode: Mode, animated: Bool) {
        self.mode = mode
        collectionView.reloadData()
        updateLayout(animated: animated)
    }

    private(set) var mode = Mode.hide

    private func updateLayout(animated: Bool) {
        self.slideAnimationViewTopConstraint.isActive = false
        let anchor: NSLayoutYAxisAnchor
        let alpha: CGFloat
        switch self.mode {
        case .show:
            anchor = view.topAnchor
            view.isUserInteractionEnabled = true
            alpha = 1
        case .hide:
            anchor = view.bottomAnchor
            view.isUserInteractionEnabled = false
            alpha = 0
        }
        self.slideAnimationViewTopConstraint = slideAnimationView.topAnchor.constraint(equalTo: anchor)
        self.slideAnimationViewTopConstraint.isActive = true

        if animated {
            UIView.animate(withDuration: 0.2) {
                self.view.alpha = alpha
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.alpha = alpha
            self.view.layoutIfNeeded()
        }
    }
}

extension SelectedTargetPanelViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.selected.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedTargetPanelCell.reuseIdentifier,
                                                      for: indexPath) as! SelectedTargetPanelCell
        let target = store.allSelectedData[indexPath.item]
        cell.setShareTarget(target)
        return cell
    }
}
