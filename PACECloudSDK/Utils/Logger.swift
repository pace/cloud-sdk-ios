//
//  Logger.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class Logger {
    private static let logTag = Constants.logTag
    class var moduleTag: String { "" }

    enum Level: CustomStringConvertible {
        case verbose
        case info
        case warning
        case error
        case critical

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

            case .critical:
                return "[C]"
            }
        }
    }

    class func v(_ message: String) {
        NSLog("\(logTag)\(moduleTag)\(Level.verbose.description) - \(message)")
    }

    class func i(_ message: String) {
        NSLog("\(logTag)\(moduleTag)\(Level.info.description) - \(message)")
    }

    class func w(_ message: String) {
        NSLog("\(logTag)\(moduleTag)\(Level.warning.description) - \(message)")
    }

    class func e(_ message: String) {
        NSLog("\(logTag)\(moduleTag)\(Level.error.description) - \(message)")
    }

    class func c(_ message: String) {
        NSLog("\(logTag)\(moduleTag)\(Level.critical.description) - \(message)")
    }
}
