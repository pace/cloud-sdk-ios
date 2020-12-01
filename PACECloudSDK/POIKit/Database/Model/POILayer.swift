//
//  POILayer.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit {
    /// Point Of Interest layers, used for filtering
    enum POILayer: String {
        /// gas station, will map to class `GasStation`
        case gasStation
        /// unknow, generic POI with no known layer
        case unknown
    }
}
