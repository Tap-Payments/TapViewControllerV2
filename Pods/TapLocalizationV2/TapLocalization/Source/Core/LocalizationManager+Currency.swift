//
//  LocalizationManager+Currency.swift
//  TapLocalization
//
//  Created by Dennis Pashkov on 11/16/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

import TapDatabaseV2
import TapSwiftFixesV2
import TapLoggerV2

private var currencyFormatterAssociationKey: UInt8 = 0

/// Localization manager extension to support currency formatting.
public extension LocalizationManager {

    // MARK: - Public -
    // MARK: - Methods

    /// Returns localized currency symbol for the given currency code.
    ///
    /// - Parameter currencyCode: Curreny code.
    /// - Returns: Localized currency symbol.
    public func localizedCurrencySymbol(for currencyCode: String) -> String {

        var currencySymbol = (self.locale as NSLocale).displayName(forKey: .currencySymbol, value: currencyCode) ?? currencyCode
        self.optionallyHardcodeCurrencySymbol(&currencySymbol)

        return currencySymbol
    }

    /// Returns number of fraction digits for the specified currency code.
    ///
    /// - Parameter currencyCode: Currency code.
    /// - Returns: Number of fraction digits.
    public func numberOfFractionDigits(for currencyCode: String) -> Int {

        return synchronized(self.currencyFormatter) {

            self.currencyFormatter.currencyCode = currencyCode
            return self.currencyFormatter.maximumFractionDigits
        }
    }

    /// Returns localized string with the given amount and currency.
    ///
    /// - Parameters:
    ///   - amount: Amount
    ///   - currencyCode: Currency code
    /// - Returns: Localized amount string.
    public func localizedAmountString(with amount: Decimal, currencyCode: String) -> String {

        return self.localizedAmountString(with: amount, currencyCode: currencyCode, displayCurrency: true)
    }

    /// Returns localized amount string with the given amount and currency, optionally not displaying the currency.
    ///
    /// - Parameters:
    ///   - amount: Amount
    ///   - currencyCode: Currency code.
    ///   - displayCurrency: Boolean value that determines whether the currency symbol should be displayed.
    /// - Returns: Localized amount string.
    public func localizedAmountString(with amount: Decimal, currencyCode: String, displayCurrency: Bool) -> String {

        return synchronized(self.currencyFormatter) {

            self.currencyFormatter.locale = self.locale
            self.currencyFormatter.currencyCode = currencyCode

            self.currencyFormatter.positiveFormat = nil
            self.currencyFormatter.negativeFormat = nil

            let positiveFormat = self.currencyFormatter.positiveFormat
            let negativeFormat = self.currencyFormatter.negativeFormat

            var currencySymbol = String.tap_empty
            if displayCurrency {

                currencySymbol = self.localizedCurrencySymbol(for: currencyCode)
            }

            self.currencyFormatter.locale = Locale.tap_enUS

            self.currencyFormatter.positiveFormat = positiveFormat
            self.currencyFormatter.negativeFormat = negativeFormat
            self.currencyFormatter.currencySymbol = currencySymbol

            if let amountString = self.currencyFormatter.string(from: amount as NSDecimalNumber) {

                return amountString
            }
            else {

                DebugLog("Somehow could not localize amount along with currency symbol. Using default format.")
                return currencySymbol + (amount as NSDecimalNumber).stringValue
            }
        }
    }

    public func localizedAmountString(with amount: Decimal, currencyCode: String, amountAttributes: [NSAttributedString.Key: Any?]?, currencyAttributes: [NSAttributedString.Key: Any?]?) -> NSAttributedString {

        let amountString = self.localizedAmountString(with: amount, currencyCode: currencyCode)
        let currencySymbol = self.localizedCurrencySymbol(for: currencyCode)

        let currencyRange = (amountString as NSString).range(of: currencySymbol)

        let mutableResultString = NSMutableAttributedString(string: amountString, attributes: amountAttributes?.tap_nonOptionalRepresentation)
        if currencyRange.location != NSNotFound && currencyRange.length > 0 {

            mutableResultString.setAttributes(currencyAttributes?.tap_nonOptionalRepresentation, range: currencyRange)
        }

        return NSAttributedString(attributedString: mutableResultString)
    }

    // MARK: - Private -
    // MARK: Properties

    private var currencyFormatter: NumberFormatter {

        get {

            if let result = objc_getAssociatedObject(self, &currencyFormatterAssociationKey) as? NumberFormatter {

                return result
            }

            let formatter = NumberFormatter(locale: Locale.tap_enUS)
            formatter.numberStyle = .currency
            formatter.allowsFloats = true
            formatter.alwaysShowsDecimalSeparator = true

            self.currencyFormatter = formatter

            return formatter
        }
        set {

            objc_setAssociatedObject(self, &currencyFormatterAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: Methods

    private func optionallyHardcodeCurrencySymbol(_ currencySymbol: inout String) {

        let replacements = [

            "KWD": "KD",
            "د.ك.‏": "د.ك"
        ]

        for (wrongValue, correctValue) in replacements where currencySymbol == wrongValue {

            currencySymbol = correctValue
            break
        }
    }
}
