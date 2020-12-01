//
//  Vector2+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

extension Vector2 {
    init(coordinate: CLLocationCoordinate2D) {
        self.init(Scalar(coordinate.latitude), Scalar(coordinate.longitude))
    }

    var toCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: Double(x), longitude: Double(y))
    }
}

extension Vector2 {
    static let zero = Vector2(0, 0)
    static let x = Vector2(1, 0)
    static let y = Vector2(0, 1)

    var lengthSquared: Scalar {
        return x * x + y * y
    }

    var length: Scalar {
        return sqrt(lengthSquared)
    }

    var inverse: Vector2 {
        return -self
    }

    init(_ x: Scalar, _ y: Scalar) {
        self.init(x: x, y: y)
    }

    init(_ v: [Scalar]) {
        assert(v.count == 2, "array must contain 2 elements, contained \(v.count)")
        self.init(v[0], v[1])
    }

    func toArray() -> [Scalar] {
        return [x, y]
    }

    func dot(_ v: Vector2) -> Scalar {
        return x * v.x + y * v.y
    }

    func cross(_ v: Vector2) -> Scalar {
        return x * v.y - y * v.x
    }

    func normalized() -> Vector2 {
        let lengthSquared = self.lengthSquared
        if lengthSquared ~= 0 || lengthSquared ~= 1 {
            return self
        }
        return self / sqrt(lengthSquared)
    }

    func rotated(by radians: Scalar) -> Vector2 {
        let cs = cos(radians)
        let sn = sin(radians)
        return Vector2(x * cs - y * sn, x * sn + y * cs)
    }

    func rotated(by radians: Scalar, around pivot: Vector2) -> Vector2 {
        return (self - pivot).rotated(by: radians) + pivot
    }

    func angle(with v: Vector2) -> Scalar {
        if self == v {
            return 0
        }

        let t1 = normalized()
        let t2 = v.normalized()
        let cross = t1.cross(t2)
        let dot = max(-1, min(1, t1.dot(t2)))

        return atan2(cross, dot)
    }

    func interpolated(with v: Vector2, by t: Scalar) -> Vector2 {
        return self + (v - self) * t
    }

    static prefix func - (v: Vector2) -> Vector2 {
        return Vector2(-v.x, -v.y)
    }

    static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    static func * (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.x * rhs.x, lhs.y * rhs.y)
    }

    static func * (lhs: Vector2, rhs: Scalar) -> Vector2 {
        return Vector2(lhs.x * rhs, lhs.y * rhs)
    }

    static func / (lhs: Vector2, rhs: Vector2) -> Vector2 {
        return Vector2(lhs.x / rhs.x, lhs.y / rhs.y)
    }

    static func / (lhs: Vector2, rhs: Scalar) -> Vector2 {
        return Vector2(lhs.x / rhs, lhs.y / rhs)
    }

    static func ~= (lhs: Vector2, rhs: Vector2) -> Bool {
        return lhs.x ~= rhs.x && lhs.y ~= rhs.y
    }
}
