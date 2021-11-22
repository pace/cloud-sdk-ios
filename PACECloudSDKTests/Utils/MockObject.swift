//
//  MockObject.swift
//  PACECloudSDKTests
//
//  Created by PACE Telematics GmbH.
//

import Foundation

protocol MockObject {
    var url: String { get }
    var mockData: Result<Data, Error> { get }
    var statusCode: Int { get }

    init(mockData: Result<Data, Error>?, statusCode: Int)
}

struct MockData {}
