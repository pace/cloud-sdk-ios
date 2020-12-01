//
//  VectorTiles+Feature.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension VectorTile_Tile.Feature {
    func getValues(for layer: VectorTile_Tile.Layer) -> [String: String] {
        var values = [String: String]()

        var index = 0
        while index < tags.count {
            let keyTag = Int(tags[index])
            let nameTag = Int(tags[index + 1])

            index += 2

            let key = layer.keys[keyTag]
            let value = layer.values[nameTag]

            guard value.hasStringValue else {
                continue
            }

            values[key] = value.stringValue
        }

        return values
    }
}
