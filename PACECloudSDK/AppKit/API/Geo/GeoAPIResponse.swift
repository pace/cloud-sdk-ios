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
    let id: String?
    let type: String?
    let geometry: GeoAPIGeometry?
    let properties: GeoAPIProperties?
}

struct GeoAPIGeometry: Decodable {
    let type: String?
    let coordinates: [GeoAPICoordinates]?
}

struct GeoAPIProperties: Decodable {
    let apps: [GeoAPIApp]?
    let reference: String?
}

struct GeoAPIApp: Decodable {
    let type: String?
    let url: String?
}

typealias GeoAPICoordinates = [GeoAPICoordinate]
typealias GeoAPICoordinate = [Double]
