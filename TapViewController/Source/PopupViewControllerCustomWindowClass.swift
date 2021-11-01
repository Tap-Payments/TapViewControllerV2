//
//  PopupViewControllerCustomWindowClass.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 2/8/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import protocol TapAdditionsKitV2.ClassProtocol
import class UIKit.UIWindow.UIWindow

/// Popup view controller custom window class protocol.
public protocol PopupViewControllerCustomWindowClass: ClassProtocol {

    /// Custom window class. Should be subclass of UIWindow
    static var customWindowClass: UIWindow.Type { get }
}
