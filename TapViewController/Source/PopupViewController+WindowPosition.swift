//
//  PopupViewController+WindowPosition.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 12/7/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import CoreGraphics

// MARK: - WindowPosition
public extension PopupViewController {

    // MARK: - Public -
    // MARK: Methods

    /// Translates window by x axis.
    ///
    /// - Parameter value: Desired x position.
    public func changeWindowXPosition(to value: CGFloat) {

        guard let nonnullWindow = self.view.window else { return }

        var windowFrame = nonnullWindow.frame
        windowFrame.origin.x = value
        nonnullWindow.frame = windowFrame
    }

    /// Translates window by y axis.
    ///
    /// - Parameter value: Desired y position.
    public func changeWindowYPosition(to value: CGFloat) {

        guard let nonnullWindow = self.view.window else { return }

        var windowFrame = nonnullWindow.frame
        windowFrame.origin.y = value
        nonnullWindow.frame = windowFrame
    }

    /// Changes window width.
    ///
    /// - Parameter value: Desired window width.
    public func changeWindowWidth(to value: CGFloat) {

        guard let nonnullWindow = self.view.window else { return }

        var windowFrame = nonnullWindow.frame
        windowFrame.size.width = value
        nonnullWindow.frame = windowFrame
    }

    /// Changes window height.
    ///
    /// - Parameter value: Desired window height.
    public func changeWindowHeight(to value: CGFloat) {

        guard let nonnullWindow = self.view.window else { return }

        var windowFrame = nonnullWindow.frame
        windowFrame.size.height = value
        nonnullWindow.frame = windowFrame
    }

    /// Moves window to shown/hidden state, based on set presentationStyle.
    ///
    /// - Parameter shownState: Shown state: true if shown, false otherwise.
    public func updateWindowPositionForShownState(_ shownState: Bool) {

        guard let screenSize = self.view.window?.screen.bounds.size else { return }
        guard let windowSize = self.view.window?.bounds.size else { return }

        switch self.presentationStyle {

        case .none, .fade:

            return

        case .fromTop:

            self.changeWindowYPosition(to: shownState ? 0.0 : -windowSize.height)

        case .fromBottom:

            self.changeWindowYPosition(to: shownState ? 0.0 : screenSize.height)

        case .fromLeft:

            self.changeWindowXPosition(to: shownState ? 0.0 : -windowSize.width)

        case .fromRight:

            self.changeWindowXPosition(to: shownState ? 0.0 : screenSize.width)

        case .fromLeadingEdge:

            self.changeWindowXPosition(to: shownState ? 0.0 : TapViewControllerConnector.applicationInterface?.layoutDirection == .rightToLeft ? screenSize.width : -windowSize.width)

        case .fromTrailingEdge:

            self.changeWindowXPosition(to: shownState ? 0.0 : TapViewControllerConnector.applicationInterface?.layoutDirection == .rightToLeft ? -windowSize.width : screenSize.width)
        }
    }
}
