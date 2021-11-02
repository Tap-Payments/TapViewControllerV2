//
//  LocalizationManager.swift
//  TapLocalization
//
//  Created by Dennis Pashkov on 11/16/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

import TapDatabaseV2
import TapLoggerV2

/// Localization Manager class.
public class LocalizationManager {

    // MARK: - Public -
    // MARK: Properties

    /// Localization manager data source. Should be set up before calling LocalizationManager.shared.
    /// Otherwise exception will be thrown.
    public static weak var dataSource: LocalizationManagerDataSource?

    /// Shared instance.
    public static let shared = LocalizationManager()

    /// Calendar
    public private(set) lazy var calendar: Calendar = Calendar.current

    /// Locale
    public private(set) var locale: Locale {

        didSet {

            self.calendar.locale = self.locale
        }
    }

    /// Current language
    public var currentLanguage: String {

        didSet {

            self.locale = Locale(identifier: self.currentLanguage)
            self.updateBundle()

            self.datasource.userDefaultsLanguage = self.currentLanguage

            NotificationCenter.default.post(name: .localizationChanged, object: nil)

            self.checkIfLayoutDirectionChangedAndPostNotification(from: oldValue, to: self.currentLanguage)
        }
    }

    /// Defines if current language is right-to-left.
    public var isCurrentLanguageRightToLeft: Bool {

        return self.isLanguageRightToLeft(self.currentLanguage)
    }

    /// Returns current language in native language.
    public var currentLanguageInNativeLanguage: String {

        return self.languageInNative(for: self.currentLanguage)
    }

    /// Supported languages
    public private(set) var supportedLanguages: [String]

    /// Default video language ( use in case if there is no video for the current user's locale ).
    public private(set) lazy var defaultLanguageForVideo = Locale.current

    // MARK: Methods

    /// Returns flag image name for the given language.
    ///
    /// - Parameter language: Language to return flag image name for.
    /// - Returns: Flag image name.
    public func flagImageName(for language: String) -> String? {

        return self.languageIcons[language]?.uppercased()
    }

    /// Defines if the given language is right to left.
    ///
    /// - Parameter language: Language to check direction.
    /// - Returns: true if language is right to left.
    public func isLanguageRightToLeft(_ language: String) -> Bool {

        return Locale.characterDirection(forLanguage: language) == .rightToLeft
    }

    /// Returns native language name for the given language code.
    ///
    /// - Parameter languageCode: Language code.
    /// - Returns: Native language name.
    public func languageInNative(for languageCode: String) -> String {

        return Locale(identifier: languageCode).localizedString(forLanguageCode: languageCode) ?? languageCode
    }

    /// Translates given key into required language.
    ///
    /// - Parameters:
    ///   - key: Language key.
    ///   - language: Localization.
    /// - Returns: Localized key.
    public func localizedString(for key: String, with language: String = LocalizationManager.shared.currentLanguage) -> String {

        let dbKey = key.components(separatedBy: " ").joined(separator: "_").components(separatedBy: ".").joined()

        if let currentLanguageData = self.localizationData[self.currentLanguage] {

            if let value = currentLanguageData[dbKey] {

                return value
            }
            else {

                DebugLog("There is no such key in Firebase for \(self.currentLanguage) language: \(dbKey)")
                self.postUnsupportedKey(dbKey)
            }
        }

        return self.currentBundle.localizedString(forKey: key, value: key, table: nil)
    }

    deinit {

        TapDatabase.shared.removeObserver(self)
    }

    // MARK: - Private -

    private struct Constants {

        fileprivate typealias LocalizationType = [String: [String: String]]
        fileprivate typealias SupportedLanguagesType = [String]
        fileprivate typealias SupportedLanguagesImages = [String: String]

        fileprivate static let localizationResourceFileExtension = "lproj"

        @available(*, unavailable) private init() {}
    }

    // MARK: Properties

    private let datasource: LocalizationManagerDataSource

    private var currentBundle: Bundle

    private lazy var localizationData: Constants.LocalizationType = [:]

    private lazy var languageIcons: Constants.SupportedLanguagesImages = [:]

    // MARK: Methods

    private init() {

        guard let dSource = type(of: self).dataSource else {

            fatalError("Localization manager data source should be set before calling LocalizationManager.shared")
        }

        self.datasource = dSource
        self.supportedLanguages = self.datasource.initiallySupportedLanguages
        self.currentLanguage = type(of: self).obtainCurrentLanguage()
        self.locale = Locale(identifier: self.currentLanguage)
        self.currentBundle = type(of: self).bundle(for: self.currentLanguage)

        self.setupFirebase()
    }

    private static func bundle(for language: String) -> Bundle {

        guard let bundlePath = Bundle.main.path(forResource: language, ofType: Constants.localizationResourceFileExtension) else {

            fatalError("There is no bundle for \(language) language.")
        }

        guard let bundle = Bundle(path: bundlePath) else {

            fatalError("Bundle at path \(bundlePath) is invalid.")
        }

        return bundle
    }

    private func updateBundle() {

        self.currentBundle = type(of: self).bundle(for: self.currentLanguage)
    }

    /// Setup Firebase
    private func setupFirebase() {

        TapDatabase.shared.addObserver(self)
    }

    /// post to firebase key and language for missing value.
    ///
    /// - Parameter key: key taht missing
    private func postUnsupportedKey(_ key: String) {

        let path = "\(TapDatabase.Path.missingLocalization)/\(self.currentLanguage)/\(key)"
        TapDatabase.shared.setValue(String.tap_empty, at: path)
    }

    private static func obtainCurrentLanguage() -> String {

        if let storedLanguage = self.dataSource?.userDefaultsLanguage {

            return storedLanguage
        }

        let bundleLanguages = Bundle.main.preferredLocalizations

        let supportedLanguages = self.dataSource?.initiallySupportedLanguages ?? bundleLanguages

        for language in bundleLanguages {

            if supportedLanguages.contains(language) {

                return language
            }
        }

        return Locale.tap_enUS.identifier
    }

    private func checkIfLayoutDirectionChangedAndPostNotification(from oldLanguage: String, to newLanguage: String) {

        let lastDirectionIsRTL = self.isLanguageRightToLeft(oldLanguage)
        let currentDirectionIsRTL = self.isLanguageRightToLeft(newLanguage)

        if lastDirectionIsRTL != currentDirectionIsRTL {

            NotificationCenter.default.post(name: .layoutDirectionChanged, object: nil)
        }
    }
}

// MARK: - TapDatabaseObserver
extension LocalizationManager: TapDatabaseObserver {

    public var paths: [DatabasePath] {

        return [TapDatabase.Path.localization, TapDatabase.Path.SupportedLanguages.images, TapDatabase.Path.SupportedLanguages.languages]
    }

    public func valueChanged(_ value: Any, at path: DatabasePath) {

        switch path {

        case TapDatabase.Path.localization:

            if let data = value as? Constants.LocalizationType {

                self.localizationData = data
                NotificationCenter.default.post(name: .localizationChanged, object: nil)
            }

        case TapDatabase.Path.SupportedLanguages.languages:

            if let languages = value as? Constants.SupportedLanguagesType {

                self.supportedLanguages = languages
                NotificationCenter.default.post(name: .supportedLanguagesListChanged, object: nil)
            }

        case TapDatabase.Path.SupportedLanguages.images:

            if let images = value as? Constants.SupportedLanguagesImages {

                self.languageIcons = images
                NotificationCenter.default.post(name: .localizationChanged, object: nil)
            }

        default:

            break
        }
    }

    public func valueDisappeared(at path: DatabasePath) {

        switch path {

        case TapDatabase.Path.localization:

            self.localizationData = [:]
            NotificationCenter.default.post(name: .localizationChanged, object: nil)

        case TapDatabase.Path.SupportedLanguages.languages:

            self.supportedLanguages = []
            NotificationCenter.default.post(name: .supportedLanguagesListChanged, object: nil)

        case TapDatabase.Path.SupportedLanguages.images:

            self.languageIcons = [:]
            NotificationCenter.default.post(name: .localizationChanged, object: nil)

        default:

            break
        }
    }
}
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
