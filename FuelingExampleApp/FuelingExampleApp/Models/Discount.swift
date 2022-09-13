//
//  Discount.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct Discount {
    let id: String
    let amount: Decimal
    let token: String

    init?(from data: DiscountResponseData) {
        guard let id = data.id,
              let amount = data.attributes?.amount else {
                  return nil
              }

        self.id = id
        self.amount = amount
        self.token = "prn:discount:tokens:\(id)"
    }
}
