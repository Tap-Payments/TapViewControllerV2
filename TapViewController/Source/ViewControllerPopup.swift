//
//  ViewControllerPopup.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 12/8/15.
//  Copyright © 2015 Tap Payments. All rights reserved.
//

import protocol TapAdditionsKitV2.ClassProtocol
import class UIKit.UIView.UIView

/*!
 Protocol to show view controller as a popup.
 */
public protocol ViewControllerPopup: ClassProtocol {

    // MARK: Properties

    /// View to act like a popup.
    var popupView: UIView? { get }

    /// Background view.
    var backgroundView: UIView? { get }
}
