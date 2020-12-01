//
//  POIKitEnvironment.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum POIKitBaseUrl {
    case osrm
    case search
    case reverseGeocode
    case tile
    case poi
    case api
}

public extension POIKit {
    /** MapKit Environment */
    class POIKitEnvironment {
        /** Production Environment */
        public static let PRODUCTION = POIKitEnvironment(
            apiHostUrl: "https://api.pace.cloud/poi",
            osrmBaseUrl: "https://maps.pacelink.net/",
            searchBaseUrl: "https://api.pace.cloud/photon/api",
            reverseGeocodeBaseUrl: "https://api.pace.cloud/photon/reverse",
            tileBaseUrl: "https://maps.pacelink.net/tiles/car-mm",
            poiBaseUrl: "https://api.pace.cloud/poi/v1/tiles"
        )

        /** Staging Enviroment */
        public static let STAGING = POIKitEnvironment(
            apiHostUrl: "https://api.stage.pace.cloud/poi",
            osrmBaseUrl: "https://maps.pacelink.net/",
            searchBaseUrl: "https://api.pace.cloud/photon/api",
            reverseGeocodeBaseUrl: "https://api.pace.cloud/photon/reverse",
            tileBaseUrl: "https://maps.pacelink.net/tiles/car-mm",
            poiBaseUrl: "https://api.stage.pace.cloud/poi/v1/tiles"
        )

        /** Sandbox Environment */
        public static let SANDBOX = POIKitEnvironment(
            apiHostUrl: "https://api.sandbox.pace.cloud/poi",
            osrmBaseUrl: "https://maps.pacelink.net/",
            searchBaseUrl: "https://api.pace.cloud/photon/api",
            reverseGeocodeBaseUrl: "https://api.pace.cloud/photon/reverse",
            tileBaseUrl: "https://maps.pacelink.net/tiles/car-mm",
            poiBaseUrl: "https://api.sandbox.pace.cloud/poi/v1/tiles"
        )

        /** Development Environment */
        public static let DEVELOPMENT = POIKitEnvironment(
            apiHostUrl: "https://api.dev.pace.cloud/poi",
            osrmBaseUrl: "https://maps.pacelink.net/",
            searchBaseUrl: "https://api.pace.cloud/photon/api",
            reverseGeocodeBaseUrl: "https://api.pace.cloud/photon/reverse",
            tileBaseUrl: "https://maps.pacelink.net/tiles/car-mm",
            poiBaseUrl: "https://api.dev.pace.cloud/poi/v1/tiles"
        )

        let apiHostUrl: String
        let osrmBaseUrl: String
        let searchBaseUrl: String
        let reverseGeocodeBaseUrl: String
        let tileBaseUrl: String
        let poiBaseUrl: String
        let sslVerifyHost: String
        let name: String

        public init(apiHostUrl: String,
                    osrmBaseUrl: String,
                    searchBaseUrl: String,
                    reverseGeocodeBaseUrl: String,
                    tileBaseUrl: String,
                    poiBaseUrl: String,
                    name: String = "") {
            self.apiHostUrl = apiHostUrl
            self.osrmBaseUrl = osrmBaseUrl
            self.searchBaseUrl = searchBaseUrl
            self.reverseGeocodeBaseUrl = reverseGeocodeBaseUrl
            self.tileBaseUrl = tileBaseUrl
            self.poiBaseUrl = poiBaseUrl
            self.sslVerifyHost = "."
            self.name = name
        }

        func baseUrl(_ type: POIKitBaseUrl) -> String {
            switch type {
            case .api:
                return apiHostUrl

            case .osrm:
                return osrmBaseUrl

            case .search:
                return searchBaseUrl

            case .reverseGeocode:
                return reverseGeocodeBaseUrl

            case .tile:
                return tileBaseUrl

            case .poi:
                return poiBaseUrl
            }
        }
    }
}
