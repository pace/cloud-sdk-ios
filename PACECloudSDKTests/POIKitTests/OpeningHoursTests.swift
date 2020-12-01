//
//  OpeningHoursTests.swift
//  POIKitTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

class OpeningHoursTests: XCTestCase {
    let allWeek: [PCCommonOpeningHours.Rules.PCDays] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]

    func testNoOpeningHour() {
        let oh: [PCCommonOpeningHours.Rules] = []

        XCTAssertEqual(oh.description, "[]")
        XCTAssertTrue(oh.getClosedAreas(around: Date()).isEmpty)
    }

    func testOpen247() {
        let oh: [PCCommonOpeningHours.Rules] = [PCCommonOpeningHours.Rules(action: .open, days: allWeek, timespans: [PCCommonOpeningHours.Rules.Timespans(from: "0", to: "0")])]

        XCTAssertEqual(oh.description, #"[["mo", "tu", "we", "th", "fr", "sa", "su"]: [From 0 to 0]: open]"#)
        XCTAssertTrue(oh.getClosedAreas(around: Date()).isEmpty)
    }

    func testOpenAllWeekWithClosed() {

        let oh: [PCCommonOpeningHours.Rules] = [PCCommonOpeningHours.Rules(action: .open, days: allWeek, timespans: [PCCommonOpeningHours.Rules.Timespans(from: "5", to: "23:45")])]

        XCTAssertEqual(oh.description, #"[["mo", "tu", "we", "th", "fr", "sa", "su"]: [From 5 to 23:45]: open]"#)

        let controlData = [
            (-93600.0, -75600.0),
            (-8160.0, 10800.0),
            (78240.0, 97200.0),
            (164640.0, 183600.0),
            (251040.0, 270000.0),
            (337440.0, 338400.0)
        ]

        XCTAssert(oh.getClosedAreas(around: Date(timeIntervalSince1970: 24 * 60 * 60)) == controlData)
    }

    func testOnlyOpenMonday() {
        let oh: [PCCommonOpeningHours.Rules] = [
            PCCommonOpeningHours.Rules(action: .close, days: Array(allWeek[1...]), timespans: [PCCommonOpeningHours.Rules.Timespans(from: "0", to: "0")]),
            PCCommonOpeningHours.Rules(action: .open, days: [.monday], timespans: [PCCommonOpeningHours.Rules.Timespans(from: "0", to: "0")])
        ]

        XCTAssertEqual(oh.description, #"[["tu", "we", "th", "fr", "sa", "su"]: [From 0 to 0]: close, ["mo"]: [From 0 to 0]: open]"#)

        let controlData = [
            (165600.0, 338400.0),
            (424740.0, 597600.0)
        ]

        XCTAssertTrue(oh.getClosedAreas(around: Date(timeIntervalSince1970: 4 * 24 * 60 * 60)) == controlData)
    }

    func testSundayClosed() {
        let oh: [PCCommonOpeningHours.Rules] = [
            PCCommonOpeningHours.Rules(action: .close, days: [.sunday], timespans: [PCCommonOpeningHours.Rules.Timespans(from: "0", to: "0")]),
            PCCommonOpeningHours.Rules(action: .open, days: Array(allWeek.dropLast()), timespans: [PCCommonOpeningHours.Rules.Timespans(from: "7", to: "20")])
        ]

        XCTAssertEqual(oh.description, #"[["su"]: [From 0 to 0]: close, ["mo", "tu", "we", "th", "fr", "sa"]: [From 7 to 20]: open]"#)

        let controlData = [
            (79200.0, 104400.0),
            (151140.0, 190800.0),
            (237540.0, 363600.0),
            (410340.0, 450000.0),
            (496740.0, 511200.0)
        ]

        XCTAssertTrue(oh.getClosedAreas(around: Date(timeIntervalSince1970: 3 * 24 * 60 * 60)) == controlData)
    }

    func testMultipleClosedSections() {
        let oh: [PCCommonOpeningHours.Rules] = [
            PCCommonOpeningHours.Rules(action: .close, days: allWeek, timespans: [PCCommonOpeningHours.Rules.Timespans(from: "21", to: "5"), PCCommonOpeningHours.Rules.Timespans(from: "11", to: "14")])
        ]

        let controlData = [
            (-54000.0, -43260.0),
            (-18000.0, 10740.0),
            (32400.0, 43140.0),
            (68400.0, 97140.0),
            (118800.0, 129540.0),
            (154800.0, 183540.0),
            (205200.0, 215940.0),
            (241200.0, 269940.0),
            (291600.0, 302340.0),
            (327600.0, 356340.0)
        ]

        XCTAssertEqual(oh.description, #"[["mo", "tu", "we", "th", "fr", "sa", "su"]: [From 21 to 5, From 11 to 14]: close]"#)

        XCTAssertTrue(oh.getClosedAreas(around: Date(timeIntervalSince1970: 24 * 60 * 60)) == controlData)
    }

    func testOpenOvernight() {
        let oh: [PCCommonOpeningHours.Rules] = [
            PCCommonOpeningHours.Rules(action: .open, days: allWeek, timespans: [PCCommonOpeningHours.Rules.Timespans(from: "20", to: "8")])
        ]

        let controlData = [
            (-93600.0, -21600.0),
            (21540.0, 64800.0),
            (107940.0, 151200.0),
            (194340.0, 237600.0),
            (280740.0, 324000.0)
        ]

        XCTAssertEqual(oh.description, #"[["mo", "tu", "we", "th", "fr", "sa", "su"]: [From 20 to 8]: open]"#)

        XCTAssertTrue(oh.getClosedAreas(around: Date(timeIntervalSince1970: 24 * 60 * 60)) == controlData)
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
