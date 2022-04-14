//
//  ISO8601DateFormatter+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension ISO8601DateFormatter {
    func timeIntervalSince1970(from dateString: String) -> TimeInterval? {
        guard let date = date(from: dateString) else {
            return nil
        }

        return date.timeIntervalSince1970
    }
}
