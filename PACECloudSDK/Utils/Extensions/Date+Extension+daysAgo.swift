//
//  Date+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Date {
    func daysAgo(_ days: Int) -> Date {
        let todayTimeIntervalSince1970 = self.timeIntervalSince1970
        let oneDay: Double = 24 * 60 * 60

        return Date(timeIntervalSince1970: todayTimeIntervalSince1970 - oneDay * Double(days))
    }
}
