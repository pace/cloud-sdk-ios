//
//  GasStation.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public extension POIKit {
    class GasStation: PCGasStation {
        public var prices: [PCFuelPrice] = []
        public var currency: String?

        public var layer: POILayer = .unknown
        public var layerType: String?

        public var distance: Float?

        public var geometry: [GeometryCommand] = [] {
            didSet {
                var lat: Double?
                var lon: Double?
                var geoCount: Int = 0

                for geo in geometry {
                    let coordinate = geo.location.coordinate

                    geoCount += 1

                    lat = (lat ?? 0.0) + coordinate.latitude
                    lon = (lon ?? 0.0) + coordinate.longitude
                }

                guard let latitude = lat, let longitude = lon, geoCount > 0 else { return }

                attributes?.latitude = Float(latitude) / Float(geoCount)
                attributes?.longitude = Float(longitude) / Float(geoCount)
            }
        }

        /** coordinate where the POI is located, center coordinate for Polygons */
        public var coordinate: CLLocationCoordinate2D? {
            let coordinates: [CLLocationCoordinate2D] = geometry.compactMap { $0.location.coordinate }
            guard let minLat = coordinates.min(by: { $0.latitude < $1.latitude })?.latitude,
                let maxLat = coordinates.max(by: { $0.latitude < $1.latitude })?.latitude,
                let minLon = coordinates.min(by: { $0.longitude < $1.longitude })?.longitude,
                let maxLon = coordinates.max(by: { $0.longitude < $1.longitude })?.longitude else {
                    return nil
            }

            return CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        }

        public var region: CLCircularRegion? {
            let coordinates: [CLLocationCoordinate2D] = geometry.compactMap { $0.location.coordinate }
            guard let id = id,
                let minLat = coordinates.min(by: { $0.latitude < $1.latitude })?.latitude,
                let minLon = coordinates.min(by: { $0.longitude < $1.longitude })?.longitude,
                let center = self.coordinate else {
                    return nil
            }

            let radius = center.distance(from: CLLocationCoordinate2D(latitude: minLat, longitude: minLon))
            return CLCircularRegion(center: center, radius: radius, identifier: id)
        }

        /// Returns a sorted list of all services
        public var allServices: [String] {
            let amenities = attributes?.amenities?.map { $0.rawValue } ?? []
            let foods = attributes?.food?.map { $0.rawValue } ?? []
            let loyaltyPrograms = attributes?.loyaltyPrograms?.map { $0.rawValue } ?? []
            let postalServices = attributes?.postalServices?.map { $0.rawValue } ?? []
            let services = attributes?.services?.map { $0.rawValue } ?? []
            let shopGoods = attributes?.shopGoods?.map { $0.rawValue } ?? []

            var result = amenities + foods + loyaltyPrograms + postalServices + services + shopGoods

            result.sort()

            return result
        }

        public var isConnectedFuelingAvailable = false

        public var lastUpdated: Date?
        public var lastFetched: Date = Date()

        public var priceComparisonOptOut: Bool = false

        public init() {
            super.init(attributes: .init(), relationships: .init(), type: .gasStation)
        }

        public init(id: String, coordinate: CLLocationCoordinate2D) {
            super.init(attributes: .init(), id: id, relationships: .init(), type: .gasStation)
            self.geometry = [GeometryCommand(type: .moveTo, coordinate: coordinate)]
        }

        public required init(from decoder: Decoder) throws {
            fatalError("init(from:) has not been implemented")
        }

        public static func == (lhs: GasStation, rhs: GasStation) -> Bool {
            return lhs.id == rhs.id
        }
    }
}

extension PCCommonOpeningHours.Rules: CustomStringConvertible {
    public var description: String {
        "\(days?.map { $0.shortenedRawValue } ?? []): \(timespans ?? []): \(action?.rawValue ?? "-")"
    }
}

extension PCCommonOpeningHours.Rules.Timespans: CustomStringConvertible {
    public var description: String {
        return "From \(from ?? "nil") to \(to ?? "nil")"
    }
}

extension PCCommonOpeningHours.Rules.PCDays {
    public var shortenedRawValue: String {
        switch self {
        case .monday:
            return "mo"

        case .tuesday:
            return "tu"

        case .wednesday:
            return "we"

        case .thursday:
            return "th"

        case .friday:
            return "fr"

        case .saturday:
            return "sa"

        case .sunday:
            return "su"
        }
    }

    public init?(rawValue: String) {
        switch rawValue {
        case "mo", PCCommonOpeningHours.Rules.PCDays.monday.rawValue:
            self = PCCommonOpeningHours.Rules.PCDays.monday

        case "tu", PCCommonOpeningHours.Rules.PCDays.tuesday.rawValue:
            self = PCCommonOpeningHours.Rules.PCDays.tuesday

        case "we", PCCommonOpeningHours.Rules.PCDays.wednesday.rawValue:
            self = PCCommonOpeningHours.Rules.PCDays.wednesday

        case "th", PCCommonOpeningHours.Rules.PCDays.thursday.rawValue:
            self = PCCommonOpeningHours.Rules.PCDays.thursday

        case "fr", PCCommonOpeningHours.Rules.PCDays.friday.rawValue:
            self = PCCommonOpeningHours.Rules.PCDays.friday

        case "sa", PCCommonOpeningHours.Rules.PCDays.saturday.rawValue:
            self = PCCommonOpeningHours.Rules.PCDays.saturday

        case "su", PCCommonOpeningHours.Rules.PCDays.sunday.rawValue:
            self = PCCommonOpeningHours.Rules.PCDays.sunday

        default:
            return nil
        }
    }

    static var weekdays: [PCCommonOpeningHours.Rules.PCDays] = [.monday, .tuesday, .wednesday, .thursday, .friday]
    static var weekend: [PCCommonOpeningHours.Rules.PCDays] = [.saturday, .sunday]
}
