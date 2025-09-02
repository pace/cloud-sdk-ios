//
//  GeoDatabaseTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import XCTest
@testable import PACECloudSDK

class GeoDatabaseTests: XCTestCase {
    private let location: CLLocation = .init(latitude: 49.012591, longitude: 8.427429)
    private var database: GeoAPIManager.GeoDatabase!

    private var temporaryDatabaseURL: URL {
        let fileName = "tmp_geo_database"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        return fileURL
    }

    private var geoFeatures: [GeoAPIFeature]? {
        switch MockData.GeoServiceMockObject().mockData {
        case .success(let data):
            do {
                let response = try JSONDecoder().decode(GeoAPIResponse.self, from: data)
                return response.features
            } catch {
                XCTFail("Failed decoding with error \(error)")
            }

        default:
            XCTFail("No geo mock data")
        }

        return nil
    }

    override func setUp() async throws {
        try await super.setUp()
        database = try await .init(url: temporaryDatabaseURL)
    }

    override func tearDown() {
        super.tearDown()
        try? FileManager.default.removeItem(at: temporaryDatabaseURL)
    }

    private func writeToDatabase() async {
        do {
            guard let features = geoFeatures else {
                XCTFail("Failed getting geofeatures")
                return
            }

            try await database.write(features)
        } catch {
            XCTFail("Failed writing to database with error \(error)")
        }
    }

    func testWriteRead() async {
        guard let features = geoFeatures else {
            XCTFail("Failed getting geofeatures")
            return
        }

        await writeToDatabase()

        do {
            let stations = try await database.readAll()
            XCTAssertTrue(!stations.isEmpty)
            XCTAssertEqual(stations.count, features.count)
        } catch {
            XCTFail("Failed reading from database with error \(error)")
        }
    }

    func testReadId() async {
        await writeToDatabase()

        do {
            let station = try await database.read(poiId: "e3211b77-03f0-4d49-83aa-4adaa46d95ae")
            XCTAssertNotNil(station)
        } catch {
            XCTFail("Failed reading from database with error \(error)")
        }
    }

    func testReadBoundingBox() async {
        guard let features = geoFeatures else {
            XCTFail("Failed getting geofeatures")
            return
        }

        let boundingBox: POIKit.BoundingBox = .init(center: location.coordinate, radius: 10_000)

        for feature in features {
            guard let geometry = feature.geometry,
                  case .point(let point) = geometry else {
                XCTFail()
                return
            }

            let coordinates = CLLocationCoordinate2D(latitude: point.coordinates[1], longitude: point.coordinates[0])
            XCTAssertTrue(boundingBox.contains(coord: coordinates))
        }

        await writeToDatabase()

        do {
            let stations = try await database.read(boundingBox: boundingBox)
            XCTAssertTrue(!stations.isEmpty)

            for station in stations {
                guard let coordinates = station.location?.coordinate else {
                    XCTFail()
                    return
                }

                XCTAssertTrue(boundingBox.contains(coord: coordinates))
            }
        } catch {
            XCTFail("Failed reading from database with error \(error)")
        }
    }
}
