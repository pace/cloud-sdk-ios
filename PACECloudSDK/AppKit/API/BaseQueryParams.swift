//
//  BaseQueryParams.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

protocol BaseQueryParams {
    var host: String { get }
    var redirectUri: String { get }
    var state: String { get }
    var statusCode: Int? { get set }
}
