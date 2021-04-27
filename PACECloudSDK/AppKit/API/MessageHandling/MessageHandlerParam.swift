//
//  MessageHandlerParam.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum MessageHandlerParam: String {
    // GetTOTP
    case totp
    case biometryMethod

    // Disable
    case until

    // Open url in new tab
    case url
    case cancelUrl

    // Verify location
    case lat
    case lon
    case threshold

    // Redirect scheme
    case link

    case value

    case error
    case statusCode
}

enum MessageHandlerStatusCode: String {
    case success = "Success"
    case badRequest = "Bad request"
    case notFound = "Not found"
    case unauthorized = "Unauthorized"
    case notAllowed = "Not allowed"
    case internalError = "Internal error"
    case requestTimeout = "Request timeout"

    var statusCode: String {
        let code: Int
        switch self {
        case .success:
            code = 200

        case .badRequest:
            code = 400

        case .notFound:
            code = 404

        case .unauthorized:
            code = 401

        case .notAllowed:
            code = 405

        case .requestTimeout:
            code = 408

        case .internalError:
            code = 500
        }

        return "\(code)"
    }
}
