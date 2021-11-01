//
//  NavigationControllerOldSchoolTransitionAnimation.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 10/14/16.
//  Copyright © 2016 Tap Payments. All rights reserved.
//

import enum UIKit.UINavigationController.UINavigationControllerOperation
import class UIKit.UIView.UIView
import protocol UIKit.UIViewControllerTransitioning.UIViewControllerAnimatedTransitioning
import protocol UIKit.UIViewControllerTransitioning.UIViewControllerContextTransitioning

/// Old-scrool (pre- iOS 7 transitions animator).
public class NavigationControllerOldSchoolTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {

    // MARK: - Public -
    // MARK: Methods

    public init(operation: UINavigationControllerOperation) {

        self.operation = operation
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {

        return Constants.transitionDuration
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard self.operation != .none else { return }

        let containerView = transitionContext.containerView
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {

            transitionContext.completeTransition(false)
            return
        }

        var toFrame = toView.frame
        let layoutDirection = TapViewControllerConnector.applicationInterface?.layoutDirection ?? .leftToRight
        let willMoveToTheLeft = (self.operation == .push && layoutDirection == .leftToRight) || (self.operation == .pop && layoutDirection == .rightToLeft)

        if willMoveToTheLeft {

            toFrame.origin.x = toFrame.size.width
        } else {

            toFrame.origin.x = -toFrame.size.width
        }

        toView.frame = toFrame

        containerView.insertSubview(toView, belowSubview: fromView)

        let animations = { [weak fromView, weak toView] in

            guard let strongFromView = fromView, let strongToView = toView else { return }

            var fromFrame = strongFromView.frame
            fromFrame.origin.x = willMoveToTheLeft ? -fromFrame.size.width : fromFrame.size.width
            strongFromView.frame = fromFrame

            var toFrame2 = strongToView.frame
            toFrame2.origin.x = 0.0
            strongToView.frame = toFrame2
        }

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: animations) { (finished) in

            transitionContext.completeTransition(finished)
        }
    }

    // MARK: - Private -

    private struct Constants {

        fileprivate static let transitionDuration = 0.25

        @available(*, unavailable) private init() {}
    }

    // MARK: Properties

    private var operation: UINavigationControllerOperation
}
