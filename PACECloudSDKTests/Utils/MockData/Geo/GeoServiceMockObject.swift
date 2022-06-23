//
//  GeoServiceMockObject.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension MockData {
    struct GeoServiceMockObject: MockObject {
        private(set) var url: String
        private(set) var mockData: Result<Data, Error>
        private(set) var statusCode: Int

        init(mockData: Result<Data, Error>? = nil, statusCode: Int = 200) {
            self.url = "https://cdn.dev.pace.cloud/geo/2021-1/apps/pace-drive-ios-min.geojson"
            self.mockData = mockData ?? GeoServiceMockObject.defaultMockData
            self.statusCode = statusCode
        }

        private static var defaultMockData: Result<Data, Error> {
            if CommandLine.arguments.contains(CommandLineArgument.emptyGeoResponse.rawValue) {
                return .success(GeoServiceMockObject.emptyGeoServiceData)
            } else if CommandLine.arguments.contains(CommandLineArgument.geoRequestError.rawValue) {
                return .failure(URLError(.badServerResponse))
            } else {
                return .success(GeoServiceMockObject.geoServiceData)
            }
        }
    }
}

extension MockData.GeoServiceMockObject {
    private static let emptyGeoServiceData: Data =
        """
        {
            "type": "FeatureCollection",
            "features": []
        }
        """.data(using: .utf8) ?? Data()

    private static let geoServiceData: Data =
        """
        {
            "type": "FeatureCollection",
            "features": [{
                "id": "e3211b77-03f0-4d49-83aa-4adaa46d95ae",
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [8.427428305149078, 49.012591410884085]
                },
                "properties": {
                    "apps": [{
                        "type": "fueling",
                        "url": "https://dev.fuel.site"
                    }],
                    "connectedFuelingStatus": "online",
                    "pacePay": true
                }
            }, {
                "id": "2745dc62-0d2a-474f-9849-3de4a76b888a",
                "type": "Feature",
                "geometry": {
                    "type": "Point",
                    "coordinates": [8.42731699347496, 49.01260548482239]
                },
                "properties": {
                    "apps": [{
                        "type": "fueling",
                        "url": "https://dev.fuel.site"
                    }],
                    "connectedFuelingStatus": "offline",
                    "pacePay": false
                }
            }]
        }
        """.data(using: .utf8) ?? Data()
}
