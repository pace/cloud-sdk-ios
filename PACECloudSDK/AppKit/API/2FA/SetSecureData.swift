//
//  SetSecureData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

struct SetSecureData: Codable {
    let key: String
    let value: String

    init?(from messageItems: [String: String]) {
        guard let key: String = messageItems["key"],
              let value: String = messageItems["value"]
        else { return nil }

        self.key = key
        self.value = value
    }
}
