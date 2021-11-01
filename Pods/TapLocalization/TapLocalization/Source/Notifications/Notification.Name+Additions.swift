//
//  Notification.Name+Additions.swift
//  TapLocalization
//
//  Created by Dennis Pashkov on 11/16/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

/// Public notification names.
public extension Notification.Name {

    // MARK: - Public -
    // MARK: Properties

    /// Notification name to handle layout direction changes based on the current application language.
    public static let layoutDirectionChanged = Notification.Name("TapLayoutDirectionChangedNotification")

    /// Notification name to handle localization updates.
    /// Is called in several cases:
    /// 1. Application language changed.
    /// 2. Firebase localization DB has updated.
    public static let localizationChanged = Notification.Name("TapLocalizationChangedNotification")

    /// Notification name to handle supported languages list change.
    public static let supportedLanguagesListChanged = Notification.Name("TapSupportedLanguagesListChanged")
}

/// Top level constants to avoid import of the whole module.

public let tapLayoutDirectionChangedNotificationName: Notification.Name = .layoutDirectionChanged
public let tapLocalizationChangedNotificationName: Notification.Name = .localizationChanged
public let tapSupportedLanguagesListChangedNotificationName: Notification.Name = .supportedLanguagesListChanged
