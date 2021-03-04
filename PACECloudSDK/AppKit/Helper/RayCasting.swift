//
//  RayCasting.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

// https://rosettacode.org/wiki/Ray-casting_algorithm
// If the starting point of the ray is right on an edge
// `contains` will return `false`
class RayCasting {
    static func contains(shape: [[Double]], point: [Double]) -> Bool {
        var isInside = false
        let shapeEdges = shape.count

        for i in 0..<shapeEdges {
            if intersects(a: shape[i], b: shape[(i + 1) % shapeEdges], p: point) {
                isInside.toggle()
            }
        }

        return isInside
    }

    private static func intersects(a: [Double], b: [Double], p: [Double]) -> Bool {
        var point = p
        if a[1] > b[1] {
            return intersects(a: b, b: a, p: point)
        }

        if point[1] == a[1] || point[1] == b[1] {
            point[1] += 0.00001 // Avoid ray on vertex problem
        }

        if point[1] > b[1] || point[1] < a[1] || point[0] >= max(a[0], b[0]) {
            return false
        }

        if point[0] < min(a[0], b[0]) {
            return true
        }

        let bax = (point[1] - a[1]) / (point[0] - a[0]) // angle between b <-> ax
        let pax = (b[1] - a[1]) / (b[0] - a[0]) // angle between p <-> ax

        return bax >= pax
    }
}
