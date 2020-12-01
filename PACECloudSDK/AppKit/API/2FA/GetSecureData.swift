//
//  GetSecureData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

struct GetSecureData: BaseQueryParams {
    enum StatusCode: Int {
        case notFound = 404
        case notAllowed = 405
        case internalError = 500
    }

    // Params for request
    let host: String
    let key: String
    let redirectUri: String
    let state: String

    // Params for response
    var value: String?
    var statusCode: Int?

    init?(from query: String, host: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)
        self.init(from: queryItems, host: host)
    }

    init?(from queryItems: [String: String], host: String) {
        guard let key = queryItems["key"], let redirectUri = queryItems[URLParam.redirectUri.rawValue] else { return nil }

        self.host = host
        self.key = key
        self.redirectUri = redirectUri
        self.state = queryItems[URLParam.state.rawValue] ?? ""
    }
}
