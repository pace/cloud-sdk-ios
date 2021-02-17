//
//  Array+Extension.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
