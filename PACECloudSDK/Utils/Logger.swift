//
//  Logger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public protocol PACECloudSDKLoggingDelegate: AnyObject {
    func didLog(_ log: String)
}

class Logger {
    private static let logTag = Constants.logTag
    class var moduleTag: String { "" }

    private static let loggingQueue = DispatchQueue(label: "pacecloudsdklogger", qos: .background)
    private static let dateFormatter: DateFormatter = .init(formatString: "yyyy-MM-dd HH:mm:ss.SSS")

    enum Level: CustomStringConvertible {
        case verbose
        case info
        case warning
        case error

        var description: String {
            switch self {
            case .verbose:
                return "[V]"

            case .info:
                return "[I]"

            case .warning:
                return "[W]"

            case .error:
                return "[E]"
            }
        }
    }

    static func v(_ message: String, passToClient: Bool = true) {
        log(message: message, level: Level.verbose.description, passToClient: passToClient)
    }

    static func i(_ message: String, passToClient: Bool = true) {
        log(message: message, level: Level.info.description, passToClient: passToClient)
    }

    static func w(_ message: String, passToClient: Bool = true) {
        log(message: message, level: Level.warning.description, passToClient: passToClient)
    }

    static func e(_ message: String, passToClient: Bool = true) {
        log(message: message, level: Level.error.description, passToClient: passToClient)
    }

    static func pwa(_ message: String) {
        log(message: message, level: "[PWA]", passToClient: true)
    }

    private static func log(message: String, level: String, passToClient: Bool) {
        loggingQueue.async {
            let log = "\(logTag)\(moduleTag)\(level) \(message)"

            NSLog(log)

            guard PACECloudSDK.shared.isLoggingEnabled, passToClient else { return }

            let timestamp = dateFormatter.string(from: Date())
            let timestampLog = "\(timestamp) \(log)"
            PACECloudSDK.shared.loggingDelegate?.didLog(timestampLog)
        }
    }
}
