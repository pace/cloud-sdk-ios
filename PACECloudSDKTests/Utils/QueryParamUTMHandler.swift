//
//  QueryParamHandlerTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class QueryParamUTMHandlerTests: XCTestCase {
    override class func setUp() {
        PACECloudSDK.shared.setup(with: .init(apiKey: "apiKey",
                                              clientId: "unit-test-dummy",
                                              environment: .development,
                                              isRedirectSchemeCheckEnabled: false))
    }

    func testWithoutAdditionalQueryParams() {
        let url = URL(string: "https://pace.cloud?id=1337&foo=bar&utm_source=UnitTestDummy")
        PACECloudSDK.shared.additionalQueryParams = nil

        let modifiedUrl = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: url!)

        XCTAssertEqual(url!.absoluteString, modifiedUrl!.absoluteString)
    }

    func testWithAdditionalQueryParams() {
        let url = URL(string: "https://pace.cloud?id=1337&foo=bar")
        let queryItems = ["bar": "foo", "foobar": "barfoo"].map { URLQueryItem(name: $0.key, value: $0.value) }

        PACECloudSDK.shared.additionalQueryParams = Set(queryItems)

        let modifiedUrl = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: url!)
        let components = URLComponents(string: modifiedUrl!.absoluteString)

        XCTAssertNotEqual(url!.absoluteString, modifiedUrl!.absoluteString)
        XCTAssertTrue(queryItems.allSatisfy(components!.queryItems!.contains))
    }

    func testWithCustomUTMSource() {
        let url = URL(string: "https://pace.cloud?id=1337&foo=bar")
        let utmURL = URL(string: "https://pace.cloud?id=1337&foo=bar&utm_source=foo")
        let queryItems = ["utm_source": "foo"].map { URLQueryItem(name: $0.key, value: $0.value) }

        PACECloudSDK.shared.additionalQueryParams = Set(queryItems)

        let modifiedUrl = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: url!)
        let components = URLComponents(string: modifiedUrl!.absoluteString)

        XCTAssertEqual(utmURL!.absoluteString, modifiedUrl!.absoluteString)
        XCTAssertTrue(queryItems.allSatisfy(components!.queryItems!.contains))
    }

    func testWithPreSetCustomUTMSource() {
        let url = URL(string: "https://pace.cloud?id=1337&foo=bar&utm_source=foobar")
        let queryItems = ["utm_source": "foo"].map { URLQueryItem(name: $0.key, value: $0.value) }

        PACECloudSDK.shared.additionalQueryParams = Set(queryItems)

        let modifiedUrl = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: url!)
        let components = URLComponents(string: modifiedUrl!.absoluteString)

        XCTAssertEqual(url!.absoluteString, modifiedUrl!.absoluteString)
        XCTAssertFalse(queryItems.allSatisfy(components!.queryItems!.contains))
    }

    func testWithIgnoredUrl() {
        let url = URL(string: "https://api.pace.cloud/photon/api?id=1337&foo=bar")
        let queryItems = ["bar": "foo", "foobar": "barfoo"].map { URLQueryItem(name: $0.key, value: $0.value) }

        PACECloudSDK.shared.additionalQueryParams = Set(queryItems)

        let modifiedUrl = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: url!)

        XCTAssertEqual(url!.absoluteString, modifiedUrl!.absoluteString)
    }
}
