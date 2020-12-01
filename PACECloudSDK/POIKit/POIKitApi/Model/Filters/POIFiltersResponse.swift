//
//  FiltersResponse.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation


public extension POIKit {
    struct POIFiltersResponse {
        public let filterGroups: [String: [String: Bool]]

        init(with response: POIFiltersAPIResponse) {
            var filterGroups: [String: [String: Bool]] = [:]
            response.data.forEach {
                var filters: [String: Bool] = [:]
                $0.attributes.available?.forEach {
                    filters[$0] = true
                }

                $0.attributes.unavailable?.forEach {
                    filters[$0] = false
                }

                filterGroups[$0.attributes.fieldName] = filters
            }
            self.filterGroups = filterGroups
        }

        init(with categories: PCCategories) {
            var filterGroups: [String: [String: Bool]] = [:]
            categories.forEach {
                var filters: [String: Bool] = [:]
                $0.attributes?.available?.forEach {
                    filters[$0] = true
                }

                $0.attributes?.unavailable?.forEach {
                    filters[$0] = false
                }

                filterGroups[$0.attributes?.fieldName ?? ""] = filters
            }
            self.filterGroups = filterGroups
        }
    }

    struct POIFiltersAPIResponse: Decodable {
        let data: [POIFiltersAPIData]
    }

    struct POIFiltersAPIData: Decodable {
        let type: String
        let attributes: POIFiltersAPIAttributes
    }

    struct POIFiltersAPIAttributes: Decodable {
        let field: String
        let fieldName: String
        let available: [String]?
        let unavailable: [String]?
    }
}
