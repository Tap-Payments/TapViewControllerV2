//
//  TapDatabaseObserver.swift
//  TapDatabase
//
//  Created by Dennis Pashkov on 11/10/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

/// Tap Database Observer
public protocol TapDatabaseObserver: class {

    // MARK: Properties

    /// Observable database paths.
    var paths: [DatabasePath] { get }

    // MARK: Methods

    /// Is called when updated value has arrived for the given path.
    /// Once the observer is added in case if there is already a value, this method will also be triggered.
    ///
    /// - Parameters:
    ///   - value: Value.
    ///   - path: Database path.
    func valueChanged(_ value: Any, at path: DatabasePath)

    /// Is called when value disappears at a given path.
    /// NOTE: Will also be called if there was no value before.
    ///
    /// - Parameter path: Database path.
    func valueDisappeared(at path: DatabasePath)
}
