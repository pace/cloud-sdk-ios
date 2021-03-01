//
//  QueryParamHandlerTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class QueryParamHandlerTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey", authenticationMode: .web, environment: .development))
    }

    func testWithoutAdditionalQueryParams() {
        let url = URL(string: "https://pace.cloud?id=1337&foo=bar")
        PACECloudSDK.shared.additionalQueryParams = nil

        let modifiedUrl = QueryParamHandler.buildUrl(for: url!)

        XCTAssertEqual(url!.absoluteString, modifiedUrl!.absoluteString)
    }

    func testWithAdditionalQueryParams() {
        let url = URL(string: "https://pace.cloud?id=1337&foo=bar")
        let queryItems = ["bar": "foo", "foobar": "barfoo"].map { URLQueryItem(name: $0.key, value: $0.value) }

        PACECloudSDK.shared.additionalQueryParams = Set(queryItems)

        let modifiedUrl = QueryParamHandler.buildUrl(for: url!)
        let components = URLComponents(string: modifiedUrl!.absoluteString)

        XCTAssertNotEqual(url!.absoluteString, modifiedUrl!.absoluteString)
        XCTAssertTrue(queryItems.allSatisfy(components!.queryItems!.contains))
    }

    func testWithIgnoredUrl() {
        let url = URL(string: "https://api.pace.cloud/photon/api?id=1337&foo=bar")
        let queryItems = ["bar": "foo", "foobar": "barfoo"].map { URLQueryItem(name: $0.key, value: $0.value) }

        PACECloudSDK.shared.additionalQueryParams = Set(queryItems)

        let modifiedUrl = QueryParamHandler.buildUrl(for: url!)

        XCTAssertEqual(url!.absoluteString, modifiedUrl!.absoluteString)
    }
}
