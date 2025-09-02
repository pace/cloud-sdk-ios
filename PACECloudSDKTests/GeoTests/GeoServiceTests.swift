//
//  GeoServiceTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import XCTest
@testable import PACECloudSDK

class GeoServiceTests: XCTestCase {
    private let location: CLLocation = .init(latitude: 49.012591, longitude: 8.427429)
    private var geoAPIManager: GeoAPIManager!

    private var temporaryDatabaseURL: URL {
        let fileName = "tmp_geo_database"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        return fileURL
    }

    override func setUp() async throws {
        try await super.setUp()

        PACECloudSDK.shared.customURLProtocol = MockURLProtocol()
        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey",
                                              clientId: "unit-test-dummy",
                                              geoDatabaseMode: .disabled,
                                              environment: .development,
                                              isRedirectSchemeCheckEnabled: false,
                                              geoAppsScope: "pace-drive-ios-min"))

        geoAPIManager = await .init(databaseUrl: temporaryDatabaseURL, speedThreshold: Constants.Configuration.defaultSpeedThreshold, geoAppsScope: "pace-drive-ios-min")
    }

    override func tearDown() {
        super.tearDown()

        geoAPIManager = nil
        try? FileManager.default.removeItem(at: temporaryDatabaseURL)
        CommandLine.arguments.removeAll()
    }

    func testLocationBasedStations() async {
        let result = await geoAPIManager.locationBasedCofuStations(for: location)

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            XCTAssertEqual(stations.count, 2)
        }
    }

    func testEmptyLocationBasedStations() async {
        addCommandLineArguments([.emptyGeoResponse])

        let result = await geoAPIManager.locationBasedCofuStations(for: location)

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            XCTAssertEqual(stations.count, 0)
        }
    }

    func testLocationBasedStationsError() async {
        addCommandLineArguments([.geoRequestError])

        let result = await geoAPIManager.locationBasedCofuStations(for: location)

        switch result {
        case .failure:
            break

        case .success:
            XCTFail()
        }
    }

    func testCofuStationsArea() async {
        let result = await geoAPIManager.cofuGasStations(option: .boundingCircle(center: location, radius: 10_000))

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            XCTAssertEqual(stations.count, 2)
        }

    }

    func testEmptyCofuStationsArea() async {
        addCommandLineArguments([.emptyGeoResponse])

        let result = await geoAPIManager.cofuGasStations(option: .boundingCircle(center: location, radius: 10_000))

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            XCTAssertEqual(stations.count, 0)
        }
    }

    func testCofuStationsAll() async {
        let result = await geoAPIManager.cofuGasStations(option: .all)

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            XCTAssertEqual(stations.count, 2)
        }
    }

    func testEmptyCofuStationsAll() async {
        addCommandLineArguments([.emptyGeoResponse])

        let result = await geoAPIManager.cofuGasStations(option: .all)

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            XCTAssertEqual(stations.count, 0)
        }
    }

    func testCofuStationsError() async {
        addCommandLineArguments([.geoRequestError])

        let result = await geoAPIManager.cofuGasStations(option: .all)

        switch result {
        case .failure:
            break

        case .success:
            XCTFail()
        }
    }

    func testAppsProperty() async {
        let result = await geoAPIManager.locationBasedCofuStations(for: location)

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            let appDatas: [AppKit.AppData] = (stations.first?.properties["apps"] as? [[String: Any]] ?? []).map {
                AppKit.AppData(appID: nil, appUrl: $0["url"] as? String ?? "", metadata: [:])
            }

            XCTAssertTrue(!appDatas.isEmpty)
        }
    }

    func testCofuStatusProperty() async {
        let result = await geoAPIManager.locationBasedCofuStations(for: location)

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            XCTAssertTrue(stations[0].cofuStatus == .online && stations[1].cofuStatus == .offline)
        }
    }

    func testFuelingURLsProperty() async {
        let result = await geoAPIManager.locationBasedCofuStations(for: location)

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            stations.forEach {
                XCTAssertEqual("https://dev.fuel.site", $0.fuelingURLs.first!)
            }
        }
    }

    func testPacePayProperty() async {
        let result = await geoAPIManager.locationBasedCofuStations(for: location)

        switch result {
        case .failure:
            XCTFail()

        case .success(let stations):
            guard let station1PacePay = stations[0].properties["pacePay"] as? Bool,
                  let station2PacePay = stations[1].properties["pacePay"] as? Bool else {
                XCTFail()
                return
            }

            XCTAssertTrue(station1PacePay)
            XCTAssertFalse(station2PacePay)
        }
    }

    func testIsPoiInRange() async {
        let isInRange = await geoAPIManager.isPoiInRange(with: "e3211b77-03f0-4d49-83aa-4adaa46d95ae", near: location)
        XCTAssertTrue(isInRange)
    }

    func testIsPoiNotInRange() async {
        let isInRange = await geoAPIManager.isPoiInRange(with: "e3211b77-03f0-4d49-83aa-4adaa46d95ae", near: CLLocation())
        XCTAssertFalse(isInRange)
    }

    func testIsPoiInRangeWrongUUID() async {
        let isInRange = await geoAPIManager.isPoiInRange(with: "7777777-777-7777-7777-777777777777", near: location)
        XCTAssertFalse(isInRange)
    }
}
