//
//  URLBuilderTests.swift
//  AppKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class URLBuilderTests: XCTestCase {
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
        guard let result = URLBuilder.buildAppStartUrl(with: "https://pace.com", decomposedParams: [.references], references: "f582e5b4-5424-453f-9d7d-8c106b8360d3") else { XCTFail(); return }
        XCTAssertEqual(result, "https://pace.com?r=f582e5b4-5424-453f-9d7d-8c106b8360d3")
    }

    func testBuildImageUrlAbsolutePath() {
        guard let result = URLBuilder.buildAppIconUrl(baseUrl: "https://pace.fuel.site", iconSrc: "https://cdn.pace.cloud/brands/mybrand/notification_logo.png")?.absoluteString else { XCTFail(); return }
        XCTAssertEqual(result, "https://cdn.pace.cloud/brands/mybrand/notification_logo.png")
    }

    func testBuildImageUrlRelativePath() {
        guard let result = URLBuilder.buildAppIconUrl(baseUrl: "https://pace.fuel.site", iconSrc: "notification_logo.png")?.absoluteString else { XCTFail(); return }
        XCTAssertEqual(result, "https://pace.fuel.site/notification_logo.png")
    }

    func testBuildImageUrlInvalidAbsoluteURL() {
        let result = URLBuilder.buildAppIconUrl(baseUrl: nil, iconSrc: "//brands/mybrand/notification_logo.png")?.absoluteString
        XCTAssertNil(result)
    }

    func testBuildImageUrlInvalidRelativeURL() {
        let result = URLBuilder.buildAppIconUrl(baseUrl: "base", iconSrc: nil)?.absoluteString
        XCTAssertNil(result)
    }
}
