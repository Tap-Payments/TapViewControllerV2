//
//  TapDatabaseDataSource.swift
//  TapDatabase
//
//  Created by Dennis Pashkov on 11/14/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

/// Data source for Tap Database.
public protocol TapDatabaseDataSource: class {

    // MARK: Properties

    /// Firebase database reference.
    /// This is required step to get the instance of Database here,
    /// because FIRAppNotConfigured exception will be thrown
    /// on attempt to get it from the module different from the main.
    var database: TapDatabaseInterface { get }
}
