//
//  ViewControllerInterface.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 11/17/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import CoreGraphics
import UIKit

/// Base View Controller interface.
@objc public protocol ViewControllerInterface where Self: UIViewController {

    // MARK: Properties

    /// Appearance delegate.
    var appearanceDelegate: ViewControllerAppearanceDelegate? { get set }

    /// Top offset layout constraint.
    var topOffsetConstraint: NSLayoutConstraint? { get }

    /// Bottom offset layout constraint.
    var bottomOffsetConstraint: NSLayoutConstraint? { get }

    // MARK: Methods

    /// Asks the receiver for required bottom offset for opened/closed keyboard.
    ///
    /// - Parameters:
    ///   - openedKeyboard: Boolean flag which determines whether offset is requested for opened or for closed keyboard.
    ///   - keyboardHeight: Keyboard height.
    /// - Returns: Bottom offset value.
    func bottomOffset(for openedKeyboard: Bool, height keyboardHeight: CGFloat) -> CGFloat

    /// Asks the receiver to update constraints due to keyboard position/state change.
    ///
    /// - Parameters:
    ///   - openedKeyboard: Defines if keyboard is opened.
    ///   - keyboardHeight: Keyboard height.
    func updateConstraints(for openedKeyboard: Bool, height keyboardHeight: CGFloat)

    /// Method that will be called as soon as there are any localization changes on Firebase.
    /// Also called in viewWillAppear(_:) method to set up initial localization.
    func updateLocalization()
}
