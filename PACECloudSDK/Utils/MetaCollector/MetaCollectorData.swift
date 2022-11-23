//
//  MetaCollectorData.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public protocol MetaCollectorService {
    var data: [String: AnyCodable] { get }
}

public extension PACECloudSDK.MetaCollector {
    class RequestBody: Encodable {
        enum CodingKeys: String, CodingKey { // swiftlint:disable:this nesting
            case deviceId, clientId, userId, services, lastLocation, firebasePushToken, locale
        }

        let deviceId: String
        let clientId: String
        var userId: String?
        var services: [MetaCollectorService]?
        var lastLocation: Location?
        var firebasePushToken: String?
        var locale: String?

        init(deviceId: String,
             clientId: String,
             userId: String? = nil,
             services: [MetaCollectorService]? = nil,
             lastLocation: Location? = nil,
             firebasePushToken: String? = nil,
             locale: String? = nil) {
            self.deviceId = deviceId
            self.clientId = clientId
            self.userId = userId
            self.services = services
            self.lastLocation = lastLocation
            self.firebasePushToken = firebasePushToken
            self.locale = locale
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(deviceId, forKey: .deviceId)
            try container.encodeIfPresent(clientId, forKey: .clientId)
            try container.encodeIfPresent(userId, forKey: .userId)
            try container.encodeIfPresent(services?.map { $0.data }, forKey: .services)
            try container.encodeIfPresent(lastLocation, forKey: .lastLocation)
            try container.encodeIfPresent(firebasePushToken, forKey: .firebasePushToken)
            try container.encodeIfPresent(locale, forKey: .locale)
        }
    }
}

public extension PACECloudSDK.MetaCollector.RequestBody {
    struct DefaultService: MetaCollectorService {
        public let name: String
        public let version: String

        public init(name: String, version: String) {
            self.name = name
            self.version = version
        }

        public var data: [String: AnyCodable] {
            ["name": .init(name), "version": .init(version)]
        }
    }

    struct Location: Encodable {
        public let accuracyInM: Double
        public let longitude: Double
        public let latitude: Double

        public init(accuracyInM: Double, longitude: Double, latitude: Double) {
            self.accuracyInM = accuracyInM
            self.longitude = longitude
            self.latitude = latitude
        }
    }
}
