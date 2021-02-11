//
//  URLBuilderTests.swift
//  AppKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class URLBuilderTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey",
                                              authenticationMode: .web,
                                              environment: .development))
    }

    func testBuildManifestUrl() {
        let rootUrl = URLBuilder.buildAppManifestUrl(with: "https://pace.com")!
        XCTAssertEqual(rootUrl, "https://pace.com/manifest.json")

        let urlWithPath = URLBuilder.buildAppManifestUrl(with: "https://pace.com/path/foo/bar")!
        XCTAssertEqual(urlWithPath, "https://pace.com/manifest.json")

        let urlWithParams = URLBuilder.buildAppManifestUrl(with: "https://pace.com?foo=bar&bar=foo")!
        XCTAssertEqual(urlWithParams, "https://pace.com/manifest.json")

        let urlWithPort = URLBuilder.buildAppManifestUrl(with: "https://pace.com:8888")!
        XCTAssertEqual(urlWithPort, "https://pace.com:8888/manifest.json")

        let urlWithPortAndPath = URLBuilder.buildAppManifestUrl(with: "https://pace.com:8888/path/foo/bar")!
        XCTAssertEqual(urlWithPortAndPath, "https://pace.com:8888/manifest.json")

        let urlWithPortAndPathAndParams = URLBuilder.buildAppManifestUrl(with: "https://pace.com:8888/path/foo/bar?foo=bar&bar=foo")!
        XCTAssertEqual(urlWithPortAndPathAndParams, "https://pace.com:8888/manifest.json")
    }

    func testBuildAppStartUrl() {
        guard let result = URLBuilder.buildAppStartUrl(with: "https://pace.com", decomposedParams: [.references], references: "prn:poi:gas-stations:f582e5b4-5424-453f-9d7d-8c106b8360d3") else { XCTFail(); return }
        XCTAssertEqual(result, "https://pace.com?r=prn:poi:gas-stations:f582e5b4-5424-453f-9d7d-8c106b8360d3")
    }

    func testBuildImageUrl() {
        guard let result = URLBuilder.buildAppIconUrl(baseUrl: "base", iconSrc: "image") else { XCTFail(); return }
        XCTAssertEqual(result, "base/image")
    }

    // - MARK: 2FA
    func testTOTPSecretData() {
        let message: [String: AnyHashable]  = ["secret": "10101",
                                               "period": 30,
                                               "digits": 6,
                                               "algorithm": "sha1",
                                               "key": "foobar"]
        guard let data = TOTPSecretData(from: message) else { XCTFail(); return }

        XCTAssertEqual(data.secret, "10101")
        XCTAssertEqual(data.period, 30)
        XCTAssertEqual(data.digits, 6)
        XCTAssertEqual(data.algorithm, "sha1")
        XCTAssertEqual(data.key, "foobar")
    }

    func testGetTOTP() {
        let message: [String: AnyHashable] = ["key": "foobar", "serverTime": 1591780142]

        guard let data = GetTOTPData(from: message, host: "") else { XCTFail(); return }

        XCTAssertEqual(data.serverTime, 1591780142)
        XCTAssertEqual(data.key, "foobar")
    }

    func testSetSecureData() {
        let message = ["key": "foo", "value": "bar"]
        guard let data = SetSecureData(from: message) else { XCTFail(); return }

        XCTAssertEqual(data.key, "foo")
        XCTAssertEqual(data.value, "bar")
    }
}
