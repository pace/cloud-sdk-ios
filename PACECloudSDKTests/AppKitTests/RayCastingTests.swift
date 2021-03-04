//
//  RayCastingTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class RayCastingTests: XCTestCase {
    private let polygon: [[Double]] = [
        [8.427429, 49.01304015764206],
        [8.427166935031618, 49.013005967255644],
        [8.426944768026093, 49.012908601401435],
        [8.426796322288334, 49.01276288345869],
        [8.426744196943954, 49.01259099797384],
        [8.426796326657078, 49.01241911308242],
        [8.42694477420443, 49.0122733965724],
        [8.427166939400362, 49.0121760321509],
        [8.427429, 49.012141842357934],
        [8.427691060599638, 49.0121760321509],
        [8.42791322579557, 49.0122733965724],
        [8.42806167334292, 49.01241911308242],
        [8.428113803056045, 49.01259099797384],
        [8.428061677711664, 49.01276288345869],
        [8.427913231973907, 49.012908601401435],
        [8.427691064968382, 49.013005967255644],
        [8.427429, 49.01304015764206]
    ]

    func testLocationInside() {
        let isInside = RayCasting.contains(shape: polygon, point: [8.427777, 49.012713])
        XCTAssertTrue(isInside)
    }

    func testLocationInsideOnTheEdge() {
        let isInside = RayCasting.contains(shape: polygon, point: [8.426794, 49.012679])
        XCTAssertTrue(isInside)
    }

    func testLocationOutside() {
        let isInside = RayCasting.contains(shape: polygon, point: [8.426067, 49.011819])
        XCTAssertFalse(isInside)
    }

    func testLocationOutsideOnTheEdge() {
        let isInside = RayCasting.contains(shape: polygon, point: [8.426764, 49.012716])
        XCTAssertFalse(isInside)
    }

    func test2000Polygons() {
        let reversedPolygon = polygon.reversed() as [[Double]]
        let polygons = Array(repeating: polygon, count: 1000)
        let reversedPolygons = Array(repeating: reversedPolygon, count: 1000)

        let shapes = (polygons + reversedPolygons).shuffled()

        measure {
            shapes.forEach {
                let _ = RayCasting.contains(shape: $0, point: [8.426764, 49.012716])
            }
        }
    }
}
