//
//  Tile.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct Tile: Hashable {

    private(set) var id = ""
    var tileId = "" {
        didSet { id = "\(tileId)_\(_type)" }
    }
    var tileInformation: TileInformation
    var data = Data()
    var invalidationToken: Int64 = 0
    var created = Date()
    var lastUsed = Date()
    var validUntil = Date()
    var _type: String = LayerType.poi.rawValue {
        didSet { id = "\(tileId)_\(_type)" }
    }
    var type: LayerType {
        get { return LayerType(rawValue: _type) ?? .poi }
        set { _type = newValue.rawValue }
    }

    init(tileInformation: TileInformation, type: LayerType, invalidationToken: Int64 = 0, data: Data, created: Date = Date(), timeToLive: Int? = nil) {
        self.tileId = tileInformation.id
        self.tileInformation = tileInformation
        self.type = type
        self.invalidationToken = invalidationToken
        self.data = data
        self.created = created
        if let timeToLive = timeToLive {
            self.validUntil = created.addingTimeInterval(Double(timeToLive))
        } else {
            self.validUntil = created.addingTimeInterval(Double(type.defaultTimeToLive))
        }
    }
}
