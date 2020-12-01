//
//  CGPoint+Coordinates.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import CoreGraphics

extension CGPoint {
    func toGpsCoordinate(extent: UInt32, tileInformation: TileInformation?) -> CLLocationCoordinate2D {
        guard let tileInformation = tileInformation else {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }

        let size = Double(extent) * Double(truncating: pow(2, tileInformation.zoomLevel) as NSDecimalNumber)
        let x = Double(tileInformation.x * Int(extent))
        let y = Double(tileInformation.y * Int(extent))
        let lon_deg = (Double(self.x) + x) * 360 / size - 180
        let lat_rad = 180 - (Double(self.y) + y) * 360 / size
        let lat_deg = 360 / Double.pi * atan(exp( lat_rad * Double.pi / 180)) - 90
        return CLLocationCoordinate2D(latitude: lat_deg, longitude: lon_deg)
    }
}
