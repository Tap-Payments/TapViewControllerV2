//
//  TapDataSnapshotInterface.swift
//  TapDatabase
//
//  Created by Dennis Pashkov on 11/14/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

/// Tap Data Snapshot. DataSnapshot class from Firebase conforms to it.
public protocol TapDataSnapshotInterface {

    // MARK: Properties

    /// Snapshot value.
    var value: Any? { get }

    // MARK: Methods

    /// Defines if snapshot exists.
    ///
    /// - Returns: Boolean value which determines whether the snapshot exists.
    func exists() -> Bool
}
