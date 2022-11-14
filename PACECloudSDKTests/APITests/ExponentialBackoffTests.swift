//
//  ExponentialBackoffTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

final class ExponentialBackoffTests: XCTestCase {
    private let validResponseSuccessful = HTTPURLResponse(url: .init(string: "pace.cloud")!,
                                                          statusCode: HttpStatusCode.ok.rawValue,
                                                          httpVersion: nil,
                                                          headerFields: nil)
    private let validResponseTimeout = HTTPURLResponse(url: .init(string: "pace.cloud")!,
                                                       statusCode: HttpStatusCode.requestTimeout.rawValue,
                                                       httpVersion: nil,
                                                       headerFields: nil)

    func testCanPerformExponentialBackoff() {
        let invalidResponse = API.shouldRetryRequest(currentRetryCount: 0, maxRetryCount: 5, response: nil)
        let timeout = API.shouldRetryRequest(currentRetryCount: 0, maxRetryCount: 5, response: validResponseTimeout)

        XCTAssertTrue(invalidResponse)
        XCTAssertTrue(timeout)
    }

    func testCanNotPerformExponentialBackoff() {
        let tooManyRetries = API.shouldRetryRequest(currentRetryCount: 6, maxRetryCount: 5, response: validResponseTimeout)
        let noTimeout = API.shouldRetryRequest(currentRetryCount: 0, maxRetryCount: 5, response: validResponseSuccessful)

        XCTAssertFalse(tooManyRetries)
        XCTAssertFalse(noTimeout)
    }

    func testNextExponentialBackoffRequestDelay() {
        let value1 = API.nextExponentialBackoffRequestDelay(currentRetryCount: 1)
        let value2 = API.nextExponentialBackoffRequestDelay(currentRetryCount: 3)
        let value3 = API.nextExponentialBackoffRequestDelay(currentRetryCount: 6)
        let value4 = API.nextExponentialBackoffRequestDelay(currentRetryCount: 7)
        let value5 = API.nextExponentialBackoffRequestDelay(currentRetryCount: 20)

        XCTAssertEqual(value1, 1)
        XCTAssertEqual(value2, 4)
        XCTAssertEqual(value3, 32)
        XCTAssertEqual(value4, 64)
        XCTAssertEqual(value5, 64)
    }
}
