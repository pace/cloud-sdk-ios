//
//  IDKitError.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension IDKit {
    enum IDKitError: Error, CustomStringConvertible {
        case invalidAuthorizationEndpoint
        case invalidTokenEndpoint
        case invalidUserEndpoint
        case invalidRedirectUrl
        case invalidIssuerUrl
        case invalidPresentingViewController
        case invalidSession
        case failedRetrievingSessionWhileAuthorizing
        case failedRetrievingConfigurationWhileDiscovering
        case internalError
        case statusCode(Int)
        case invalidHTTPURLResponse(URL)
        case invalidData(URL)
        case failedTokenRefresh(Error)
        case other(Error)

        public var description: String {
            switch self {
            case .invalidAuthorizationEndpoint:
                return "The provided authorizationEndpoint isn't a valid url."

            case .invalidTokenEndpoint:
                return "The provided tokenEndpoint isn't a valid url."

            case .invalidUserEndpoint:
                return "The provided userEndpoint isn't a valid url."

            case .invalidRedirectUrl:
                return "The provided redirectUrl isn't a valid url."

            case .invalidIssuerUrl:
                return "The provided issuerUrl isn't a valid url."

            case .invalidPresentingViewController:
                return "The provided presentingViewController is nil."

            case .invalidSession:
                return "The current session is either invalid or expired which may be caused by resetting the session beforehand. Authorize again to create a new session."

            case .failedRetrievingSessionWhileAuthorizing:
                return "The authorization request failed because the session couldn't be retrieved."

            case .failedRetrievingConfigurationWhileDiscovering:
                return "The discovery failed because the configuration couldn't be retrieved."

            case .internalError:
                return "An internal error occured."

            case .statusCode(let statusCode):
                return "Retrieved response with status code \(statusCode)"

            case .invalidHTTPURLResponse(let url):
                return "The retrieved HTTPURLResponse is invalid for \(url.absoluteString)"

            case .invalidData(let url):
                return "The retrieved data is invalid for \(url.absoluteString)"

            case .failedTokenRefresh(let error):
                return "The token refresh failed and the session has been reset automatically (\(error))."

            case .other(let error):
                return error.localizedDescription
            }
        }
    }
}
