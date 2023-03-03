//
//  Token.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension OneTimePassword {
    struct Token: Equatable {
        let name: String
        let issuer: String
        let generator: Generator

        init(name: String = "", issuer: String = "", generator: Generator) {
            self.name = name
            self.issuer = issuer
            self.generator = generator
        }

        var currentPassword: String? {
            let currentTime = Date()
            return try? generator.password(at: currentTime)
        }
    }
}
