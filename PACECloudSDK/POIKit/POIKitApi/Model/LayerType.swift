//
//  LayerType.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum LayerType: String {
    case poi

    var defaultTimeToLive: Int {
        switch self {
        case .poi:
            return POIKitConfig.poiTileTimeToLive
        }
    }
}
