//
//  GeoDatabase.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import GRDB

extension GeoAPIManager {
    class GeoDatabase {
        private let queue: DispatchQueue = .init(label: "geo-database", qos: .utility, autoreleaseFrequency: .workItem)

        private let url: URL
        private let targetQueue: DispatchQueue
        private let config: Configuration
        private var migrator: DatabaseMigrator

        init(url: URL, targetQueue: DispatchQueue) throws {
            self.url = url
            self.targetQueue = targetQueue

            var config = Configuration()
            config.automaticMemoryManagement = true
            config.qos = .utility
            config.targetQueue = targetQueue
            self.config = config

            var migrator = DatabaseMigrator()
            migrator.eraseDatabaseOnSchemaChange = true
            self.migrator = migrator

            try migrate()
        }

        private func dbQueue() throws -> DatabaseQueue {
            try DatabaseQueue(path: url.path, configuration: config)
        }

        func write(_ elements: [GeoElement]) throws {
            let dbQueue = try dbQueue()
            try dbQueue.write { db in
                try elements.forEach { element in
                    try element.save(db)
                }
            }
        }
    }
}

private extension GeoAPIManager.GeoDatabase {
    func migrate() throws {
        migrator.registerMigration("Location and GeoElement") { db in
            try db.create(table: "geoElement", options: .ifNotExists) { t in
                t.primaryKey("id", .text)
                t.column("location", .jsonb)
                t.column("polygon", .jsonb)
                t.column("properties", .jsonb)
            }
        }

        let dbQueue = try dbQueue()
        try migrator.migrate(dbQueue)
    }
}
