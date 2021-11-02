//
//  ViewControllerImplementation.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 11/17/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import TapSwiftFixesV2
import TapAdditionsKitV2
import TapLocalizationV2
import UIKit

/// View Controller implementation.
internal class ViewControllerImplementation {

    // MARK: - Internal -
    // MARK: Properties

    /// Suported interface orientations
    internal var supportedInterfaceOrientations: UIInterfaceOrientationMask {

        if let forces = TapViewControllerConnector.applicationInterface?.forcesPortraitOrientation {

            return forces ? .portrait : .all
        } else {

            return .all
        }
    }

    internal var shouldAutorotate: Bool {

        return true
    }

    // MARK: Methods

    internal init(viewController: UIViewController & ViewControllerInterface) {

        self.controller = viewController
        self.addStatusBarObserver()
    }

    internal func updateLocalization() {

        if #available(iOS 9.0, *) {

            self.updateSemanticContentAttribute()
        }

        self.controller.updateLocalization()
    }

    internal func viewWillAppear(_ animated: Bool) {

        TapViewControllerLogger.debugLog("\(self.controller.tap_className) will appear.")

        self.controller.appearanceDelegate?.viewControllerWillAppear?(self.controller, animated: animated)

        self.addLocalizationObserver()
        self.updateLocalization()

        if self.controller.topOffsetConstraint != nil || self.controller.bottomOffsetConstraint != nil {

            self.addKeyboardObserver()
        }

        if !self.controller.shouldAutomaticallyForwardAppearanceMethods {

            for childController in self.controller.childViewControllers {

                childController.beginAppearanceTransition(true, animated: animated)
            }
        }
    }

    internal func viewDidAppear(_ animated: Bool) {

        self.controller.appearanceDelegate?.viewControllerDidAppear?(self.controller, animated: animated)

        if !self.controller.shouldAutomaticallyForwardAppearanceMethods {

            for childController in self.controller.childViewControllers {

                childController.endAppearanceTransition()
            }
        }
    }

    internal func viewWillDisappear(_ animated: Bool) {

        self.controller.appearanceDelegate?.viewControllerWillDisappear?(self.controller, animated: animated)

        if !self.controller.shouldAutomaticallyForwardAppearanceMethods {

            for childController in self.controller.childViewControllers {

                childController.beginAppearanceTransition(false, animated: animated)
            }
        }
    }

    internal func viewDidDisappear(_ animated: Bool) {

        self.controller.appearanceDelegate?.viewControllerDidDisappear?(self.controller, animated: animated)

        if self.controller.topOffsetConstraint != nil || self.controller.bottomOffsetConstraint != nil {

            self.removeKeyboardObserver()
        }

        self.removeLocalizationObserver()

        if !self.controller.shouldAutomaticallyForwardAppearanceMethods {

            for childController in self.controller.childViewControllers {

                childController.endAppearanceTransition()
            }
        }
    }

    internal func viewWillLayoutSubviews() {

        if #available(iOS 9.0, *) {

            self.updateSemanticContentAttribute()
        }
    }

    deinit {

        self.removeStatusBarObserver()
    }

    // MARK: - Private -

    private struct Constants {

        fileprivate static let statusBarUpdateAnimationDuration: TimeInterval = 0.25
    }

    // MARK: Properties

    private weak var controller: (UIViewController & ViewControllerInterface)!

    // MARK: Methods

    private func addLocalizationObserver() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(localizationDidChange(_:)),
                                               name: tapLocalizationChangedNotificationName,
                                               object: nil)
    }

    private func removeLocalizationObserver() {

        NotificationCenter.default.removeObserver(self, name: tapLocalizationChangedNotificationName, object: nil)
    }

    @objc private func localizationDidChange(_ notification: NSNotification) {

        DispatchQueue.main.async { [weak self] in

            self?.updateLocalization()
        }
    }

    private func addKeyboardObserver() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
    }

    private func removeKeyboardObserver() {

        NotificationCenter.default.removeObserver(self,
                                                  name: .UIKeyboardWillChangeFrame,
                                                  object: nil)
    }

    @objc private func keyboardWillChangeFrame(_ notification: NSNotification) {

        performOnMainThread { [weak self] in

            guard let strongSelf = self else { return }
            guard let userInfo = notification.userInfo else { return }

            guard let window = strongSelf.controller.view.window else { return }
            guard var endKeyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

            endKeyboardFrame = window.convert(endKeyboardFrame, to: strongSelf.controller.view)

            let screenSize = window.bounds.size

            let keyboardIsShown = screenSize.height > endKeyboardFrame.origin.y
            let offset = strongSelf.controller.bottomOffset(for: keyboardIsShown, height: endKeyboardFrame.size.height)

            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.0
            let animationOptions: UIViewAnimationOptions = [

                .beginFromCurrentState,
                keyboardIsShown ? .curveEaseOut : .curveEaseIn
            ]

            let animations = { [weak strongSelf] in

                guard let strongerSelf = strongSelf else { return }

                strongerSelf.controller.topOffsetConstraint?.constant = -offset
                strongerSelf.controller.bottomOffsetConstraint?.constant = offset

                strongerSelf.controller.updateConstraints(for: keyboardIsShown, height: endKeyboardFrame.size.height)

                strongerSelf.controller.view.tap_layout()
            }

            UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOptions, animations: animations, completion: nil)
        }
    }

    private func addStatusBarObserver() {

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(statusBarWillChangeFrame(_:)),
                                               name: .UIApplicationWillChangeStatusBarFrame,
                                               object: nil)
    }

    private func removeStatusBarObserver() {

        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillChangeStatusBarFrame, object: nil)
    }

    @objc private func statusBarWillChangeFrame(_ notification: NSNotification) {

        performOnMainThread {

            let options: UIViewAnimationOptions = [.beginFromCurrentState, .curveLinear, .allowAnimatedContent, .allowUserInteraction]

            let animations: TypeAlias.ArgumentlessClosure = {

                self.controller.view.tap_layout()
            }

            UIView.animate(withDuration: Constants.statusBarUpdateAnimationDuration, delay: 0.0, options: options, animations: animations, completion: nil)
        }
    }

    @available(iOS 9.0, *) private func updateSemanticContentAttribute() {

        if let contentAttribute = TapViewControllerConnector.applicationInterface?.requiredSemanticContentAttribute, self.controller.view.semanticContentAttribute != contentAttribute {

            self.controller.view.tap_applySemanticContentAttribute(contentAttribute)
        }
    }
}
