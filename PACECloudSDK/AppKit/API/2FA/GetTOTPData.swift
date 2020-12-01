//
//  GetTOTPData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

enum BiometryMethod: String {
    case other, face, fingerprint
}

struct GetTOTPData: BaseQueryParams {
    private enum GetTOTPRequestParam: String {
        case serverTime = "server_time"
        case key
    }

    enum StatusCode: Int {
        case unauthorized = 401
        case notFound = 404
        case notAllowed = 405
        case internalError = 500
    }

    // Params for request
    let host: String
    let key: String
    let serverTime: Double
    let redirectUri: String
    let state: String

    // Params for response
    var statusCode: Int?
    var totp: String?
    var biometryMethod: BiometryMethod?

    init?(from query: String, host: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)
        self.init(from: queryItems, host: host)
    }

    init?(from queryItems: [String: String], host: String) {
        guard let serverTime: Double = Double(queryItems[GetTOTPRequestParam.serverTime.rawValue] ?? ""),
            let key: String = queryItems[GetTOTPRequestParam.key.rawValue],
            let redirectUri: String = queryItems[URLParam.redirectUri.rawValue] else { return nil }

        self.host = host
        self.key = key
        self.serverTime = serverTime
        self.redirectUri = redirectUri
        self.state = queryItems[URLParam.state.rawValue] ?? ""
    }
}
