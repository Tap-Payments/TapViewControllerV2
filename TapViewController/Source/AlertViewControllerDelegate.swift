//
//  AlertViewControllerDelegate.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 12/7/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

/*!
 Alert View Controller delegate.
 */
@objc public protocol AlertViewControllerDelegate: class {

    // MARK: Methods

    /*!
     Notifies delegate that alert view controller did dismiss.
 
     - parameter alertController: Sender.
     */
    @objc optional func alertViewControllerDidDismiss(_ alertController: AlertViewController)

    /*!
     Notifies delegate that button was clicked in alert view controller.
 
     - parameter alertController: Sender.
     */
    @objc optional func alertViewControllerButtonClicked(_ alertController: AlertViewController)

    /*!
     Notifies delegate that alert view controller did dismiss.
 
     - parameter alertController: Sender.
     */
    @objc optional static func alertViewControllerDidDismiss(_ alertController: AlertViewController)

    /*!
     Notifies delegate that button was clicked in alert view controller.
 
     - parameter alertController: Sender.
     */
    @objc optional static func alertViewControllerButtonClicked(_ alertController: AlertViewController)
}
