//
//  PACECloudSlimSDK+Kits.swift
//  PACECloudSlimSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension PACECloudSDK {
    func setupKits(with config: Configuration) {
        IDKit.determineOIDConfiguration(with: config.customOIDConfiguration)
        AppKit.shared.setup()
        // POIKit setup not needed
    }
}
