//
//  OpeningHoursTests.swift
//  POIKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class OpeningHoursTests: XCTestCase {
    let allWeek: [PCPOICommonOpeningHours.Rules.PCPOIDays] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    func testNoOpeningHour() {
        let oh: [PCPOICommonOpeningHours.Rules] = []

        XCTAssertEqual(oh.description, "[]")
        XCTAssertTrue(oh.getClosedAreas(around: Date()).isEmpty)
    }

    func testOpen247() {
        let oh: [PCPOICommonOpeningHours.Rules] = [PCPOICommonOpeningHours.Rules(action: .open, days: allWeek, timespans: [PCPOICommonOpeningHours.Rules.Timespans(from: "0", to: "0")])]

        XCTAssertEqual(oh.description, #"[["mo", "tu", "we", "th", "fr", "sa", "su"]: [From 0 to 0]: open]"#)
        XCTAssertTrue(oh.getClosedAreas(around: Date()).isEmpty)
    }

    func testOpenAllWeekWithClosed() {

        let oh: [PCPOICommonOpeningHours.Rules] = [PCPOICommonOpeningHours.Rules(action: .open, days: allWeek, timespans: [PCPOICommonOpeningHours.Rules.Timespans(from: "5", to: "23:45")])]

        XCTAssertEqual(oh.description, #"[["mo", "tu", "we", "th", "fr", "sa", "su"]: [From 5 to 23:45]: open]"#)

        let formatter = ISO8601DateFormatter()

        let controlData = [
            (formatter.timeIntervalSince1970(from: "1969-12-30T23:00:00Z")!, formatter.timeIntervalSince1970(from: "1969-12-31T04:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1969-12-31T22:44:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-01T04:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-01T22:44:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-02T04:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-02T22:44:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-03T04:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-03T22:44:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-04T04:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-04T22:44:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-04T23:00:00Z")!)
        ]

        XCTAssert(oh.getClosedAreas(around: formatter.date(from: "1970-01-02T00:00:00Z")!) == controlData)
    }

    func testOnlyOpenMonday() {
        let oh: [PCPOICommonOpeningHours.Rules] = [
            PCPOICommonOpeningHours.Rules(action: .close, days: Array(allWeek[1...]), timespans: [PCPOICommonOpeningHours.Rules.Timespans(from: "0", to: "0")]),
            PCPOICommonOpeningHours.Rules(action: .open, days: [.monday], timespans: [PCPOICommonOpeningHours.Rules.Timespans(from: "0", to: "0")])
        ]

        XCTAssertEqual(oh.description, #"[["tu", "we", "th", "fr", "sa", "su"]: [From 0 to 0]: close, ["mo"]: [From 0 to 0]: open]"#)

        let formatter = ISO8601DateFormatter()

        let controlData = [
            (formatter.timeIntervalSince1970(from: "1970-01-02T23:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-04T23:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-05T22:59:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-07T23:00:00Z")!)
        ]

        XCTAssertTrue(oh.getClosedAreas(around: formatter.date(from: "1970-01-05T00:00:00Z")!) == controlData)
    }

    func testSundayClosed() {
        let oh: [PCPOICommonOpeningHours.Rules] = [
            PCPOICommonOpeningHours.Rules(action: .close, days: [.sunday], timespans: [PCPOICommonOpeningHours.Rules.Timespans(from: "0", to: "0")]),
            PCPOICommonOpeningHours.Rules(action: .open, days: Array(allWeek.dropLast()), timespans: [PCPOICommonOpeningHours.Rules.Timespans(from: "7", to: "20")])
        ]

        XCTAssertEqual(oh.description, #"[["su"]: [From 0 to 0]: close, ["mo", "tu", "we", "th", "fr", "sa"]: [From 7 to 20]: open]"#)

        let formatter = ISO8601DateFormatter()

        let controlData = [
            (formatter.timeIntervalSince1970(from: "1970-01-01T23:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-02T06:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-02T18:59:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-03T06:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-03T18:59:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-05T06:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-05T18:59:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-06T06:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-06T18:59:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-06T23:00:00Z")!)
        ]

        XCTAssertTrue(oh.getClosedAreas(around: formatter.date(from: "1970-01-04T00:00:00Z")!) == controlData)
    }

    func testMultipleClosedSections() {
        let oh: [PCPOICommonOpeningHours.Rules] = [
            PCPOICommonOpeningHours.Rules(action: .close, days: allWeek, timespans: [PCPOICommonOpeningHours.Rules.Timespans(from: "21", to: "5"), PCPOICommonOpeningHours.Rules.Timespans(from: "11", to: "14")])
        ]

        let formatter = ISO8601DateFormatter()

        let controlData = [
            (formatter.timeIntervalSince1970(from: "1969-12-31T10:00:00Z")!, formatter.timeIntervalSince1970(from: "1969-12-31T12:59:00Z")!),
            (formatter.timeIntervalSince1970(from: "1969-12-31T20:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-01T03:59:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-01T10:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-01T12:59:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-01T20:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-02T03:59:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-02T10:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-02T12:59:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-02T20:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-03T03:59:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-03T10:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-03T12:59:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-03T20:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-04T03:59:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-04T10:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-04T12:59:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-04T20:00:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-05T03:59:00Z")!)
        ]

        XCTAssertEqual(oh.description, #"[["mo", "tu", "we", "th", "fr", "sa", "su"]: [From 21 to 5, From 11 to 14]: close]"#)

        XCTAssertTrue(oh.getClosedAreas(around: formatter.date(from: "1970-01-02T00:00:00Z")!) == controlData)
    }

    func testOpenOvernight() {
        let oh: [PCPOICommonOpeningHours.Rules] = [
            PCPOICommonOpeningHours.Rules(action: .open, days: allWeek, timespans: [PCPOICommonOpeningHours.Rules.Timespans(from: "20", to: "8")])
        ]

        let formatter = ISO8601DateFormatter()

        let controlData = [
            (formatter.timeIntervalSince1970(from: "1969-12-30T23:00:00Z")!, formatter.timeIntervalSince1970(from: "1969-12-31T19:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-01T06:59:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-01T19:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-02T06:59:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-02T19:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-03T06:59:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-03T19:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "1970-01-04T06:59:00Z")!, formatter.timeIntervalSince1970(from: "1970-01-04T19:00:00Z")!)
        ]

        XCTAssertEqual(oh.description, #"[["mo", "tu", "we", "th", "fr", "sa", "su"]: [From 20 to 8]: open]"#)

        XCTAssertTrue(oh.getClosedAreas(around: formatter.date(from: "1970-01-02T00:00:00Z")!) == controlData)
    }

    func testDSTSafeClosingTimes() {
        let oh: [PCPOICommonOpeningHours.Rules] = [
            PCPOICommonOpeningHours.Rules(action: .open, days: allWeek, timespans: [PCPOICommonOpeningHours.Rules.Timespans(from: "20", to: "8")])
        ]

        let formatter = ISO8601DateFormatter()
        let date1 = formatter.date(from: "2022-03-26T12:00:00Z")!
        let date2 = formatter.date(from: "2022-03-27T12:00:00Z")!

        let controlData1 = [
            (formatter.timeIntervalSince1970(from: "2022-03-23T23:00:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-24T19:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "2022-03-25T06:59:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-25T19:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "2022-03-26T06:59:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-26T19:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "2022-03-27T05:59:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-27T18:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "2022-03-28T05:59:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-28T18:00:00Z")!)
        ]

        let controlData2 = [
            (formatter.timeIntervalSince1970(from: "2022-03-24T23:00:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-25T19:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "2022-03-26T06:59:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-26T19:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "2022-03-27T05:59:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-27T18:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "2022-03-28T05:59:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-28T18:00:00Z")!),
            (formatter.timeIntervalSince1970(from: "2022-03-29T05:59:00Z")!, formatter.timeIntervalSince1970(from: "2022-03-29T18:00:00Z")!)
        ]

        XCTAssertTrue(oh.getClosedAreas(around: date1) == controlData1)
        XCTAssertTrue(oh.getClosedAreas(around: date2) == controlData2)
    }
}

extension Array where Element == (Double, Double) {
    static func ==(lhs: [(Double, Double)], rhs: [(Double, Double)]) -> Bool {
        guard lhs.count == rhs.count else { return false }

        for i in 0..<lhs.count {
            if lhs[i] != rhs[i] { return false }
        }

        return true
    }
}
