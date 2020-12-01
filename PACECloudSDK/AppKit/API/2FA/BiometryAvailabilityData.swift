//
//  BiometryAvailabilityData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

struct BiometryAvailabilityData: BaseQueryParams {
    enum StatusCode: Int {
        case available = 200
        case notAvailable = 404

        init(available: Bool) {
            self = available ? .available : .notAvailable
        }
    }

    let host: String
    let redirectUri: String
    let state: String

    var statusCode: Int? = StatusCode.notAvailable.rawValue

    init?(from query: String, host: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)
        self.init(from: queryItems, host: host)
    }

    init?(from queryItems: [String: String], host: String) {
        guard let redirectUri = queryItems[URLParam.redirectUri.rawValue] else { return nil }

        self.host = host
        self.redirectUri = redirectUri
        self.state = queryItems[URLParam.state.rawValue] ?? ""
    }
}
