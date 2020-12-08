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

    init?(from messageItems: [String: AnyHashable]) {
        guard let secret = messageItems[TOTPURLParam.secret.rawValue] as? String,
            let period = messageItems[TOTPURLParam.period.rawValue] as? Double,
            let digits = messageItems[TOTPURLParam.digits.rawValue] as? Int,
            let algorithm = messageItems[TOTPURLParam.algorithm.rawValue] as? String,
            let key = messageItems[TOTPURLParam.key.rawValue] as? String else { return nil }

        self.secret = secret
        self.period = period
        self.digits = digits
        self.algorithm = algorithm
        self.key = key
    }
}
