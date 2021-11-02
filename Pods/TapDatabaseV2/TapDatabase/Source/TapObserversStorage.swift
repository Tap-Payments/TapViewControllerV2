//
//  TapObserversStorage.swift
//  TapDatabase
//
//  Created by Dennis Pashkov on 11/10/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

/// Tap Observers Storage.
internal class TapObserversStorage {

    // MARK: - Internal -
    // MARK: Properties

    /// Observable path.
    internal let path: DatabasePath

    /// Observers.
    internal private(set) var observers: [TapDatabaseObserver]

    /// Initializes the storage with the path and first observer.
    ///
    /// - Parameters:
    ///   - path: Observable path.
    ///   - observer: Observer.
    internal init(path: DatabasePath, observer: TapDatabaseObserver) {

        self.path = path
        self.observers = [observer]
    }

    /// Adds an observer.
    ///
    /// - Parameter observer: Observer to add.
    /// - Returns: Boolean value which determines whether the observer was added.
    internal func add(_ observer: TapDatabaseObserver) -> Bool {

        guard !(self.observers.contains { $0 === observer }) else { return false }

        self.observers.append(observer)

        return true
    }

    /// Removes observer.
    ///
    /// - Parameter observer: Observer to remove.
    /// - Returns: Boolean value which determines whether there are no observers left.
    ///            true - there are no observer left, false otherwise.
    internal func remove(_ observer: TapDatabaseObserver) -> Bool {

        if let index = (self.observers.index { $0 === observer }) {

            self.observers.remove(at: index)
        }

        return self.observers.count == 0
    }

    deinit {

        self.observers.removeAll()
    }
}
