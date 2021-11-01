//
//  TapViewControllerWithSearch.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 6/4/18.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import CoreGraphics
import struct TapAdditionsKitV2.TypeAlias
import protocol TapSearchViewV2.TapSearchUpdating
import class TapSearchViewV2.TapSearchView
import class UIKit.NSLayoutConstraint.NSLayoutConstraint
import class UIKit.UIColor.UIColor
import struct UIKit.UIGeometry.UIEdgeInsets
import class UIKit.UIScrollView.UIScrollView
import protocol UIKit.UIScrollView.UIScrollViewDelegate
import class UIKit.UITableView.UITableView
import class UIKit.UIView.UIView

open class TapViewControllerWithSearch: TapViewController {

    // MARK: - Open -
    // MARK: Methods

    open override func viewDidLoad() {

        super.viewDidLoad()
        self.navigationController?.navigationBar.isOpaque = false
    }

    open override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()
        self.updateTableViewContentInset()
    }

    open func searchViewTextChanged(_ text: String) {}

    // MARK: - Public -
    // MARK: Properties

    @IBOutlet public private(set) weak var tableView: UITableView? {

        didSet {

            if let nonnullTableView = self.tableView {

                self.tableViewLoaded(nonnullTableView)

                if let nonnullSearchView = self.searchView {

                    self.bothTableViewAndSearchViewLoaded(nonnullTableView, searchView: nonnullSearchView)
                }
            }
        }
    }

    @IBOutlet public private(set) weak var searchView: TapSearchView? {

        didSet {

            if let nonnullSearchView = self.searchView {

                self.searchViewLoaded(nonnullSearchView)

                if let nonnullTableView = self.tableView {

                    self.bothTableViewAndSearchViewLoaded(nonnullTableView, searchView: nonnullSearchView)
                }
            }
        }
    }

    // MARK: Methods

    public func tableViewLoaded(_ aTableView: UITableView) {

        if #available(iOS 11.0, *) {

            aTableView.contentInsetAdjustmentBehavior = .never
        }
    }

    public func searchViewLoaded(_ aSearchView: TapSearchView) {

        aSearchView.delegate = self

        aSearchView.layer.shadowOpacity = 0.0
        aSearchView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        aSearchView.layer.shadowRadius = 1.0
        aSearchView.layer.shadowColor = UIColor(tap_hex: "#B5B5B5A8")?.cgColor
    }

    public func bothTableViewAndSearchViewLoaded(_ aTableView: UITableView, searchView aSearchView: TapSearchView) {

        self.updateTableViewContentInset()
        aTableView.contentOffset = .zero
    }

    public func makeSearchViewVisible(_ visible: Bool, animated: Bool) {

        guard let nonnullHeightConstraint = self.searchViewHeightConstraint else { return }
        guard let maximalSearchHeight = self.searchView?.intrinsicContentSize.height else { return }

        let height = visible ? maximalSearchHeight : Constants.headerViewAndSearchBarOverlapping + Constants.shadowHeight

        guard nonnullHeightConstraint.constant != height else { return }

        let animations: TypeAlias.ArgumentlessClosure = {

            nonnullHeightConstraint.constant = height
            self.view.tap_layout()
            self.optionallyUpdateTableViewContentOffset()
            self.updateSearchViewShadowOpacity(for: height / maximalSearchHeight)
        }

        UIView.animate(withDuration: animated ? Constants.searchViewAppearanceDuration : 0.0, delay: 0.0, options: .beginFromCurrentState, animations: animations, completion: nil)
    }

    // MARK: - Private -

    private struct Constants {

        fileprivate static let headerViewAndSearchBarOverlapping: CGFloat = 4.0
        fileprivate static let shadowHeight: CGFloat = 2.0
        fileprivate static let searchViewAppearanceDuration: TimeInterval = 0.2

        @available(*, unavailable) private init() {}
    }

    // MARK: Properties

    @IBOutlet private weak var searchViewHeightConstraint: NSLayoutConstraint?

    // MARK: Methods

    private func updateTableViewContentInset() {

        guard let nonnullTableView = self.tableView else { return }
        guard let searchHeight = self.searchView?.intrinsicContentSize.height else { return }

        let desiredInset = UIEdgeInsets(top: searchHeight - Constants.headerViewAndSearchBarOverlapping, left: 0.0, bottom: 0.0, right: 0.0)
        if nonnullTableView.contentInset != desiredInset {

            nonnullTableView.contentInset = desiredInset
        }
    }

    private func endSearching() {

        self.searchView?.endEditing(true)
    }

    private func updateSearchViewShadowOpacity(for searchViewRelativeSize: CGFloat) {

        let shadowOpacity = searchViewRelativeSize > 0.5 ? 0.0 : 1.0 - 2.0 * searchViewRelativeSize
        self.searchView?.layer.shadowOpacity = Float(shadowOpacity)
    }

    private func optionallyUpdateTableViewContentOffset() {

        guard let nonnullTableView = self.tableView else { return }
        guard let height = self.searchView?.intrinsicContentSize.height else { return }
        let visibleSearchViewPart = max(Constants.headerViewAndSearchBarOverlapping + Constants.shadowHeight,
                                        height - max(0.0, min(height, nonnullTableView.contentInset.top + nonnullTableView.contentOffset.y)))

        let visible = 2.0 * visibleSearchViewPart > height

        guard nonnullTableView.contentOffset.y < 0.0 && nonnullTableView.contentOffset.y > -nonnullTableView.contentInset.top else { return }

        let desiredContentOffsetY = visible ? -nonnullTableView.contentInset.top : 0.0
        nonnullTableView.setContentOffset(CGPoint(x: 0.0, y: desiredContentOffsetY), animated: false)
    }
}

// MARK: - UIScrollViewDelegate
extension TapViewControllerWithSearch: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        guard scrollView === self.tableView else { return }
        guard let height = self.searchView?.intrinsicContentSize.height else { return }
        let visibleSearchViewPart = max(Constants.headerViewAndSearchBarOverlapping + Constants.shadowHeight,
                                        height - max(0.0, min(height, scrollView.contentInset.top + scrollView.contentOffset.y)))
        self.searchViewHeightConstraint?.constant = visibleSearchViewPart

        let scaleY = visibleSearchViewPart / height

        self.updateSearchViewShadowOpacity(for: scaleY)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        guard !decelerate && scrollView === self.tableView else { return }
        guard let height = self.searchView?.intrinsicContentSize.height else { return }
        let visibleSearchViewPart = max(Constants.headerViewAndSearchBarOverlapping + Constants.shadowHeight,
                                        height - max(0.0, min(height, scrollView.contentInset.top + scrollView.contentOffset.y)))

        let visible = 2.0 * visibleSearchViewPart > height
        self.makeSearchViewVisible(visible, animated: true)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        guard scrollView === self.tableView else { return }
        guard let height = self.searchView?.intrinsicContentSize.height else { return }
        let visibleSearchViewPart = max(Constants.headerViewAndSearchBarOverlapping + Constants.shadowHeight,
                                        height - max(0.0, min(height, scrollView.contentInset.top + scrollView.contentOffset.y)))

        let visible = 2.0 * visibleSearchViewPart > height
        self.makeSearchViewVisible(visible, animated: true)
    }
}

// MARK: - TapSearchUpdating
extension TapViewControllerWithSearch: TapSearchUpdating {

    public func updateSearchResults(with searchText: String) {

        self.searchViewTextChanged(searchText)
    }
}
