//
//  NSMutableData+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension NSMutableData {
    /**
     Append string to NSMutableData
     - parameter string: The string to be added to the `NSMutableData`.
     */
    func appendString(_ string: String) {
        guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) else { return }
        append(data)
    }
}
