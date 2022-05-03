//
//  DateTimeProvider.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

protocol DateTimeProvider {
    var currentDate: Date { get }
}

extension DateTimeProvider {
    var currentDate: Date {
        Date()
    }
}

struct DateTimeProviderHelper: DateTimeProvider {}
