//
//  POIModelConvertible.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public protocol POIModelConvertible {
    associatedtype POIModel

    init?(from poiModel: POIModel)
    func poiConverted() -> POIModel
}
