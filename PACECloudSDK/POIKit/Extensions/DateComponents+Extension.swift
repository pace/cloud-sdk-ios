//
//  DateComponents+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension DateComponents {
    init(fromMinutes minutes: Int) {
        let fullHours = minutes / 60
        self.init(day: fullHours / 24, hour: fullHours % 24, minute: minutes % 60)
    }

    static var allComponentsSet: Set<Calendar.Component> {
        [.era, .year, .month, .day, .hour, .minute,
         .second, .weekday, .weekdayOrdinal, .quarter,
         .weekOfMonth, .weekOfYear, .yearForWeekOfYear,
         .nanosecond, .calendar, .timeZone]
    }
}
