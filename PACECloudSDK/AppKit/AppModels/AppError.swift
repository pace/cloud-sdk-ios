//
//  AppError.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension AppKit {
    enum AppError: Equatable, CustomStringConvertible {
        case noLocationFound
        case locationNotAuthorized
        case couldNotFetchApp
        case failedRetrievingUrl
        case fetchAlreadyRunning
        case paymentError
        case badRequest
        case invalidURNFormat
        case customURLSchemeNotSet
        case other(Error)

        public var description: String {
            switch self {
            case .noLocationFound:
                return "Couldn't find current location"

            case .locationNotAuthorized:
                return "Location permissions not granted"

            case .couldNotFetchApp:
                return "Could not fetch app"

            case .fetchAlreadyRunning:
                return "App Fetch currently running"

            case .failedRetrievingUrl:
                return "Failed to retrieve url"

            case .paymentError:
                return "Failed processing payment"

            case .badRequest:
                return "Request does not match expected format"

            case .invalidURNFormat:
                return "The passed reference value does not conform to the URN format"

            case .customURLSchemeNotSet:
                return "Custom URL scheme couldn't be opened"

            case .other(let error):
                return error.localizedDescription
            }
        }

        // swiftlint:disable cyclomatic_complexity
        public static func == (lhs: AppError, rhs: AppError) -> Bool {
            switch (lhs, rhs) {
            case (.noLocationFound, .noLocationFound):
                return true

            case (.locationNotAuthorized, .locationNotAuthorized):
                return true

            case (.couldNotFetchApp, .couldNotFetchApp):
                return true

            case (.fetchAlreadyRunning, .fetchAlreadyRunning):
                return true

            case (.failedRetrievingUrl, .failedRetrievingUrl):
                return true

            case (.paymentError, .paymentError):
                return true

            case (.badRequest, .badRequest):
                return true

            case (.invalidURNFormat, .invalidURNFormat):
                return true

            case (.customURLSchemeNotSet, .customURLSchemeNotSet):
                return true

            case (.other(let lhs), .other(let rhs)):
                return lhs.localizedDescription == rhs.localizedDescription

            default:
                return false
            }
        }
    }
}
