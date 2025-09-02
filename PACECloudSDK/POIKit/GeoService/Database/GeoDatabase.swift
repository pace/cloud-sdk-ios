//
//  GeoDatabase.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
internal import GRDB

extension GeoAPIManager {
    actor GeoDatabase {
        private let url: URL
        private var migrator: DatabaseMigrator
        private let dbQueue: DatabaseQueue

        init(url: URL) async throws {
            self.url = url

            var config = Configuration()
            config.qos = .utility

            #if !PACECloudWatchSDK
            config.automaticMemoryManagement = true
            #endif

            self.dbQueue = try DatabaseQueue(path: url.path, configuration: config)

            var migrator = DatabaseMigrator()
            migrator.eraseDatabaseOnSchemaChange = true
            self.migrator = migrator

            try migrate()
        }

        func write(_ features: [GeoAPIFeature]) async throws {
            let geoElements = mappedGeoElements(features)

            try await dbQueue.write { db in
                for element in geoElements {
                    try element.save(db, onConflict: .replace)
                }
            }
        }

        func write(_ eTag: String) async throws {
            let eTagMetadata = GeoMetadata(key: GeoMetadata.eTagKey, value: eTag)

            try await dbQueue.write { db in
                try eTagMetadata.save(db, onConflict: .replace)
            }
        }

        func readAll() throws -> [POIKit.CofuGasStation] {
            let geoElements = try dbQueue.read { db in
                return try GeoElement.fetchAll(db)
            }

            let cofuGasStations = mappedCofuGasStations(geoElements)
            return cofuGasStations
        }

        func read(boundingBox: POIKit.BoundingBox) throws -> [POIKit.CofuGasStation] {
            let geoElements = try dbQueue.read { db in
                let predicateSQL =
                """
                bb.minLon >= ? AND bb.maxLon <= ? AND
                bb.minLat >= ? AND bb.maxLat <= ?
                """

                let sql =
                """
                SELECT g.*
                FROM geoElement g
                JOIN bounding_box_rtree bb ON g.id = bb.id
                WHERE \(predicateSQL)
                """

                let args: StatementArguments = [
                    boundingBox.minLon,
                    boundingBox.maxLon,
                    boundingBox.minLat,
                    boundingBox.maxLat
                ]

                return try GeoElement.fetchAll(db, sql: sql, arguments: args)
            }

            let cofuGasStations = mappedCofuGasStations(geoElements)
            return cofuGasStations
        }

        func read(poiId: String) throws -> POIKit.CofuGasStation? {
            let geoElement: GeoElement? = try dbQueue.read { db in
                try GeoElement.fetchOne(db,
                                        sql: "SELECT * FROM geoElement WHERE poiId = ?",
                                        arguments: [poiId])
            }

            guard let geoElement else { return nil }

            let cofuGasStation = mappedCofuGasStation(geoElement)
            return cofuGasStation
        }

        func readETag() throws -> String? {
            let eTagMetadata = try dbQueue.read { db in
                try GeoMetadata.fetchOne(db, key: GeoMetadata.eTagKey)
            }

            let eTag = eTagMetadata?.value
            return eTag
        }
    }
}

private extension GeoAPIManager.GeoDatabase {
    func mappedGeoElements(_ features: [GeoAPIFeature]) -> [GeoElement] {
        features.compactMap {
            guard let poiId = $0.id,
                  let geometry = $0.geometry,
                  case .point(let point) = geometry else { return nil }

            return .init(poiId: poiId,
                         longitude: point.coordinates[0],
                         latitude: point.coordinates[1],
                         properties: $0.properties)
        }
    }

    func mappedCofuGasStations(_ geoElements: [GeoElement]) -> [POIKit.CofuGasStation] {
        let cofuGasStations: [POIKit.CofuGasStation] = geoElements.map(mappedCofuGasStation)
        return cofuGasStations
    }

    func mappedCofuGasStation(_ geoElement: GeoElement) -> POIKit.CofuGasStation {
        let coordinates: GeoAPICoordinate = [geoElement.longitude, geoElement.latitude]
        let mappedProperties: [String: Any] = (geoElement.properties ?? [:]).mapValues { $0.value }

        return .init(id: geoElement.poiId,
                     coordinates: coordinates,
                     polygon: nil,
                     properties: mappedProperties)
    }
}

private extension GeoAPIManager.GeoDatabase {
    func migrate() throws {
        migrator.registerMigration("GeoElements, GeoMetadata and BoundingBox r-tree") { db in
            try db.create(table: "geoElement", options: .ifNotExists) { t in
                t.autoIncrementedPrimaryKey("id", onConflict: .replace)
                t.column("poiId", .text).notNull()
                t.column("longitude", .double).notNull()
                t.column("latitude", .double).notNull()
                t.column("properties", .jsonb)
            }

            try db.create(table: "geoMetadata", options: .ifNotExists) { t in
                t.primaryKey("key", .text, onConflict: .replace)
                t.column("value", .text).notNull()
            }

            // Create bounding box r-tree
            try db.execute(sql:
                """
                CREATE VIRTUAL TABLE IF NOT EXISTS bounding_box_rtree USING rtree(
                    id,             -- matches geoElement.id
                    minLon, maxLon, -- longitude
                    minLat, maxLat  -- latitude
                );
                """)

            // Create triggers to automatically insert into bounding box r-tree
            try db.execute(sql:
                """
                CREATE TRIGGER IF NOT EXISTS geoElement_after_insert AFTER INSERT ON geoElement
                BEGIN
                    INSERT INTO bounding_box_rtree(id, minLon, maxLon, minLat, maxLat)
                    VALUES (new.id, new.longitude, new.longitude, new.latitude, new.latitude);
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER IF NOT EXISTS geoElement_after_update AFTER UPDATE OF longitude, latitude ON geoElement
                BEGIN
                    UPDATE bounding_box_rtree
                        SET minLon = new.longitude, maxLon = new.longitude,
                            minLat = new.latitude,  maxLat = new.latitude
                    WHERE id = new.id;
                END;
                """)

            try db.execute(sql: """
                CREATE TRIGGER IF NOT EXISTS geoElement_after_delete AFTER DELETE ON geoElement
                BEGIN
                    DELETE FROM bounding_box_rtree WHERE id = old.id;
                END;
                """)
        }

        try migrator.migrate(dbQueue)
    }
}
