//
//  CLLocationCoordinate2D+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    // https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Swift
    func tileInformation(forZoomLevel zoom: Int) -> TileInformation {
        let x = Int(floor((longitude + 180) / 360.0 * pow(2.0, Double(zoom))))
        let y = Int(floor((1 - log( tan( latitude * Double.pi / 180.0 ) + 1 / cos( latitude * Double.pi / 180.0 )) / Double.pi ) / 2 * pow(2.0, Double(zoom))))

        return TileInformation(zoomLevel: Int(zoom), x: x, y: y)
    }

    func move(by distanceKm: Double, atBearingDegrees bearingDegrees: Double) -> CLLocationCoordinate2D {
        let distanceRadians = distanceKm / POIKitConfig.earthRadiusInKilometers
        let bearingRadians = bearingDegrees.toRadian
        let fromLatRadians = self.latitude.toRadian
        let fromLonRadians = self.longitude.toRadian

        let toLatRadians = asin( sin(fromLatRadians) * cos(distanceRadians)
            + cos(fromLatRadians) * sin(distanceRadians) * cos(bearingRadians) )

        var toLonRadians = fromLonRadians + atan2(sin(bearingRadians)
            * sin(distanceRadians) * cos(fromLatRadians), cos(distanceRadians)
                - sin(fromLatRadians) * sin(toLatRadians))

        // adjust toLonRadians to be in the range -180 to +180...
        toLonRadians = fmod((toLonRadians + 3 * Double.pi), (2 * Double.pi)) - Double.pi

        return CLLocationCoordinate2D(latitude: toLatRadians.toDegrees, longitude: toLonRadians.toDegrees)
    }

    func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        return CLLocation(latitude: self.latitude, longitude: self.longitude).distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }

    func calculateCoordinateLocation(between startCoordinate: CLLocationCoordinate2D, and endCoordinate: CLLocationCoordinate2D) -> CoordinateLocation {
        let point = Vector2(coordinate: self)
        let start = Vector2(coordinate: startCoordinate)
        let end = Vector2(coordinate: endCoordinate)

        if start.x == end.x && start.y == end.y {
            return .before
        }

        let startToPoint = point - start
        let startToEnd = end - start

        let param = startToPoint.dot(startToEnd) / startToEnd.lengthSquared
        return CoordinateLocation(modifier: param)
    }

    func getBearing(to point2: CLLocationCoordinate2D) -> Double {
        let lat1 = self.latitude.toRadian
        let lon1 = self.longitude.toRadian

        let lat2 = point2.latitude.toRadian
        let lon2 = point2.longitude.toRadian

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        return (radiansBearing.toDegrees + 360).truncatingRemainder(dividingBy: 360)
    }

    func direction(to coordinate: CLLocationCoordinate2D) -> CLLocationDirection {
        let deltaLongitude = coordinate.longitude - self.longitude
        let deltaLatitude = coordinate.latitude - self.latitude
        let angle = (Double.pi * 0.5) - atan(deltaLatitude / deltaLongitude)

        if deltaLongitude > 0 {
            return angle
        } else if deltaLongitude < 0 {
            return angle + Double.pi
        } else if deltaLatitude < 0 {
            return Double.pi
        }

        return 0.0
    }

    /**
     Returns a Boolean value indicating whether two coordinates are equal.

     - parameter lhs: Coordinate to compare
     - parameter rhs: Another coordinate to compare
     - returns: if coordinates are equal
     */
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    // Algorithm from: https://wrf.ecse.rpi.edu//Research/Short_Notes/pnpoly.html
    func isIn(polygon: [CLLocationCoordinate2D]) -> Bool {
        guard var j = polygon.last else { return false }
        var isInPolygon = false
        for i in polygon {
            let a = (i.longitude > longitude) != (j.longitude > longitude)
            let b = (latitude < (j.latitude - i.latitude) * (longitude - i.longitude) / (j.longitude - i.longitude) + i.latitude)
            if a && b { isInPolygon.toggle() }
            j = i
        }
        return isInPolygon
    }

    func tileCoordinate(withZoom zoom: Int) -> (x: Int, y: Int) {
        let tileX = Int(floor((longitude + 180) / 360.0 * pow(2.0, Double(zoom))))
        let tileY = Int(floor((1 - log( tan( latitude * Double.pi / 180.0 ) + 1 / cos( latitude * Double.pi / 180.0 )) / Double.pi ) / 2 * pow(2.0, Double(zoom))))

        return (tileX, tileY)
    }
}
