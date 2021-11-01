//
//  ViewControllerAppearanceDelegate.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 11/23/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

/// View Controller appearance delegate.
@objc public protocol ViewControllerAppearanceDelegate: class {

    // MARK: Methods

    /// Notifies the receiver that view controller will appear.
    ///
    /// - Parameters:
    ///   - viewController: Sender.
    ///   - animated: Defines if change will be animated.
    @objc optional func viewControllerWillAppear(_ viewController: ViewControllerInterface, animated: Bool)

    /// Notifies the receiver that view controller did appear.
    ///
    /// - Parameters:
    ///   - viewController: Sender.
    ///   - animated: Defines if change will be animated.
    @objc optional func viewControllerDidAppear(_ viewController: ViewControllerInterface, animated: Bool)

    /// Notifies the receiver that view controller will disappear.
    ///
    /// - Parameters:
    ///   - viewController: Sender.
    ///   - animated: Defines if change will be animated.
    @objc optional func viewControllerWillDisappear(_ viewController: ViewControllerInterface, animated: Bool)

    /// Notifies the receiver that view controller did disappear.
    ///
    /// - Parameters:
    ///   - viewController: Sender.
    ///   - animated: Defines if change will be animated.
    @objc optional func viewControllerDidDisappear(_ viewController: ViewControllerInterface, animated: Bool)
}
