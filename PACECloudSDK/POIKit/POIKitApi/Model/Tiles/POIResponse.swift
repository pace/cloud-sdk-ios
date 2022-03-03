//
//  POIResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct POIResponse {
    let tilesResponse: TilesResponse
    let pois: [POIKit.GasStation]
}
