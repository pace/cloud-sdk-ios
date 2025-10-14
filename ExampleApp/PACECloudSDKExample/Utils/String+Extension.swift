//
//  String+Extension.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension String: Identifiable {
    public typealias ID = Int // swiftlint:disable:this type_name

    public var id: Int {
        return hash
    }
}
