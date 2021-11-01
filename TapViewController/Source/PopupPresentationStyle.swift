//
//  PopupPresentationStyle.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 1/3/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

/// Enum for popup presentation style.
///
/// - fade: Fade animation.
/// - fromTop: Appearance from top of the screen.
/// - fromBottom: Appearance from bottom of the screen.
/// - fromLeft: Appearance from left of the screen.
/// - fromRight: Appearance from right of the screen.
/// - fromLeadingEdge: Appearance from the leading edge of the screen.
/// - fromTrailingEdge: Appearance from the trailing edge of the screen.
public enum PopupPresentationStyle {

    case none
    case fade
    case fromTop
    case fromBottom
    case fromLeft
    case fromRight
    case fromLeadingEdge
    case fromTrailingEdge
}
