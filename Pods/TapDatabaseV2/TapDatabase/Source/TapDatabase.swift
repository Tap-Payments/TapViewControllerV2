//
//  TapDatabase.swift
//  TapDatabase
//
//  Created by Dennis Pashkov on 11/10/17.
//  Copyright © 2017 Tap Payments. All rights reserved.
//

import TapAdditionsKitV2

public typealias DatabasePath = String

/// Tap Database
public class TapDatabase {

    // MARK: - Public -

    /// Database paths structure.
    public struct Path {

        /// Localization path.
        public static let localization: DatabasePath = "loc"

        /// Supported languages path.
        public static let supportedLanguages: DatabasePath = "s_langs"

        /// Missing localizations path.
        public static let missingLocalization: DatabasePath = "addLocalization"

        /// Errors path.
        public static let errors: DatabasePath = "errors"

        /// Countries path.
        public static let countries: DatabasePath = "Countries"

        /// Supported languages branch constants.
        public struct SupportedLanguages {

            /// Images path.
            public static let images: DatabasePath = "\(Path.supportedLanguages)/images"

            /// Languages path.
            public static let languages: DatabasePath = "\(Path.supportedLanguages)/langs"

            private init() {}
        }

        private init() {}
    }

    // MARK: Properties

    /// Static data source.
    public static weak var dataSource: TapDatabaseDataSource?

    /// Shared instance.
    /// Note: Shared instance must be called ONLY after dataSource is set. Thanks Google...
    public static let shared = TapDatabase()

    /// Defines DB cache location (memory or disk).
    public var isPersistenceEnabled: Bool {

        get {

            return self.database.isPersistenceEnabled
        }
        set {

            self.database.isPersistenceEnabled = newValue
        }
    }

    // MARK: Methods

    /// Adds database observer.
    /// Once the observer is added and there is already a snapshot for the observer's path,
    /// valueChanged(_:at:) will be called on observer.
    ///
    /// - Parameter observer: Observer to add.
    public func addObserver(_ observer: TapDatabaseObserver) {

        let addedPaths = self.addObserverIfNotYetAdded(observer)
        self.deliverExistingSnapshots(to: observer, at: addedPaths)

        for path in addedPaths {

            self.observe(path)
        }
    }

    /// Removes the observer.
    ///
    /// - Parameter observer: Observer to remove.
    public func removeObserver(_ observer: TapDatabaseObserver) {

        for path in observer.paths {

            guard let storage = (self.storages.filter { $0.path == path }).first,
                  let index = (self.storages.index { $0 === storage }) else { continue }

            if storage.remove(observer) {

                self.storages.remove(at: index)
                self.stopObserving(path)
            }
        }
    }

    /// Removes all observers.
    public func removeAllObservers() {

        let observers = self.allObservers

        for observer in observers {

            self.removeObserver(observer)
        }
    }

    /// This method is a method to update the DB.
    /// Sets the value at a given path.
    ///
    /// - Parameters:
    ///   - value: Value. It can be any object that is supported by JSON
    ///           (e.g. String, Number and collection types, such as Array and Dictionary).
    ///   - path: Path where to put the value. Both simple and complex paths are supported ('loc', 'loc/en/Done').
    public func setValue(_ value: Any?, at path: DatabasePath) {

        self.database.dbReference().child(at: path).setValue(value)
    }

    deinit {

        self.removeAllObservers()
    }

    // MARK: - Private -

    private struct Constants {

        fileprivate static let observersDeliveryQueueName = "company.tap.TapDatabase.obervers_delivery_queue"
    }

    // MARK: Properties

    private let database: TapDatabaseInterface

    private lazy var storages: [TapObserversStorage] = []

    private lazy var snapshots: [DatabasePath: TapDataSnapshotInterface] = [:]

    private lazy var observablePaths: [DatabasePath: (TapDatabaseReferenceInterface, UInt)] = [:]

    private lazy var observersDeliveryQueue = DispatchQueue(label: Constants.observersDeliveryQueueName)

    private var allObservers: [TapDatabaseObserver] {

        var result: [TapDatabaseObserver] = []

        for storage in self.storages {

            for observer in storage.observers {

                if !(result.contains { $0 === observer }) {

                    result.append(observer)
                }
            }
        }

        return result
    }

    // MARK: Methods

    private init() {

        guard let dataSource = type(of: self).dataSource else {

            fatalError("TapDatabase dataSource is not set! Set it using TapDatabase.dataSource = ...")
        }

        self.database = dataSource.database
    }

    private func addObserverIfNotYetAdded(_ observer: TapDatabaseObserver) -> [DatabasePath] {

        var result: [DatabasePath] = []

        for path in observer.paths {

            if let storage = (self.storages.filter { $0.path == path }).first {

                if storage.add(observer) {

                    result.append(path)
                }

            } else {

                let storage = TapObserversStorage(path: path, observer: observer)
                self.storages.append(storage)

                result.append(path)
            }
        }

        return result
    }

    private func deliverExistingSnapshots(to observer: TapDatabaseObserver, at paths: [DatabasePath]) {

        for path in paths {

            if let snap = self.snapshots[path] {

                self.deliver(snap, at: path, to: [observer], callOnEmptySnapshot: false)
            }
        }
    }

    private func observe(_ path: DatabasePath) {

        guard !self.observablePaths.tap_allKeys.contains(path) else { return }

        let databaseReference = self.database.dbReference(withPath: path)
        databaseReference.keepSynced(true)

        let handle = databaseReference.observeEvent(.value) { [weak self] (snapshot) in

            guard let strongSelf = self else { return }

            strongSelf.snapshots[path] = snapshot

            guard let storage = (strongSelf.storages.filter { $0.path == path }).first else { return }

            strongSelf.deliver(snapshot, at: path, to: storage.observers)
        }

        self.observablePaths[path] = (databaseReference, handle)
    }

    private func stopObserving(_ path: DatabasePath) {

        guard let dbReferenceAndHandle = self.observablePaths[path] else { return }

        dbReferenceAndHandle.0.removeObserver(withHandle: dbReferenceAndHandle.1)

        self.observablePaths.removeValue(forKey: path)
        self.snapshots.removeValue(forKey: path)
    }

    private func deliver(_ snapshot: TapDataSnapshotInterface,
                         at path: DatabasePath,
                         to observers: [TapDatabaseObserver],
                         callOnEmptySnapshot: Bool = true) {

        let snapshotHasValue = snapshot.exists()

        for observer in observers {

            if let nonnullValue = snapshot.value, snapshotHasValue {

                self.observersDeliveryQueue.async {

                    observer.valueChanged(nonnullValue, at: path)
                }

                continue
            }

            if !snapshotHasValue && callOnEmptySnapshot {

                self.observersDeliveryQueue.async {

                    observer.valueDisappeared(at: path)
                }
            }
        }
    }
}
