//
//  URLDecomposerTests.swift
//  AppKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class URLDecomposerTests: XCTestCase {
    func testDecomposeManifestUrlWithParam() {
        guard let data = manifestMockWithParam.data(using: .utf8),
            let manifest = try? JSONDecoder().decode(AppManifest.self, from: data),
            let result = URLDecomposer.decomposeManifestUrl(with: manifest, appBaseUrl: "base") else { XCTFail(); return }

        XCTAssertEqual(result.url, "base")
        XCTAssertEqual(result.params.count, 1)
        XCTAssertEqual(result.params.first!.rawValue, "r")
    }

    func testDecomposeManifestUrlWithParams() {
        guard let data = manifestMockWithParams.data(using: .utf8),
            let manifest = try? JSONDecoder().decode(AppManifest.self, from: data),
            let result = URLDecomposer.decomposeManifestUrl(with: manifest, appBaseUrl: "base") else { XCTFail(); return }

        XCTAssertEqual(result.url, "base")
        XCTAssertEqual(result.params.count, 3)
        XCTAssertEqual(result.params[0].rawValue, "r")
        XCTAssertEqual(result.params[1].rawValue, "vin")
        XCTAssertEqual(result.params[2].rawValue, "fuel_type")
    }

    func testDecomposeManifestUrlRelative() {
        guard let data = manifestMockRelative.data(using: .utf8),
            let manifest = try? JSONDecoder().decode(AppManifest.self, from: data) else { XCTFail(); return }

        manifest.manifestUrl = "https://fueling-app-2.dev.k8s.pacelink.net/manifest.json"
        guard let result = URLDecomposer.decomposeManifestUrl(with: manifest, appBaseUrl: "base") else { XCTFail(); return }

        XCTAssertEqual(result.url, "https://fueling-app-2.dev.k8s.pacelink.net/")
        XCTAssertEqual(result.params.count, 0)
    }

    func testDecomposeManifestUrlAbsolute() {
        guard let data = manifestMockAbsolute.data(using: .utf8),
            let manifest = try? JSONDecoder().decode(AppManifest.self, from: data),
            let result = URLDecomposer.decomposeManifestUrl(with: manifest, appBaseUrl: "base") else { XCTFail(); return }

        XCTAssertEqual(result.url, "base")
        XCTAssertEqual(result.params.count, 0)
    }

    func testDecomposeManifestUrlWithUrl() {
        guard let data = manifestMockWithUrl.data(using: .utf8),
            let manifest = try? JSONDecoder().decode(AppManifest.self, from: data),
            let result = URLDecomposer.decomposeManifestUrl(with: manifest, appBaseUrl: "base") else { XCTFail(); return }

        XCTAssertEqual(result.url, "https://google.com")
        XCTAssertEqual(result.params.count, 0)
    }

    func testDecomposeQuery() {
        let queryString = "param1=value1&param2=value2&param3=value3"
        let queryItems = URLDecomposer.decomposeQuery(queryString)

        XCTAssertEqual(queryItems.count, 3)
        XCTAssertEqual(queryItems["param1"], "value1")
        XCTAssertEqual(queryItems["param2"], "value2")
        XCTAssertEqual(queryItems["param3"], "value3")
    }
}
