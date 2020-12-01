//
//  HttpUrlError.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public enum HttpUrlError: Error, CustomStringConvertible {
    case statusCode(Int)
    case invalidHTTPURLResponse(URL)
    case invalidData(URL)
    case invalidUrl(String)

    public var description: String {
        switch self {

        case .statusCode(let statusCode):
            return "Retrieved response with status code \(statusCode)"

        case .invalidHTTPURLResponse(let url):
            return "The retrieved HTTPURLResponse is invalid for \(url.absoluteString)"

        case .invalidData(let url):
            return "The retrieved data is invalid for \(url.absoluteString)"

        case .invalidUrl(let url):
            return "The provided url string is invalid: \(url)"
        }
    }
}
