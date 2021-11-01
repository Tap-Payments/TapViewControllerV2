//
//  PopupViewController.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 1/29/16.
//  Copyright © 2016 Tap Payments. All rights reserved.
//

import TapAdditionsKitV2

import class TapVisualEffectViewV2.TapVisualEffectView

/// Base class for popup controllers that use separate UIWindow.
open class PopupViewController: TapViewController {

    // MARK: - Open -
    // MARK: Properties

    /// Custom window class
    open class var customWindowClass: UIWindow.Type {

        return UIWindow.self
    }

    /// Blur view. Set it up if blur is presented.
    @IBOutlet open weak var blurView: TapVisualEffectView?

    // MARK: Methods

    /*!
     Abstract method to create an instance. Should be overriden if called.
     */
    open class func instantiate() -> Self {

        return self.instantiate(from: nil)
    }

    /*!
     Abstract method to create an instance from storyboard. Should be overriden if called.
 
     - parameter storyboard: Storyboard.
     */
    open class func instantiate(from storyboard: UIStoryboard?) -> Self {

        fatalError("This method needs to be overriden in \(self)")
    }

    /*!
     Shows popup.
 
     - parameter animated: Defines if popup should be shown with animation.
     */
    open func show(animated: Bool) {

        self.show(animated: animated, completion: nil)
    }

    /*!
     Shows popup.
 
     - parameter animated:   Defines if popup should be shown with animation.
     - parameter completion: Completion block to be called when animation finishes.
     */
    open func show(animated: Bool, completion: TypeAlias.ArgumentlessClosure?) {

        guard !self.shown else {

            completion?()
            return
        }

        self.show(true, animated: animated, completion: completion)
    }

    open override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear(animated)

        if self.statusBarHidden {

            TapViewControllerConnector.applicationInterface?.setStatusBarHidden(true, with: .fade)
        } else {

            TapViewControllerConnector.applicationInterface?.setStatusBarHidden(false, with: .fade)

            let currentStatusBarStyle = UIApplication.shared.statusBarStyle
            if self.statusBarStyle != currentStatusBarStyle {

                TapViewControllerConnector.applicationInterface?.setStatusBarStyle(self.statusBarStyle, animated: self.statusBarChangesAnimated)
            }
        }
    }

    // MARK: - Public -
    // MARK: Properties

    /// Defines if popup is shown.
    public private(set) var shown: Bool = false

    /// Defines if appearance or disappearance animation is in progress.
    public private(set) var isAnimatingAppearanceOrDisappearance: Bool = false

    /// Presentation style of the popup.
    public var presentationStyle: PopupPresentationStyle = .fade

    /// Status bar style.
    public var statusBarStyle: UIStatusBarStyle = .lightContent

    /// Defins if status bar should be hidden.
    public var statusBarHidden: Bool = false

    /// Defines if previous first responder become first responder again after controller dismissal. Default is true.
    public var restoresPreviousFirstResponder: Bool = true

    /// Defines if beginAppearanceTransition() / endAppearanceTransition() methods are called when controller is showing/dismissing
    public var affectsAppearanceMethods: Bool = true

    /// View that will be animating its opacity while animation. By default is view controller's view.
    @IBOutlet public weak var fadingView: UIView?

    /// Closure to be called before receiver appears.
    public var beforeAppearanceClosure: TypeAlias.ArgumentlessClosure?

    /// Closure to be called after controller's view was added to superview and before appearance animation. Purpose: initial layout before appearance.
    public var didMoveToSuperviewClosure: TypeAlias.ArgumentlessClosure?

    /// Additional appearance animation.
    public var additionalAppearanceAnimationClosure: TypeAlias.ArgumentlessClosure?

    /// Is called when appearance animation finishes.
    public var appearanceCompletionClosure: TypeAlias.ArgumentlessClosure?

    /// Additional disappearance animation.
    public var additionalDisappearanceAnimationClosure: TypeAlias.ArgumentlessClosure?

    /// Closure to be called before receiver is dismissed.
    public var beforeDismissClosure: TypeAlias.ArgumentlessClosure?

    /// Closure to be called after receiver is dismissed.
    public var dismissCompletionClosure: TypeAlias.ArgumentlessClosure?

    // MARK: Methods

    /*!
     Hides popup.
     */
    public func hide(animated: Bool) {

        self.hide(animated: animated, completion: nil)
    }

    /// Hides popup.
    ///
    /// - Parameters:
    ///   - animated: Defines if change happens with animation.
    ///   - completion: Completion closure.
    public func hide(animated: Bool, completion: TypeAlias.ArgumentlessClosure?) {

        guard self.shown else { return }

        self.show(false, animated: animated) { [weak self] in

            self?.dismissCompletionClosure?()
            completion?()
        }
    }

    // MARK: - Private -

    private struct Constants {

        fileprivate static let popupViewControllerAppearanceAnimationDuration: TimeInterval = 0.4
        fileprivate static let alertPopupViewControllerAppearanceAnimationDuration: TimeInterval = 0.5
        fileprivate static let alertPopupViewControllerDisappearanceAnimationDuration: TimeInterval = 0.18
        fileprivate static let zoomAnimationKey = "zoomAnimation"

        @available(*, unavailable) private init() {}
    }

    // MARK: Properties

    private var _parentWindow: UIWindow?
    private var parentWindow: UIWindow {

        if let existingParentWindow = self._parentWindow {

            return existingParentWindow
        }

        let window = type(of: self).customWindowClass.init()

        window.frame = UIScreen.main.bounds
        window.backgroundColor = UIColor.clear
        window.alpha = 1.0
        window.translatesAutoresizingMaskIntoConstraints = true
        window.windowLevel = type(of: self).nextWindowLevel

        self._parentWindow = window

        return window
    }

    private weak var lowerWindow: UIWindow?

    private static var nextWindowLevel: UIWindowLevel {

        var maxWindowLevel = UIWindowLevelNormal
        for window in UIApplication.shared.windows {

            let windowLevel = window.windowLevel

            if windowLevel >= UIWindowLevelStatusBar { continue }

            maxWindowLevel = max(maxWindowLevel, windowLevel)
        }

        return maxWindowLevel + 0.01
    }

    private var statusBarChangesAnimated: Bool = true

    private var appearanceAnimationDuration: TimeInterval {

        if self is ViewControllerPopup {

            return Constants.alertPopupViewControllerAppearanceAnimationDuration
        } else {

            return Constants.popupViewControllerAppearanceAnimationDuration
        }
    }

    private var disappearanceAnimationDuration: TimeInterval {

        if self is ViewControllerPopup {

            return Constants.alertPopupViewControllerDisappearanceAnimationDuration
        } else {

            return Constants.popupViewControllerAppearanceAnimationDuration
        }
    }

    private weak var previousFirstResponder: UIResponder?

    // MARK: Methods

    private final func show(_ show: Bool, animated: Bool, completion: TypeAlias.ArgumentlessClosure?) {

        DispatchQueue.main.async {

            self.statusBarChangesAnimated = animated
            self.shown = show

            if show {

                self.beforeAppearanceClosure?()
                self.performAppearance(show, animated: animated, completion: completion)
            } else {

                self.beforeDismissClosure?()

                let appearanceCompletion = {

                    self.performAppearance(show, animated: animated, completion: completion)
                }

                if let firstResponder = self.view.tap_firstResponder {

                    firstResponder.tap_resignFirstResponder(appearanceCompletion)
                } else {

                    appearanceCompletion()
                }
            }
        }
    }

    private final func performAppearance(_ appearance: Bool, animated: Bool, completion theCompletion: TypeAlias.ArgumentlessClosure?) {

        self.obtainLowerWindow()

        let appearanceClosure = {

            self.tap_loadViewIfNotLoaded()

            let blurStyle = self.blurView?.style ?? .none

            let fadeView: UIView = self.fadingView ?? self.parentWindow

            if appearance {

                self.parentWindow.rootViewController = self
                self.parentWindow.isHidden = false

                self.updateWindowPositionForShownState(false)

                self.view.tap_layout()

                self.didMoveToSuperviewClosure?()

                self.blurView?.style = .none

                if self.presentationStyle == .fade {

                    fadeView.alpha = 0.0
                }
            }

            DispatchQueue.main.async {

                let previousDisplayedController = self.lowerWindow?.rootViewController?.tap_displayedViewController

                if self.affectsAppearanceMethods {

                    previousDisplayedController?.beginAppearanceTransition(!appearance, animated: animated)
                }

                let animationDuration = animated ? appearance ? self.appearanceAnimationDuration : self.disappearanceAnimationDuration : 0.0
                let animationOptions: UIViewAnimationOptions = [.beginFromCurrentState, .curveEaseInOut]
                let animations = {

                    self.blurView?.style = appearance ? blurStyle : .none

                    if self.presentationStyle == .fade {

                        fadeView.alpha = appearance ? 1.0 : 0.0
                    }

                    self.updateWindowPositionForShownState(appearance)

                    if appearance {

                        self.additionalAppearanceAnimationClosure?()
                    } else {

                        self.additionalDisappearanceAnimationClosure?()
                    }

                    if let alertPopup = self as? ViewControllerPopup {

                        alertPopup.backgroundView?.alpha = appearance ? 1.0 : 0.0
                    }
                }

                let completion = { (finished: Bool) in

                    self.isAnimatingAppearanceOrDisappearance = false

                    if appearance {

                        self.parentWindow.makeKeyAndVisible()
                    } else {

                        TapViewControllerConnector.applicationInterface?.setStatusBarHidden(false, with: self.statusBarChangesAnimated ? .fade : .none)

                        self.parentWindow.isHidden = true
                        self.parentWindow.rootViewController = nil
                        self._parentWindow = nil
                        self.blurView?.style = blurStyle

                        self.lowerWindow?.makeKeyAndVisible()
                    }

                    if self.affectsAppearanceMethods {

                        previousDisplayedController?.endAppearanceTransition()
                    }

                    if appearance {

                        self.appearanceCompletionClosure?()
                    }

                    theCompletion?()

                    if !appearance {

                        if let previousResponder = self.previousFirstResponder {

                            previousResponder.becomeFirstResponder()
                        }
                    }
                }

                self.isAnimatingAppearanceOrDisappearance = true

                UIView.animate(withDuration: animationDuration, delay: 0.0, options: animationOptions, animations: animations, completion: completion)

                if let alertPopup = self as? ViewControllerPopup {

                    let zoomAnimation: CAKeyframeAnimation = appearance ? .tap_popupAppearance : .tap_popupDisappearance
                    zoomAnimation.duration = animationDuration

                    alertPopup.popupView?.layer.add(zoomAnimation, forKey: Constants.zoomAnimationKey)
                }
            }
        }

        if appearance {

            self.resignPreviousFirstResponderIfPossible(appearanceClosure)
        } else {

            appearanceClosure()
        }
    }

    private func resignPreviousFirstResponderIfPossible(_ completion: @escaping TypeAlias.ArgumentlessClosure) {

        var activeResponder: UIResponder?

        for window in UIApplication.shared.windows {

            if let fResponder = window.tap_firstResponder {

                activeResponder = fResponder
                break
            }
        }

        guard let nonnullActiveResponder = activeResponder else {

            completion()
            return
        }

        if self.restoresPreviousFirstResponder {

            self.previousFirstResponder = nonnullActiveResponder
        }

        nonnullActiveResponder.tap_resignFirstResponder(completion)
    }

    private func obtainLowerWindow() {

        let currentWindowLevel = self.parentWindow.windowLevel

        let allLowerWindows = UIApplication.shared.windows.filter { ($0.rootViewController is ViewControllerInterface) && ($0.windowLevel < currentWindowLevel) }
        let sortedLowerWindows = allLowerWindows.sorted { $0.windowLevel < $1.windowLevel }

        self.lowerWindow = sortedLowerWindows.last
    }
}

// MARK: - PopupViewControllerCustomWindowClass
extension PopupViewController: PopupViewControllerCustomWindowClass { }
