//
//  SetSecureData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

struct SetSecureData: Codable {
    let key: String
    let value: String
    let host: String

    init?(from query: String, host: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)
        self.init(from: queryItems, host: host)
    }

    init?(from queryItems: [String: String], host: String) {
        guard let key: String = queryItems["key"], let value: String = queryItems["value"] else { return nil }

        self.key = key
        self.value = value
        self.host = host
    }
}
