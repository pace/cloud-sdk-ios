//
//  DiscountResponse.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct DiscountResponse: Decodable {
    let data: [DiscountResponseData]?
}

struct DiscountResponseData: Decodable {
    let type: String?
    let id: String?
    let attributes: DiscountResponseAttributes?
}

struct DiscountResponseAttributes: Decodable {
    let amount: Decimal?
    let provider: String?
    let title: String?
}
