//
//  GeoAPIResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct GeoAPIResponse: Decodable {
    let type: String?
    let features: [GeoAPIFeature]?
}

struct GeoAPIFeature: Decodable {
    let id, type: String?
    let geometry: GeometryFeature?
    let properties: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case geometry
        case properties
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        type = try values.decode(String.self, forKey: .type)
        geometry = try values.decode(GeometryFeature.self, forKey: .geometry)
        properties = try values.decode([String: AnyCodable].self, forKey: .properties)
    }
}

enum GeometryFeature: Decodable {
    case point(GeometryPointFeature)
    case polygon(GeometryPolygonFeature)
    case collections(GeometryCollectionsFeature)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(GeometryPolygonFeature.self) {
            self = .polygon(x)
            return
        }

        if let x = try? container.decode(GeometryPointFeature.self) {
            self = .point(x)
            return
        }

        if let x = try? container.decode(GeometryCollectionsFeature.self) {
            self = .collections(x)
            return
        }

        throw DecodingError.typeMismatch(GeometryFeature.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for GeometryFeature"))
    }
}

struct GeometryPointFeature: Decodable {
    let type: String?
    let coordinates: GeoAPICoordinate
}

struct GeometryPolygonFeature: Decodable {
    let type: String?
    let coordinates: [GeoAPICoordinates]
}

struct GeometryCollectionsFeature: Decodable {
    let type: String?
    let geometries: [GeometryFeature]?
}

public typealias GeoAPICoordinates = [GeoAPICoordinate]
public typealias GeoAPICoordinate = [Double]
