//
//  Array+Extension.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        indices ~= index ? self[index] : nil
    }
}
