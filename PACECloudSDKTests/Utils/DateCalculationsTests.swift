//
//  DateCalculationsTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class DateCalculationsTests: XCTestCase {
    func testDateComponentsFromMinutesInit() {
        XCTAssertTrue(DateComponents(fromMinutes: 3) == DateComponents(day: 0, hour: 0, minute: 3))
        XCTAssertTrue(DateComponents(fromMinutes: 199) == DateComponents(day: 0, hour: 3, minute: 19))
        XCTAssertTrue(DateComponents(fromMinutes: 1920) == DateComponents(day: 1, hour: 8, minute: 0))
    }

    func testTimeIntervalSince1970AtMinutes() {
        let formatter = ISO8601DateFormatter()
        let testDate = formatter.date(from: "2022-03-26T12:00:00Z")!

        let controlDate1 = formatter.date(from: "2022-03-26T09:30:00Z")! // local date: 2022-03-26 10:30:00
        let controlDate2 = formatter.date(from: "2022-03-27T03:00:00Z")! // local date: 2022-03-27 05:00:00

        XCTAssertTrue(testDate.timeIntervalSince1970(atMinutes: 630)! == controlDate1.timeIntervalSince1970)
        XCTAssertTrue(testDate.timeIntervalSince1970(atMinutes: 1740)! == controlDate2.timeIntervalSince1970)
    }

    func testDaysAgo() {
        let formatter = ISO8601DateFormatter()

        // DST save test
        let testDate1 = formatter.date(from: "2022-03-27T10:00:00Z")! // local date: 2022-03-27 12:00:00
        let controlDate1 = formatter.date(from: "2022-03-26T11:00:00Z")! // local date: 2022-03-26 12:00:00

        XCTAssertTrue(testDate1.daysAgo(1) == controlDate1)

        let testDate2 = formatter.date(from: "2022-03-26T10:00:00Z")!
        let controlDate2 = formatter.date(from: "2022-03-25T10:00:00Z")!

        XCTAssertTrue(testDate2.daysAgo(1) == controlDate2)

        let testDate3 = formatter.date(from: "2022-03-26T10:00:00Z")!
        let controlDate3 = formatter.date(from: "2022-02-28T10:00:00Z")!

        XCTAssertTrue(testDate3.daysAgo(26) == controlDate3)

        let testDate4 = formatter.date(from: "2022-03-26T10:00:00Z")!
        let controlDate4 = formatter.date(from: "2021-03-26T10:00:00Z")!

        XCTAssertTrue(testDate4.daysAgo(365) == controlDate4)

        let testDate5 = formatter.date(from: "2020-03-26T10:00:00Z")!
        let controlDate5 = formatter.date(from: "2019-03-27T10:00:00Z")!

        XCTAssertTrue(testDate5.daysAgo(365) == controlDate5)
    }

    func testDaysLater() {
        let formatter = ISO8601DateFormatter()

        // DST save test
        let testDate1 = formatter.date(from: "2022-03-26T11:00:00Z")! // local date: 2022-03-26 12:00:00
        let controlDate1 = formatter.date(from: "2022-03-27T10:00:00Z")! // local date: 2022-03-27 12:00:00

        XCTAssertTrue(testDate1.daysLater(1) == controlDate1)

        let testDate2 = formatter.date(from: "2022-03-25T10:33:12Z")!
        let controlDate2 = formatter.date(from: "2022-03-26T10:33:12Z")!

        XCTAssertTrue(testDate2.daysLater(1) == controlDate2)

        let testDate3 = formatter.date(from: "2022-02-26T10:00:00Z")!
        let controlDate3 = formatter.date(from: "2022-03-24T10:00:00Z")!

        XCTAssertTrue(testDate3.daysLater(26) == controlDate3)

        let testDate4 = formatter.date(from: "2021-03-26T10:00:00Z")!
        let controlDate4 = formatter.date(from: "2022-03-26T10:00:00Z")!

        XCTAssertTrue(testDate4.daysLater(365) == controlDate4)

        let testDate5 = formatter.date(from: "2019-03-27T10:00:00Z")!
        let controlDate5 = formatter.date(from: "2020-03-26T10:00:00Z")!

        XCTAssertTrue(testDate5.daysLater(365) == controlDate5)
    }
}
