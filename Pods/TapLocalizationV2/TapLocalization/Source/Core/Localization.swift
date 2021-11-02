//
//  Localization.swift
//  TapLocalization
//
//  Created by Dennis Pashkov on 11/16/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

/// Localization structure.
public struct Localization: RawRepresentable, Equatable, Hashable {

    // MARK: - Public -

    public typealias RawValue = String

    // MARK: Properties

    /// String representation of the receiver.
    public let rawValue: String

    /// Hash
    public var hashValue: Int {

        return self.rawValue.hashValue
    }

    /// Localized representation of the receiver.
    public var localized: String {

        return LocalizationManager.shared.localizedString(for: self.rawValue)
    }

    // MARK: Methods

    public init(_ rawValue: String) {

        self.init(rawValue: rawValue)
    }

    public init(rawValue: String) {

        self.rawValue = rawValue
    }
}
