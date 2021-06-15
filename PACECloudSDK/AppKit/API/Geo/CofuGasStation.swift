//
//  CofuGasStation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public struct CofuGasStation {
    public let id: String
    public let coordinates: GeoAPICoordinate?
    public let polygon: [GeoAPICoordinates]?
    public let properties: [String: Any]
}
