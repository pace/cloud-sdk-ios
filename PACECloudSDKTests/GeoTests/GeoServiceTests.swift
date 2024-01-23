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

    override func setUp() {
        PACECloudSDK.shared.customURLProtocol = MockURLProtocol()
        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey",
                                              clientId: "unit-test-dummy",
                                              environment: .development,
                                              isRedirectSchemeCheckEnabled: false,
                                              geoAppsScope: "pace-drive-ios-min"))

        geoAPIManager = .init()
        geoAPIManager.geoAppsScope = "pace-drive-ios-min"
    }

    override func tearDownWithError() throws {
        CommandLine.arguments.removeAll()
    }

    func testLocationBasedStations() {
        let expectation = expectation(description: "LocationBasedStations")

        geoAPIManager.locationBasedCofuStations(for: location) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                if stations.count == 2 {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testEmptyLocationBasedStations() {
        addCommandLineArguments([.emptyGeoResponse])
        let expectation = expectation(description: "EmptyLocationBasedStations")

        geoAPIManager.locationBasedCofuStations(for: location) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                if stations.count == 0 {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testLocationBasedStationsError() {
        addCommandLineArguments([.geoRequestError])
        let expectation = expectation(description: "LocationBasedStationsError")

        geoAPIManager.locationBasedCofuStations(for: location) { result in
            switch result {
            case .failure:
                expectation.fulfill()

            case .success:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCofuStationsArea() {
        let expectation = expectation(description: "CofuStationsArea")

        geoAPIManager.cofuGasStations(option: .boundingCircle(center: location, radius: 10_000)) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                if stations.count == 2 {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testEmptyCofuStationsArea() {
        addCommandLineArguments([.emptyGeoResponse])
        let expectation = expectation(description: "EmptyCofuStationsArea")

        geoAPIManager.cofuGasStations(option: .boundingCircle(center: location, radius: 10_000)) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                if stations.count == 0 {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCofuStationsAll() {
        let expectation = expectation(description: "EmptyCofuStationsAll")

        geoAPIManager.cofuGasStations(option: .all) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                if stations.count == 2 {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testEmptyCofuStationsAll() {
        addCommandLineArguments([.emptyGeoResponse])
        let expectation = expectation(description: "EmptyCofuStationsAll")

        geoAPIManager.cofuGasStations(option: .all) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                if stations.count == 0 {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCofuStationsError() {
        addCommandLineArguments([.geoRequestError])
        let expectation = expectation(description: "CofuStationsError")

        geoAPIManager.cofuGasStations(option: .all) { result in
            switch result {
            case .failure:
                expectation.fulfill()

            case .success:
                XCTFail()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testAppsProperty() {
        let expectation = expectation(description: "AppsProperty")

        geoAPIManager.locationBasedCofuStations(for: location) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                let appDatas: [AppKit.AppData] = (stations.first?.properties["apps"] as? [[String: Any]] ?? []).map {
                    AppKit.AppData(appID: nil, appUrl: $0["url"] as? String ?? "", metadata: [:])
                }

                if !appDatas.isEmpty {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testCofuStatusProperty() {
        let expectation = expectation(description: "CofuStatusProperty")

        geoAPIManager.locationBasedCofuStations(for: location) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                if stations[0].cofuStatus == .online && stations[1].cofuStatus == .offline {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testFuelingURLsProperty() {
        let expectation = expectation(description: "FuelingURLsProperty")

        geoAPIManager.locationBasedCofuStations(for: location) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                stations.forEach {
                    XCTAssertEqual("https://dev.fuel.site", $0.fuelingURLs.first!)
                }
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testPacePayProperty() {
        let expectation = expectation(description: "PacePayProperty")

        geoAPIManager.locationBasedCofuStations(for: location) { result in
            switch result {
            case .failure:
                XCTFail()

            case .success(let stations):
                if let station1PacePay = stations[0].properties["pacePay"] as? Bool,
                   let station2PacePay = stations[1].properties["pacePay"] as? Bool,
                   station1PacePay,
                   !station2PacePay {
                    expectation.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testIsPoiInRange() {
        let expectation = expectation(description: "IsPoiInRange")

        geoAPIManager.isPoiInRange(with: "e3211b77-03f0-4d49-83aa-4adaa46d95ae", near: location) { isInRange in
            if isInRange {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testIsPoiNotInRange() {
        let expectation = expectation(description: "IsPoiNotInRange")

        geoAPIManager.isPoiInRange(with: "e3211b77-03f0-4d49-83aa-4adaa46d95ae", near: CLLocation()) { isInRange in
            if !isInRange {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }

    func testIsPoiInRangeWrongUUID() {
        let expectation = expectation(description: "IsPoiInRangeWrongUUID")

        geoAPIManager.isPoiInRange(with: "7777777-777-7777-7777-777777777777", near: location) { isInRange in
            if !isInRange {
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
