//
//  TapViewControllerLogger.swift
//  TapViewController
//
//  Created by Dennis Pashkov on 12/7/17.
//  Copyright © 2018 Tap Payments. All rights reserved.
//

import func TapLoggerV2.DebugLog

/// Logger.
internal class TapViewControllerLogger {

    // MARK: - Internal -
    // MARK: Methods

    internal static func debugLog(_ format: String, _ args: CVarArg..., filename: String = #file, line: Int = #line, funcName: String = #function) {

        DebugLog(format, args, filename: filename, line: line, funcName: funcName)
    }
}
