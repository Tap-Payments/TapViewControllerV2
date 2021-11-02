//
//  LocalizationManagerDataSource.swift
//  TapLocalization
//
//  Created by Dennis Pashkov on 11/16/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

import TapAdditionsKitV2

/// Localization manager data source.
public protocol LocalizationManagerDataSource: ClassProtocol {

    // MARK: Properties

    /// List of initially supported languages (before Firebase list is loaded).
    var initiallySupportedLanguages: [String] { get }

    /// Language taken from user defaults.
    /// On get, retreive stored in User defaults language or nil if there is no language stored.
    /// On set, write current language to user defaults.
    var userDefaultsLanguage: String? { get set }
}
