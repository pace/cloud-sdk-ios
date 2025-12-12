//
//  IDKitConstants.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

struct IDKitConstants {
    static let logTag = "[IDKit]"
    static let kcIdpHint = "kc_idp_hint"
    static let jwtSubjectKey = "sub"

    struct UserDefaults {
        static let sessionCache = "sessionCache"
        static let exchangeTokenCache = "exchangeTokenCache"
    }
}
