//
//  PACECloudSDK+Kits.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension PACECloudSDK {
    func setupKits(with config: Configuration) {
        IDKit.determineOIDConfiguration(with: config.customOIDConfiguration, userAgentType: config.oidUserAgentType)
        AppKit.shared.setup()
        POIKit.setup()
    }
}
