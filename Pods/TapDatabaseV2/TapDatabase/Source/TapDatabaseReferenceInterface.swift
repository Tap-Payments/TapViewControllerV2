//
//  TapDatabaseReferenceInterface.swift
//  TapDatabase
//
//  Created by Dennis Pashkov on 11/14/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

/// Database reference interface. DatabaseReferece from Firebase conforms to it.
public protocol TapDatabaseReferenceInterface {

    // MARK: Methods

    /// Relative database reference.
    ///
    /// - Parameter path: Relative path.
    /// - Returns: TapDatabaseReferenceInterface
    func child(at path: String) -> TapDatabaseReferenceInterface

    /// Sets value at a given node.
    ///
    /// - Parameter value: Value to set. Nullable.
    func setValue(_ value: Any?)

    /// Defines if database is synced with the server.
    ///
    /// - Parameter keepSynced: Boolean parameter.
    func keepSynced(_ keepSynced: Bool)

    /// Observes given event with a closure
    ///
    /// - Parameters:
    ///   - eventType: Event type.
    ///   - closure: Closure to call on event.
    /// - Returns: Pointer to the observer.
    func observeEvent(_ eventType: TapDataEventType, with closure: @escaping (TapDataSnapshotInterface) -> Swift.Void) -> UInt

    /// Removes observer with the given handle.
    ///
    /// - Parameter handle: Observer handle.
    func removeObserver(withHandle handle: UInt)
}
