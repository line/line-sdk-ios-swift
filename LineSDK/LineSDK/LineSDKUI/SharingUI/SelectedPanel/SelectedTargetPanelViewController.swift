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

    typealias ColumnIndex = ColumnDataStore<ShareTarget>.ColumnIndex

    enum Design {
        static var height:          CGFloat { return 79 }
        static var backgroundColor: UIColor { return .LineSDKPanelBackground }
        static var borderColor:     UIColor { return .LineSDKPanelBorder }
        static var borderWidth:     CGFloat { return 0.5 }

        // CollectionView
        static var minimumLineSpacing: CGFloat { return 10 }
    }

    var collectionViewContentOffset: CGPoint {
        get { return collectionView.contentOffset }
        set { collectionView.setContentOffset(newValue, animated: false) }
    }

    private var slideAnimationViewTopConstraint: NSLayoutConstraint!

    private let slideAnimationView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor   = Design.backgroundColor
        view.layer.borderWidth = Design.borderWidth
        view.layer.borderColor = Design.borderColor.cgColor
        return view
    }()

    private func updateColorAppearance() {
        slideAnimationView.layer.borderColor = Design.borderColor.cgColor
    }

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Design.minimumLineSpacing
        layout.scrollDirection = .horizontal
        layout.itemSize = SelectedTargetPanelCell.Design.size

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Design.backgroundColor
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

        setMode(modeFromSelection, animated: false)
    }

    private func setupSubviews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        slideAnimationView.addSubview(collectionView)
        view.addSubview(slideAnimationView)

        updateColorAppearance()
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
            self.handleSelectingChange(noti, isSelecting: true)
        }

        deselectingObserver = NotificationCenter.default.addObserver(
            forName: .columnDataStoreDidDeselect, object: store, queue: nil)
        {
            [unowned self] noti in
            self.handleSelectingChange(noti, isSelecting: false)
        }
    }

    private func handleSelectingChange(_ notification: Notification, isSelecting: Bool) {
        setMode(modeFromSelection, animated: true)

        guard let positionInSelected = notification.userInfo?[LineSDKNotificationKey.positionInSelected] as? Int else {
            return
        }

        let indexPath = IndexPath(row: positionInSelected, section: 0)
        collectionView.performBatchUpdates({
            if isSelecting {
                collectionView.insertItems(at: [indexPath])
            } else {
                collectionView.deleteItems(at: [indexPath])
            }
        }, completion: { _ in
            if isSelecting { self.scrollToLast() }
        })
    }

    private func scrollToLast() {
        guard !store.selectedIndexes.isEmpty else { return }
        let indexPath = IndexPath(item: store.selectedIndexes.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
    }

    private enum Mode {
        case show
        case hide
    }

    private var modeFromSelection: Mode {
        return store.selectedIndexes.isEmpty ? .hide : .show
    }

    private func setMode(_ mode: Mode, animated: Bool) {
        self.mode = mode
        updateLayout(animated: animated)
    }

    private var mode = Mode.hide

    private func updateLayout(animated: Bool) {
        slideAnimationViewTopConstraint.isActive = false
        let anchor: NSLayoutYAxisAnchor
        let alpha: CGFloat
        switch mode {
        case .show:
            anchor = view.topAnchor
            view.isUserInteractionEnabled = true
            alpha = 1
        case .hide:
            anchor = view.bottomAnchor
            view.isUserInteractionEnabled = false
            alpha = 0
        }
        slideAnimationViewTopConstraint = slideAnimationView.topAnchor.constraint(equalTo: anchor)
        slideAnimationViewTopConstraint.isActive = true

        func applyChange() {
            view.alpha = alpha
            view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: applyChange)
        } else {
            applyChange()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                self.updateColorAppearance()
            }
        }
        #endif
    }
}

extension SelectedTargetPanelViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return store.selectedIndexes.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectedTargetPanelCell.reuseIdentifier,
            for: indexPath) as! SelectedTargetPanelCell
        let target = store.data(at: store.selectedIndexes[indexPath.item])
        cell.setShareTarget(target)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let columnIndex = store.selectedIndexes[indexPath.item]
        store.toggleSelect(atColumn: columnIndex.column, row: columnIndex.row)
    }
}
