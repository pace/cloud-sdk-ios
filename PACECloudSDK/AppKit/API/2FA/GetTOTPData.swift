//
//  GetTOTPData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

enum BiometryMethod: String {
    case other, face, fingerprint
}

struct GetTOTPData {
    private enum GetTOTPRequestParam: String {
        case serverTime
        case key
    }

    // Params for request
    let host: String
    let key: String
    let serverTime: Double

    init?(from messageItems: [String: AnyHashable], host: String) {
        guard let serverTime = messageItems[GetTOTPRequestParam.serverTime.rawValue] as? Double,
            let key = messageItems[GetTOTPRequestParam.key.rawValue] as? String else { return nil }

        self.host = host
        self.key = key
        self.serverTime = serverTime
    }
}
