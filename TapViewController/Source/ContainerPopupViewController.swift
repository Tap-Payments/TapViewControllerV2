//
//  ContainerPopupViewController.swift
//  goTap
//
//  Created by Dennis Pashkov on 1/3/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import TapAdditionsKitV2
import UIKit
/// Subclass of PopupViewController to enable embedding of other view controller as a child to popup.
public class ContainerPopupViewController: PopupViewController {

    // MARK: - Public -
    // MARK: Methods

    public override class func instantiate() -> Self {

        guard let popupController = UIStoryboard.viewController.instantiateViewController(withIdentifier: self.tap_className) as? ContainerPopupViewController else {

            fatalError("Failed to instantiate \(self.tap_className) from storyboard.")
        }

        popupController.dismissCompletionClosure = { [weak popupController] in

            popupController?.removeChildViewController()
        }

        return popupController.tap_asSelf()
    }

    public static func instantiate(with child: UIViewController) -> Self {

        let popupController = self.instantiate()
        popupController.childViewController = child

        return popupController
    }

    public func replaceChildWithScreenshot() {

        guard let screenshot = self.containerView?.tap_screenshot else { return }
        self.containerViewScreenshotImageView?.isHidden = false
        self.containerViewScreenshotImageView?.image = screenshot
        self.containerView?.isHidden = true
    }

    public override func hide(animated: Bool, completion: TypeAlias.ArgumentlessClosure?) {

        let completion = {

            super.hide(animated: animated, completion: completion)
        }

        if let presentedController = self.childViewController?.presentedViewController {

            DispatchQueue.main.async {

                presentedController.dismiss(animated: animated, completion: completion)
            }
        } else {

            completion()
        }
    }

    // MARK: - Private -
    // MARK: Properties

    @IBOutlet private weak var containerView: UIView?
    @IBOutlet private weak var containerViewScreenshotImageView: UIImageView?

    private weak var childViewController: UIViewController? {

        didSet {

            self.addChildViewController()
        }
    }

    // MARK: Methods

    private func addChildViewController() {

        self.tap_loadViewIfNotLoaded()

        guard let nonnullChildController = self.childViewController else { return }

        self.addChildViewController(nonnullChildController)
        self.containerView?.tap_addSubviewWithConstraints(nonnullChildController.view)
        nonnullChildController.didMove(toParentViewController: self)

        self.containerView?.tap_removeAllAnimations()
    }

    private func removeChildViewController() {

        guard let nonnullChildController = self.childViewController else { return }

        nonnullChildController.willMove(toParentViewController: nil)
        nonnullChildController.view.removeFromSuperview()
        nonnullChildController.removeFromParentViewController()

        self.childViewController = nil
    }
}
