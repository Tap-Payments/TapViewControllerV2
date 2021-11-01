//
//  Bundle+Additions.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 12/7/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import TapAdditionsKitV2
import UIKit
internal extension Bundle {

    // MARK: - Internal -
    // MARK: Properties

    /// Tap View Controller Resources bundle.
    internal static let viewControllerResourcesBundle: Bundle = {

        guard let result = Bundle(for: TapViewController.self).tap_childBundle(named: TapViewControllerConstants.resourcesBundleName) else {

            fatalError("There is no \(TapViewControllerConstants.resourcesBundleName) bundle.")
        }

        return result
    }()
}

private struct TapViewControllerConstants {

    fileprivate static let resourcesBundleName = "TapViewControllerResources"
}
