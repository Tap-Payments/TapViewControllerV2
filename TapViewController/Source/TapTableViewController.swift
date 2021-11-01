//
//  TapTableViewController.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 11/17/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import CoreGraphics
import TapSwiftFixesV2
import UIKit

/// Base table view controller.
open class TapTableViewController: UITableViewController, ViewControllerInterface {

    // MARK: - Open -
    // MARK: Properties

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

        return self.baseImplementation.supportedInterfaceOrientations
    }

    open override var shouldAutorotate: Bool {

        return self.baseImplementation.shouldAutorotate
    }

    // MARK: Methods

    open override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)
        self.baseImplementation.viewWillAppear(animated)
    }

    open override func viewDidAppear(_ animated: Bool) {

        super.viewDidAppear(animated)
        self.baseImplementation.viewDidAppear(animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {

        self.baseImplementation.viewWillDisappear(animated)
        super.viewWillDisappear(animated)
    }

    open override func viewDidDisappear(_ animated: Bool) {

        self.baseImplementation.viewDidDisappear(animated)
        super.viewDidDisappear(animated)
    }

    open override func viewWillLayoutSubviews() {

        self.baseImplementation.viewWillLayoutSubviews()
        super.viewWillLayoutSubviews()
    }

    /// Point to override. Load all localization in this method.
    open func updateLocalization() { }

    /// Point to override. Set up layout for keyboard changes here.
    open func bottomOffset(for openedKeyboard: Bool, height keyboardHeight: CGFloat) -> CGFloat {

        return 0.0
    }

    /// Point to override. Set up layout for keyboard changes here.
    open func updateConstraints(for openedKeyboard: Bool, height keyboardHeight: CGFloat) { }

    deinit {

        self.baseImplementationStorage = nil
        TapViewControllerLogger.debugLog("\(self.tap_className) deallocated.")
    }

    // MARK: - Public -
    // MARK: Properties

    /// Appearance delegate.
    public weak var appearanceDelegate: ViewControllerAppearanceDelegate?

    /// Top constraint to animate changes on keyboard appearance and disappearance.
    @IBOutlet public weak var topOffsetConstraint: NSLayoutConstraint?

    /// Bottom constraint to animate changes on keyboard appearance and disappearance.
    @IBOutlet public weak var bottomOffsetConstraint: NSLayoutConstraint?

    // MARK: - Private -
    // MARK: Properties

    private var baseImplementation: ViewControllerImplementation {

        return synchronized(self) {

            if let implementation = self.baseImplementationStorage {

                return implementation
            }

            let implementation = ViewControllerImplementation(viewController: self)

            self.baseImplementationStorage = implementation

            return implementation
        }
    }

    private var baseImplementationStorage: ViewControllerImplementation?
}
