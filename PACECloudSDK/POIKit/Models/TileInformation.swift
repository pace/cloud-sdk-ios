//
//  TileInformation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreGraphics
import CoreLocation

struct TileInformation: Equatable, Hashable {
    var zoomLevel: Int
    var x: Int
    var y: Int

    var id: String {
        return "\(zoomLevel)_\(x)_\(y)"
    }

    var tileCount: Int {
        return Int(pow(2.0, Double(zoomLevel)))
    }

    init(zoomLevel: Int, x: Int, y: Int) {
        let maxTileValue = Int(pow(2, Double(zoomLevel)) - 1)
        let xValue = x > maxTileValue ? x - maxTileValue : x
        let yValue = y > maxTileValue ? y - maxTileValue : y

        self.zoomLevel = zoomLevel
        self.x = xValue
        self.y = yValue
    }

    init?(id: String) {
        let components = id.split(separator: "_").compactMap { Int($0) }
        guard components.count == 3 else { return nil }
        self.zoomLevel = components[0]
        self.x = components[1]
        self.y = components[2]
    }

    // https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#Swift
    var coordinate: CLLocationCoordinate2D {
        let zoom = Double(zoomLevel)
        let lon_deg = Double(x) / pow(2.0, zoom) * 360 - 180
        let lat_rad = atan(sinh(Double.pi * (1 - 2 * Double(y) / pow(2.0, zoom))))
        let lat_deg = lat_rad * 180 / Double.pi

        return CLLocationCoordinate2D(latitude: lat_deg, longitude: lon_deg)
    }

    func getNextTileInformation(at course: Double, extended: Bool = false) -> [TileInformation] {
        let center = CGPoint(x: self.x, y: self.y)

        var points: [CGPoint] = []

        let allowedRotationDiff = 45.0 / 2.0

        if course.rotationDifference(to: 0) < allowedRotationDiff { // 0 -> top
            points = center.pointsAt(location: .top, extended: extended)
        } else if course.rotationDifference(to: 45) < allowedRotationDiff { // 45 -> topRight
            points = center.pointsAt(location: .topRight, extended: extended)
        } else if course.rotationDifference(to: 45 * 2) < allowedRotationDiff { // 90 -> right
            points = center.pointsAt(location: .right, extended: extended)
        } else if course.rotationDifference(to: 45 * 3) < allowedRotationDiff { // 135 -> bottomRight
            points = center.pointsAt(location: .bottomRight, extended: extended)
        } else if course.rotationDifference(to: 45 * 4) < allowedRotationDiff { // 180 -> bottom
            points = center.pointsAt(location: .bottom, extended: extended)
        } else if course.rotationDifference(to: 45 * 5) < allowedRotationDiff { // 225 -> bottomLeft
            points = center.pointsAt(location: .bottomLeft, extended: extended)
        } else if course.rotationDifference(to: 45 * 6) < allowedRotationDiff { // 270 -> left
            points = center.pointsAt(location: .left, extended: extended)
        } else if course.rotationDifference(to: 45 * 7) < allowedRotationDiff { // 315 -> topLeft
            points = center.pointsAt(location: .topLeft, extended: extended)
        } else { // 0 -> top
            points = center.pointsAt(location: .top, extended: extended)
        }

        var tiles = points.map { TileInformation(zoomLevel: zoomLevel, x: Int($0.x), y: Int($0.y)) }
        tiles.insert(self, at: 0)
        return tiles
    }

    func getSurroundingTiles () -> [TileInformation] {
        let center = CGPoint(x: self.x, y: self.y)

        var points: [CGPoint] = []
        points += center.pointsAt(location: .top, extended: false)
        points += center.pointsAt(location: .right, extended: false)
        points += center.pointsAt(location: .bottom, extended: false)
        points += center.pointsAt(location: .left, extended: false)

        let tiles = points.map { TileInformation(zoomLevel: zoomLevel, x: Int($0.x), y: Int($0.y)) }
        return Array(Set(tiles))
    }

    public static func == (lhs: TileInformation, rhs: TileInformation) -> Bool {
        return lhs.zoomLevel == rhs.zoomLevel && lhs.x == rhs.x && lhs.y == rhs.y
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }

    func getAdjacentTileInformation(for compass: Compass) -> TileInformation {
        let tileCount = self.tileCount
        switch compass {
        case .north:
            return TileInformation(zoomLevel: zoomLevel, x: x, y: (y + tileCount - 1) % tileCount)

        case .south:
            return TileInformation(zoomLevel: zoomLevel, x: x, y: (y + 1) % tileCount)

        case .east:
            return TileInformation(zoomLevel: zoomLevel, x: (x + 1) % tileCount, y: y)

        case .west:
            return TileInformation(zoomLevel: zoomLevel, x: (x + tileCount - 1) % tileCount, y: y)
        }
    }

    func getDistanceToTileBorderSide(at location: CLLocationCoordinate2D, heading: Compass) -> (Double, Compass) {
        switch heading {
        case .north, .south:
            let locX = long2x(location.longitude)
            let westDistance = locX - floor(locX)
            let eastDistance = ceil(locX) - locX
            if westDistance < eastDistance {
                return (CLLocationCoordinate2D(latitude: location.latitude, longitude: tilex2lon(floor(locX))).distance(from: location), .west)
            } else {
                return (CLLocationCoordinate2D(latitude: location.latitude, longitude: tilex2lon(ceil(locX))).distance(from: location), .east)
            }

        case .east, .west:
            let locY = lat2y(location.latitude)
            let northDistance = locY - floor(locY)
            let southDistance = ceil(locY) - locY
            if northDistance < southDistance {
                return (CLLocationCoordinate2D(latitude: tiley2lat(floor(locY)), longitude: location.longitude).distance(from: location), .north)
            } else {
                return (CLLocationCoordinate2D(latitude: tiley2lat(ceil(locY)), longitude: location.longitude).distance(from: location), .south)
            }
        }
    }

    func long2x(_ lon: Double) -> Double {
        return (lon + 180.0) / 360.0 * pow(2.0, Double(zoomLevel))
    }

    func tilex2lon(_ tileX: Double) -> Double {
        return tileX / pow(2.0, Double(zoomLevel)) * 360.0 - 180.0
    }

    func lat2y(_ lat: Double) -> Double {
        return (1.0 - log(tan(lat * Double.pi / 180.0) + 1.0 / cos(lat * Double.pi / 180.0)) / Double.pi) / 2.0 * pow(2.0, Double(zoomLevel))
    }

    func tiley2lat(_ tileY: Double) -> Double {
        let number = Double.pi - 2.0 * Double.pi * tileY / pow(2.0, Double(zoomLevel))
        return 180.0 / Double.pi * atan(0.5 * (exp(number) - exp(-number)))
    }
}

private extension CGPoint {
    enum Location {
        case top
        case topRight
        case right
        case bottomRight
        case bottom
        case bottomLeft
        case left
        case topLeft
    }

    func pointsAt(location: Location, extended: Bool) -> [CGPoint] {
        let points: [CGPoint]
        let newPoint: CGPoint
        switch location {
        case .top:
            points = [up.left, up, up.right]
            newPoint = self.up

        case .topRight:
            points = [up, up.right, right]
            newPoint = self.up.right

        case .right:
            points = [up.right, right, down.right]
            newPoint = self.right

        case .bottomRight:
            points = [right, right.down, down]
            newPoint = self.down.right

        case .bottom:
            points = [down.right, down, down.left]
            newPoint = self.down

        case .bottomLeft:
            points = [down, down.left, left]
            newPoint = self.down.left

        case .left:
            points = [left.down, left, left.up]
            newPoint = self.left

        case .topLeft:
            points = [left, left.up, up]
            newPoint = self.up.left
        }

        if extended {
            return points + newPoint.pointsAt(location: location, extended: false)
        } else {
            return points
        }
    }

    var up: CGPoint {
        return CGPoint(x: x, y: y - 1)
    }

    var down: CGPoint {
        return CGPoint(x: x, y: y + 1)
    }

    var right: CGPoint {
        return CGPoint(x: x + 1, y: y)
    }

    var left: CGPoint {
        return CGPoint(x: x - 1, y: y)
    }
}
