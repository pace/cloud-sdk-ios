//
//  Dictionary+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Dictionary where Key == AnyHashable, Value == Any {
    func jsonString() -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: []), let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }

        return jsonString
    }
}
