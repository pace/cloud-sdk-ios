//
//  TOTPSecretData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

struct TOTPSecretData: Codable {
    private enum TOTPURLParam: String {
        case secret
        case period
        case digits
        case algorithm
        case key
    }

    let secret: String
    let period: Double
    let digits: Int
    let algorithm: String
    let key: String

    init?(from query: String) {
        let queryItems = URLDecomposer.decomposeQuery(query)
        self.init(from: queryItems)
    }

    init?(from queryItems: [String: String]) {
        guard let secret: String = queryItems[TOTPURLParam.secret.rawValue],
            let period: Double = Double(queryItems[TOTPURLParam.period.rawValue] ?? ""),
            let digits: Int = Int(queryItems[TOTPURLParam.digits.rawValue] ?? ""),
            let algorithm: String = queryItems[TOTPURLParam.algorithm.rawValue],
            let key: String = queryItems[TOTPURLParam.key.rawValue] else { return nil }

        self.secret = secret
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
        self.key = key
    }
}
