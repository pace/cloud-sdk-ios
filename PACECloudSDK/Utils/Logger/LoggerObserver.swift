//
//  LoggerObserver.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension Logger {
    /// A single log occurrence, handed to every registered ``Observer``.
    struct Record: Sendable {
        public let timestamp: Date
        public let level: LogLevel
        /// The emitting logger's tags, e.g. `"[PACECloudSDK][IDKit]"` — `logTag` + `moduleTag`.
        public let tag: String
        public let message: String

        public init(timestamp: Date, level: LogLevel, tag: String, message: String) {
            self.timestamp = timestamp
            self.level = level
            self.tag = tag
            self.message = message
        }
    }

    /// Receives every log the SDK emits, so a host app can route them into its own
    /// storage or telemetry without the SDK persisting anything itself.
    ///
    /// Observers are held **weakly** — there is no need to call ``Logger/removeObserver(_:)``
    /// in `deinit`, but the host app has to keep its observer alive for as long as it
    /// wants records.
    ///
    /// ``logger(didCapture:)`` is called synchronously on the logger's internal background
    /// queue, never on the main queue. Hop to main yourself if your implementation needs
    /// it. Records arrive only for logs that pass the configured log level (see
    /// ``PACECloudSDK/setLogLevel(to:)``) and arrive regardless of `persistLogs`.
    ///
    /// Do not log through `Logger` from inside `logger(didCapture:)`. `Logger.i` and
    /// friends are public on an `open class`, so a host can; because `log` dispatches
    /// `async`, that self-feeds forever as a queue-spinning loop rather than overflowing
    /// the stack.
    ///
    /// A slow implementation cannot block a caller thread — nothing ever does
    /// `loggingQueue.sync`, and the queue is `qos: .background` — but it does back up
    /// that serial queue, and ``Logger/exportLogs(completion:)``/
    /// ``Logger/debugBundleDirectory(completion:)`` completions are enqueued on the same
    /// queue, so they stall behind it.
    protocol Observer: AnyObject {
        func logger(didCapture record: Record)
    }

    static func addObserver(_ observer: Observer) {
        LoggerObserverRegistry.shared.add(observer)
    }

    static func removeObserver(_ observer: Observer) {
        LoggerObserverRegistry.shared.remove(observer)
    }
}

/// Internal (not private) so tests can construct isolated instances instead of racing on
/// `.shared`.
final class LoggerObserverRegistry {
    static let shared = LoggerObserverRegistry()

    private struct WeakObserver {
        weak var observer: Logger.Observer?
    }

    private var observers: [WeakObserver] = []
    private let lock = NSLock()

    init() {}

    func add(_ observer: Logger.Observer) {
        lock.lock()
        defer { lock.unlock() }
        observers.removeAll { $0.observer == nil }
        observers.append(WeakObserver(observer: observer))
    }

    func remove(_ observer: Logger.Observer) {
        lock.lock()
        defer { lock.unlock() }
        observers.removeAll { $0.observer == nil || $0.observer === observer }
    }

    func notify(_ record: Logger.Record) {
        lock.lock()
        let activeObservers = observers.compactMap(\.observer)
        lock.unlock()
        activeObservers.forEach { $0.logger(didCapture: record) }
    }
}
