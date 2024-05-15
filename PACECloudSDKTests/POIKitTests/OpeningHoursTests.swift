//
//  OpeningHoursTests.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import XCTest
@testable import PACECloudSDK

final class OpeningHoursTests: XCTestCase {
    private let allWeek = PCPOICommonOpeningHours.Rules.PCPOIDays.allCases
    private let weekday: [PCPOICommonOpeningHours.Rules.PCPOIDays] = [.monday, .tuesday, .wednesday, .thursday, .friday]
    private let weekend: [PCPOICommonOpeningHours.Rules.PCPOIDays] = [.saturday, .sunday]
    private let mondayToSaturday: [PCPOICommonOpeningHours.Rules.PCPOIDays] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    private let sunday: [PCPOICommonOpeningHours.Rules.PCPOIDays] = [.sunday]
    private let daily: POIKit.OpeningHoursValue = .daily
    private let open247: POIKit.OpeningHoursValue = .open247
    private let closed: POIKit.OpeningHoursValue = .closed
    private let open9to5: POIKit.OpeningHoursValue = .time(value: "09:00 – 17:00")
    private let open8to2315: POIKit.OpeningHoursValue = .time(value: "08:00 – 23:15")
    private let open7to230: POIKit.OpeningHoursValue = .time(value: "07:00 – 02:30")
    private let open8to230: POIKit.OpeningHoursValue = .time(value: "08:00 – 02:30")
    private let openWithBreak: POIKit.OpeningHoursValue = .time(value: "08:00 – 12:35\n14:00 – 23:00")

    func testOpen247() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: allWeek, timespans: [.init(from: "0", to: "0")])
        ]

        let appliedRules = openingHours.openingHours()

        XCTAssertEqual(appliedRules.count, 1)
        XCTAssertEqual(appliedRules.first?.0, daily)
        XCTAssertEqual(appliedRules.first?.1, open247)
    }

    func testOpenFrom8To23() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: allWeek, timespans: [.init(from: "8", to: "23:15")])
        ]

        let appliedRules = openingHours.openingHours()

        XCTAssertEqual(appliedRules.count, 1)
        XCTAssertEqual(appliedRules.first?.0, daily)
        XCTAssertEqual(appliedRules.first?.1, open8to2315)
    }

    func testOpenFrom7To230() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: allWeek, timespans: [.init(from: "7", to: "2:30")])
        ]

        let appliedRules = openingHours.openingHours()

        XCTAssertEqual(appliedRules.count, 1)
        XCTAssertEqual(appliedRules.first?.0, daily)
        XCTAssertEqual(appliedRules.first?.1, open7to230)
    }

    func testMultipleOpeningRules1() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: weekday, timespans: [.init(from: "8", to: "12:35")]),
            .init(action: .open, days: weekday, timespans: [.init(from: "14", to: "23")]),
            .init(action: .open, days: weekend, timespans: [.init(from: "8", to: "23:15")])
        ]

        let appliedRules = openingHours.openingHours()

        XCTAssertEqual(appliedRules.count, 2)
        XCTAssertEqual(appliedRules[0].0, .weekday(from: "monday", to: "friday"))
        XCTAssertEqual(appliedRules[0].1, openWithBreak)
        XCTAssertEqual(appliedRules[1].0, .weekday(from: "saturday", to: "sunday"))
        XCTAssertEqual(appliedRules[1].1, open8to2315)
    }

    func testMultipleOpeningRules2() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: weekday, timespans: [.init(from: "7", to: "2:30")]),
            .init(action: .open, days: weekend, timespans: [.init(from: "8", to: "2:30")])
        ]

        let appliedRules = openingHours.openingHours()

        XCTAssertEqual(appliedRules.count, 2)
        XCTAssertEqual(appliedRules[0].0, .weekday(from: "monday", to: "friday"))
        XCTAssertEqual(appliedRules[0].1, open7to230)
        XCTAssertEqual(appliedRules[1].0, .weekday(from: "saturday", to: "sunday"))
        XCTAssertEqual(appliedRules[1].1, open8to230)
    }

    func testMultipleOpeningRules3() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: mondayToSaturday, timespans: [.init(from: "9", to: "17")]),
            .init(action: .open, days: sunday, timespans: [.init(from: "8", to: "23:15")])
        ]

        let appliedRules = openingHours.openingHours()

        XCTAssertEqual(appliedRules.count, 2)
        XCTAssertEqual(appliedRules[0].0, .weekday(from: "monday", to: "saturday"))
        XCTAssertEqual(appliedRules[0].1, open9to5)
        XCTAssertEqual(appliedRules[1].0, .day(day: "sunday"))
        XCTAssertEqual(appliedRules[1].1, open8to2315)
    }

    func testMultipleOpeningRulesWithClosed1() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: weekday, timespans: [.init(from: "8", to: "12:35")]),
            .init(action: .open, days: weekday, timespans: [.init(from: "14", to: "23")]),
            .init(action: .close, days: [.tuesday], timespans: [.init(from: "0", to: "0")]),
            .init(action: .open, days: weekend, timespans: [.init(from: "8", to: "23:15")])
        ]

        let appliedRules = openingHours.openingHours()

        XCTAssertEqual(appliedRules.count, 4)
        XCTAssertEqual(appliedRules[0].0, .day(day: "monday"))
        XCTAssertEqual(appliedRules[0].1, openWithBreak)
        XCTAssertEqual(appliedRules[1].0, .day(day: "tuesday"))
        XCTAssertEqual(appliedRules[1].1, closed)
        XCTAssertEqual(appliedRules[2].0, .weekday(from: "wednesday", to: "friday"))
        XCTAssertEqual(appliedRules[2].1, openWithBreak)
        XCTAssertEqual(appliedRules[3].0, .weekday(from: "saturday", to: "sunday"))
    }

    func testMultipleOpeningRulesWithClosed2() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: [.monday, .tuesday, .wednesday], timespans: [.init(from: "8", to: "23")]),
            .init(action: .close, days: weekday, timespans: [.init(from: "12:35", to: "14")]),
            .init(action: .open, days: [.thursday], timespans: [.init(from: "8", to: "17")]),
            .init(action: .open, days: [.friday], timespans: [.init(from: "8", to: "20")]),
            .init(action: .open, days: weekend, timespans: [.init(from: "8", to: "23:15")])
        ]

        let appliedRules = openingHours.openingHours()

        XCTAssertEqual(appliedRules.count, 4)
        XCTAssertEqual(appliedRules[0].0, .weekday(from: "monday", to: "wednesday"))
        XCTAssertEqual(appliedRules[0].1, openWithBreak)
        XCTAssertEqual(appliedRules[1].0, .day(day: "thursday"))
        XCTAssertEqual(appliedRules[2].0, .day(day: "friday"))
        XCTAssertEqual(appliedRules[3].0, .weekday(from: "saturday", to: "sunday"))
        XCTAssertEqual(appliedRules[3].1, open8to2315)
    }

    func testMultipleOpeningRules() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: [.monday], timespans: [.init(from: "8", to: "20")]),
            .init(action: .open, days: [.tuesday], timespans: [.init(from: "9", to: "20")]),
            .init(action: .open, days: [.wednesday], timespans: [.init(from: "10", to: "20")]),
            .init(action: .open, days: [.thursday], timespans: [.init(from: "8", to: "21")]),
            .init(action: .open, days: [.friday], timespans: [.init(from: "8", to: "22")]),
            .init(action: .open, days: [.saturday], timespans: [.init(from: "7", to: "24")]),
            .init(action: .open, days: [.sunday], timespans: [.init(from: "7", to: "21")])
        ]

        let appliedRules = openingHours.openingHours()

        XCTAssertEqual(appliedRules.count, 7)
        XCTAssertEqual(appliedRules[0].0, .day(day: "monday"))
        XCTAssertEqual(appliedRules[0].1, .time(value: "08:00 – 20:00"))
        XCTAssertEqual(appliedRules[1].0, .day(day: "tuesday"))
        XCTAssertEqual(appliedRules[1].1, .time(value: "09:00 – 20:00"))
        XCTAssertEqual(appliedRules[2].0, .day(day: "wednesday"))
        XCTAssertEqual(appliedRules[2].1, .time(value: "10:00 – 20:00"))
        XCTAssertEqual(appliedRules[3].0, .day(day: "thursday"))
        XCTAssertEqual(appliedRules[3].1, .time(value: "08:00 – 21:00"))
        XCTAssertEqual(appliedRules[4].0, .day(day: "friday"))
        XCTAssertEqual(appliedRules[4].1, .time(value: "08:00 – 22:00"))
        XCTAssertEqual(appliedRules[5].0, .day(day: "saturday"))
        XCTAssertEqual(appliedRules[5].1, .time(value: "07:00 – 24:00"))
        XCTAssertEqual(appliedRules[6].0, .day(day: "sunday"))
        XCTAssertEqual(appliedRules[6].1, .time(value: "07:00 – 21:00"))
    }

    func testGetOpeningHours() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: [.monday, .tuesday, .wednesday], timespans: [.init(from: "8", to: "23")]),
            .init(action: .open, days: [.thursday], timespans: [.init(from: "8", to: "17")]),
            .init(action: .open, days: [.friday], timespans: [.init(from: "8", to: "20")]),
            .init(action: .open, days: weekend, timespans: [.init(from: "8", to: "2")]),
        ]

        let date1 = Date(timeIntervalSince1970: 1547424000) // 14.01.19; a Monday
        let date2 = Date(timeIntervalSince1970: 1547164800) // 11.01.19; a Friday
        let date3 = Date(timeIntervalSince1970: 1553347671) // 23.03.19; a Saturday

        let hours1 = openingHours.getOpeningHours(for: date1)
        let hours2 = openingHours.getOpeningHours(for: date2)
        let hours3 = openingHours.getOpeningHours(for: date3)

        XCTAssertEqual(hours1, POIKit.OpeningHoursValue.time(value: "08:00 – 23:00"))
        XCTAssertEqual(hours2, POIKit.OpeningHoursValue.time(value: "08:00 – 20:00"))
        XCTAssertEqual(hours3, POIKit.OpeningHoursValue.time(value: "08:00 – 02:00"))
    }

    func testMinutesTillClosed() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: [.monday, .tuesday, .wednesday], timespans: [.init(from: "8", to: "23")]),
            .init(action: .open, days: [.thursday], timespans: [.init(from: "8", to: "17")]),
            .init(action: .open, days: [.friday], timespans: [.init(from: "8", to: "20")]),
            .init(action: .open, days: weekend, timespans: [.init(from: "8", to: "23:15")]),
        ]

        let date1 = Date(timeIntervalSince1970: 1553347671) // 23.03.19; a Saturday
        let date2 = Date(timeIntervalSince1970: 1553434071) // 24.03.19; a Sunday

        let minutes1 = openingHours.minuteTillClose(from: date1)
        let minutes2 = openingHours.minuteTillClose(from: date2)

        XCTAssertEqual(minutes1, 528)
        XCTAssertEqual(minutes2, 528)
    }

    func testMidnightLogic() {
        // the array can be empty, because the method is not dependent on its values
        let openingHours: [PCPOICommonOpeningHours.Rules] = []

        let time1 = openingHours.minutesToTime(0, locale: Locale(identifier: "de_DE"))
        let time2 = openingHours.minutesToTime(0, from: true, locale: Locale(identifier: "de_DE"))
        let time3 = openingHours.minutesToTime(0, locale: Locale(identifier: "en_US"))
        let time4 = openingHours.minutesToTime(0, from: true, locale: Locale(identifier: "en_US"))

        XCTAssertEqual(time1, "24:00")
        XCTAssertEqual(time2, "00:00")
        XCTAssertEqual(time3, "12:00 AM")
        XCTAssertEqual(time4, "12:00 AM")
    }

    func testDateIsOpen() {
        let openingHours: [PCPOICommonOpeningHours.Rules] = [
            .init(action: .open, days: [.wednesday], timespans: [.init(from: "12", to: "1")]),
            .init(action: .open, days: [.friday], timespans: [.init(from: "6", to: "2")]),
            .init(action: .open, days: [.sunday], timespans: [.init(from: "0", to: "23")]),
            .init(action: .close, days: [.sunday], timespans: [.init(from: "23", to: "1")])
        ]

        let thursdayOpen = Date(timeIntervalSince1970: 1678921200) // 16.03.23, Thursday 0:00

        let fridayClosed = Date(timeIntervalSince1970: 1679025600) // 17.03.23, Friday 5:00
        let fridayOpen = Date(timeIntervalSince1970: 1679092200) // 17.03.23, Friday 23:30
        let saturdayOpen = Date(timeIntervalSince1970: 1679095200) // 18.03.23, Saturday 00:20
        let saturdayClosed = Date(timeIntervalSince1970: 1679104800) // 18.03.23, Saturday 3:00

        let sundayOpen = Date(timeIntervalSince1970: 1679216400) // 19.03.23, Sunday 10:00
        let sundayClosed = Date(timeIntervalSince1970: 1679265000) // 19.03.23, Sunday 23:30
        let mondayClosed = Date(timeIntervalSince1970: 1679268600) // 20.03.23, Monday 00:30

        let isClosed1 = openingHours.isClosed(on: thursdayOpen)

        let isClosed2 = openingHours.isClosed(on: fridayClosed)
        let isClosed3 = openingHours.isClosed(on: fridayOpen)
        let isClosed4 = openingHours.isClosed(on: saturdayOpen)
        let isClosed5 = openingHours.isClosed(on: saturdayClosed)

        let isClosed6 = openingHours.isClosed(on: sundayOpen)
        let isClosed7 = openingHours.isClosed(on: sundayClosed)
        let isClosed8 = openingHours.isClosed(on: mondayClosed)

        XCTAssertFalse(isClosed1)

        XCTAssertTrue(isClosed2)
        XCTAssertFalse(isClosed3)
        XCTAssertFalse(isClosed4)
        XCTAssertTrue(isClosed5)

        XCTAssertFalse(isClosed6)
        XCTAssertTrue(isClosed7)
        XCTAssertTrue(isClosed8)
    }
}
