//
//  UserInfo.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension IDKit {
    struct UserInfo: Decodable {
        public let id: String?
        public let firstName: String?
        public let lastName: String?
        public let isEmailVerified: Bool?
        public let email: String?
    }
}

extension IDKit.UserInfo {
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case isEmailVerified = "email_verified"
        case email, id
    }
}
