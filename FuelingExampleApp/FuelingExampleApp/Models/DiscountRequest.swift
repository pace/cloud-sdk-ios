//
//  DiscountRequest.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct DiscountRequest: Encodable {
    let data: DiscountInquiry
}

struct DiscountInquiry: Encodable {
    let type: String = "discountInquiry"
    let id: String = UUID().uuidString.lowercased()
    let attributes: DiscountInquiryAttributes
}

struct DiscountInquiryAttributes: Encodable {
    let paymentMethodId: String?
    let paymentMethodKind: String?
}
