//
//  AppCommunicationData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension AppKit {
    struct EmptyRequestData: Codable {
        let id: String
    }

    struct AppRequestData<T: Codable>: Codable {
        let id: String
        let message: T
    }

    struct DisableAction: Codable {
        let until: Double
    }

    struct OpenUrlInNewTabData: Codable {
        let url: String
        let cancelUrl: String
    }

    struct VerifyLocationData: Codable {
        let lat: Double
        let lon: Double
        let threshold: Double
    }

    struct GetAccessTokenData: Codable {
        let reason: String
        let oldToken: String?
    }

    // MARK: - 2FA
    enum BiometryMethod: String {
        case other, face, fingerprint
    }

    struct TOTPSecretData: Codable {
        let secret: String
        let period: Double
        let digits: Int
        let algorithm: String
        let key: String
    }

    struct GetTOTPData: Codable {
        let key: String
        let serverTime: Double
    }

    struct SetSecureData: Codable {
        let key: String
        let value: String
    }

    struct GetSecureData: Codable {
        let key: String
    }

    struct SetUserPropertyData: Codable {
        let key: String
        let value: String
        let update: Bool?
    }

    struct LogEventData: Codable {
        let key: String
        let parameters: [String: AnyCodable]
    }

    struct GetConfigData: Codable {
        let key: String
    }
}

public extension AppKit {
    enum GetAccessTokenReason: String {
        case unauthorized
        case other
    }

    struct GetAccessTokenResponse: Codable {
        public let accessToken: String
        public let isInitialToken: Bool

        public init(accessToken: String, isInitialToken: Bool = false) {
            self.accessToken = accessToken
            self.isInitialToken = isInitialToken
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.accessToken = try container.decode(.accessToken)
            self.isInitialToken = try container.decodeIfPresent(.isInitialToken) ?? false
        }

        public func toDictionary() -> [String: Any] {
            return ["accessToken": accessToken, "isInitialToken": isInitialToken]
        }
    }

    struct LogoutResponse: Codable {
        let statusCode: HttpStatusCode

        public init(statusCode: HttpStatusCode) {
            self.statusCode = statusCode
        }
    }
}
