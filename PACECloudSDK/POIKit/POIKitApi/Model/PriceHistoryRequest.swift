//
//  PriceHistoryRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct PriceHistoryRequest {
    var id: String
    var fuelType: String
    var params: [String: [String]] {
        return [
            "filter[from]": [from],
            "filter[to]": [to]
        ]
    }

    var options: POIAPI.PriceHistories.GetPriceHistory.Request.Options {
        let dateFormatter = ISO8601DateFormatter()
        return POIAPI.PriceHistories
            .GetPriceHistory
            .Request
            .Options(id: id,
                     fuelType: PCPOIFuel(rawValue: fuelType),
                     filterfrom: dateFormatter.date(from: from),
                     filterto: dateFormatter.date(from: to))
    }

    private var from: String
    private var to: String

    init(id: String, fuelType: String, from: String, to: String) {
        self.id = id
        self.fuelType = fuelType
        self.from = from
        self.to = to
    }
}
