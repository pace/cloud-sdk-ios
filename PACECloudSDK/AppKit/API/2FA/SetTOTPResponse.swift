//
//  SetTOTPResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

struct SetTOTPResponse: BaseQueryParams {
    enum StatusCode: Int {
        case success = 200
        case failure = 500

        init(success: Bool) {
            self = success ? .success : .failure
        }
    }

    // Params from request
    let host: String
    let redirectUri: String
    let state: String

    // Params for response
    var statusCode: Int? = StatusCode.failure.rawValue

    init?(from query: String, host: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)
        self.init(from: queryItems, host: host)
    }

    init?(from queryItems: [String: String], host: String) {
        guard let redirectUri: String = queryItems[URLParam.redirectUri.rawValue] else { return nil }

        self.host = host
        self.redirectUri = redirectUri
        self.state = queryItems[URLParam.state.rawValue] ?? ""
    }
}
