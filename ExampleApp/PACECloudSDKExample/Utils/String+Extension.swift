//
//  String+Extension.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension String: Identifiable {
    public typealias ID = Int

    public var id: Int {
        return hash
    }
}
