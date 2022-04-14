//
//  Date+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Date {
    var today: Date {
        Calendar.current.startOfDay(for: self)
    }

    var dateComponents: DateComponents {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(identifier: "GMT") ?? TimeZone.autoupdatingCurrent
        calendar.locale = Locale.autoupdatingCurrent

        return calendar.dateComponents(DateComponents.allComponentsSet, from: self)
    }

    public func daysLater(_ days: Int) -> Date? {
        var referenceDate: Date? = self

        for _ in 0..<days {
            guard let oldReferenceDate = referenceDate else { return nil }
            referenceDate = Calendar.current.nextDate(after: oldReferenceDate,
                                                      matching: Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond],
                                                                                                from: self),
                                                      matchingPolicy: .nextTime,
                                                      direction: .forward)
        }

        return referenceDate
    }

    public func daysAgo(_ days: Int) -> Date {
        var referenceDate = self

        for _ in 0..<days {
            referenceDate = Calendar.current.nextDate(after: referenceDate,
                                                      matching: Calendar.current.dateComponents([.hour, .minute, .second, .nanosecond],
                                                                                                from: self),
                                                      matchingPolicy: .nextTime,
                                                      direction: .backward) ??
                                                      Date(timeIntervalSince1970: referenceDate.timeIntervalSince1970 - 24 * 60 * 60)
        }

        return referenceDate
    }

    public var yesterday: Date {
        return daysAgo(1)
    }

    public var oneWeekAgo: Date {
        return daysAgo(7)
    }

    public var tomorrow: Date {
        daysLater(1) ?? Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 24 * 60 * 60)
    }

    /**
     Retrieves the `timeIntervalSince1970` of the given date at the given minutes.

     - Parameters:
        - date: The reference date.
        - atMinutes: The Minutes at which the time should be.
     - Returns: A `TimeInterval?` representing the `timeIntervalSince1970` of the given date at the given minutes.
     */
    public func timeIntervalSince1970(atMinutes start: Int) -> TimeInterval? {
        let addComponents = DateComponents(fromMinutes: start)

        guard let hour = addComponents.hour,
              let minute = addComponents.minute,
              let day = addComponents.day,
              let newDate = Calendar.current.date(bySettingHour: hour,
                                                  minute: minute,
                                                  second: 0,
                                                  of: self)
        else { return nil }

        return newDate.daysLater(day)?.timeIntervalSince1970
    }
}
