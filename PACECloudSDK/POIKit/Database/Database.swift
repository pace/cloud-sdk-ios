//
//  Database.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public extension POIKit {
    static func setDatabaseDelegate(_ delegate: POIDatabaseDelegate) {
        Database.setupDelegate(delegate)
    }
}

extension POIKit {
    class Database {
        static var shared = Database()
        weak var delegate: POIDatabaseDelegate?

        static func setupDelegate(_ delegate: POIDatabaseDelegate) {
            shared.delegate = delegate
        }
    }
}

public protocol POIDatabaseDelegate: AnyObject {
    func get(uuid: String) -> POIKit.GasStation?
    func get(inRect: POIKit.BoundingBox) -> [POIKit.GasStation]
    func get(uuids: [String]) -> [POIKit.GasStation]
    func add(_ gasStation: POIKit.GasStation)
    func add(_ gasStations: [POIKit.GasStation])
    func delete(_ gasStation: POIKit.GasStation)
    func delete(ignoreIds: [String], boundingBox: POIKit.BoundingBox)
}

public extension POIDatabaseDelegate {
    func get(uuid: String) -> POIKit.GasStation? { return nil }
    func get(inRect: POIKit.BoundingBox) -> [POIKit.GasStation] { return [] }
    func get(uuids: [String]) -> [POIKit.GasStation] { return [] }
    func add(_ gasStation: POIKit.GasStation) {}
    func add(_ gasStations: [POIKit.GasStation]) {}
    func delete(_ gasStation: POIKit.GasStation) {}
    func delete(ignoreIds: [String], boundingBox: POIKit.BoundingBox) {}
}

public protocol POIKitObserverTokenDelegate: AnyObject {
    func invalidateToken()
    func observe(_ handler: ((Bool, [POIKit.GasStation]) -> Void)?) -> AnyObject?
    func observe(uuids: [String], _ handler: (([POIKit.GasStation]) -> Void)?) -> AnyObject?
}

public extension POIKitObserverTokenDelegate {
    func invalidateToken() {}
    func observe(_ handler: ((Bool, [POIKit.GasStation]) -> Void)?) -> AnyObject? { return nil }
    func observe(uuids: [String], _ handler: (([POIKit.GasStation]) -> Void)?) -> AnyObject? { return nil }
}

public protocol POIModelConvertible {
    associatedtype POIModel

    init?(from poiModel: POIModel)
    func poiConverted() -> POIModel
}
