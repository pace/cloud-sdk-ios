//
//  GetSecureData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

struct GetSecureData {
    // Params for request
    let host: String
    let key: String

    init?(from messageItems: [String: String], host: String) {
        guard let key = messageItems["key"] else { return nil }

        self.host = host
        self.key = key
    }
}
