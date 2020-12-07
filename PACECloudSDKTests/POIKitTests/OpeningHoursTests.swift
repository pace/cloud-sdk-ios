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
            (-93600.0, -72000.0),
            (-4560.0, 14400.0),
            (81840.0, 100800.0),
            (168240.0, 187200.0),
            (254640.0, 273600.0)
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
            (165600.0, 342000.0),
            (428340.0, 601140.0)
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
            (79200.0, 108000.0),
            (154740.0, 194400.0),
            (241140.0, 367200.0),
            (413940.0, 453600.0),
            (500340.0, 511200.0)
        ]

        XCTAssertTrue(oh.getClosedAreas(around: Date(timeIntervalSince1970: 3 * 24 * 60 * 60)) == controlData)
    }

    func testMultipleClosedSections() {
        let oh: [PCCommonOpeningHours.Rules] = [
            PCCommonOpeningHours.Rules(action: .close, days: allWeek, timespans: [PCCommonOpeningHours.Rules.Timespans(from: "21", to: "5"), PCCommonOpeningHours.Rules.Timespans(from: "11", to: "14")])
        ]

        let controlData = [
            (-50400.0, -39660.0),
            (-14400.0, 14340.0),
            (36000.0, 46740.0),
            (72000.0, 100740.0),
            (122400.0, 133140.0),
            (158400.0, 187140.0),
            (208800.0, 219540.0),
            (244800.0, 273540.0),
            (295200.0, 305940.0),
            (331200.0, 359940.0)
        ]

        XCTAssertEqual(oh.description, #"[["mo", "tu", "we", "th", "fr", "sa", "su"]: [From 21 to 5, From 11 to 14]: close]"#)

        XCTAssertTrue(oh.getClosedAreas(around: Date(timeIntervalSince1970: 24 * 60 * 60)) == controlData)
    }

    func testOpenOvernight() {
        let oh: [PCCommonOpeningHours.Rules] = [
            PCCommonOpeningHours.Rules(action: .open, days: allWeek, timespans: [PCCommonOpeningHours.Rules.Timespans(from: "20", to: "8")])
        ]

        let controlData = [
            (-93600.0, -18000.0),
            (25140.0, 68400.0),
            (111540.0, 154800.0),
            (197940.0, 241200.0),
            (284340.0, 327600.0)
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
