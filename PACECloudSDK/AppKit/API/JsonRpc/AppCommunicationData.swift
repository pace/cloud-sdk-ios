//
//  AppCommunicationData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension AppKit {
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
}
