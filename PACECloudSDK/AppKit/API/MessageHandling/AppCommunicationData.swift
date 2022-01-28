//
//  AppCommunicationData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PassKit

public extension AppKit {
    enum GetAccessTokenReason: String {
        case unauthorized
        case other
    }

    enum BiometryMethod: String {
        case other, face, fingerprint
    }

    struct LogoutResponse: Codable {
        let statusCode: HttpStatusCode

        public init(statusCode: HttpStatusCode) {
            self.statusCode = statusCode
        }
    }
}
