//
//  AppKit+Authorization.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

class AppKitAuthorization {
    var apiKey: String?

    func setup(apiKey: String?) {
        self.apiKey = apiKey
    }
}
