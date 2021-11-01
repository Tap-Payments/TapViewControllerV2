//
//  UIStoryboard+Additions.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 12/14/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import class UIKit.UIStoryboard.UIStoryboard

internal extension UIStoryboard {

    // MARK: - Internal -
    // MARK: Properties

    /// View Controller storyboard.
    internal static let viewController = UIStoryboard(name: "TapViewController", bundle: .viewControllerResourcesBundle)
}
