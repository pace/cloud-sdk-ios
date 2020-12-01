//
//  Date+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Date {
    var today: Date {
        var now = self.dateComponents
        now.hour = 0
        now.minute = 0
        now.second = 0
        now.nanosecond = 0

        return now.date ?? self
    }

    var dateComponents: DateComponents {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = TimeZone(identifier: "GMT") ?? TimeZone.autoupdatingCurrent
        calendar.locale = Locale.autoupdatingCurrent

        return calendar.dateComponents(DateComponents.allComponentsSet, from: self)
    }
}

extension DateComponents {
    static var allComponentsSet: Set<Calendar.Component> {
        [.era, .year, .month, .day, .hour, .minute,
         .second, .weekday, .weekdayOrdinal, .quarter,
         .weekOfMonth, .weekOfYear, .yearForWeekOfYear,
         .nanosecond, .calendar, .timeZone]
    }
}
