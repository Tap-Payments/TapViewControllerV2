//
//  TapDatabaseInterface.swift
//  TapDatabase
//
//  Created by Dennis Pashkov on 11/14/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

/// Database interface. Database class from Firebase conforms to it.
public protocol TapDatabaseInterface: class {

    // MARK: Properties

    /// Defines if persistence is enabled.
    var isPersistenceEnabled: Bool { get set }

    // MARK: Methods

    /// Returns DB reference.
    ///
    /// - Returns: DB reference.
    func dbReference() -> TapDatabaseReferenceInterface

    /// Returns DB reference with the specified path.
    ///
    /// - Parameter path: Path
    /// - Returns: DB reference.
    func dbReference(withPath path: String) -> TapDatabaseReferenceInterface
}
