//
//  URLRequestError.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum URLRequestError: Error, CustomStringConvertible {
    case failedRetrievingUrlRequest(String)
    case httpStatusCodeError
    case failedRetrievingCachedObject
    case urlRequestDataError
    case failedParsingJson
    case responseInvalid
    case other(Error)

    var description: String {
        switch self {
        case .failedRetrievingUrlRequest(let urlString):
            return "Failed to retrieve url request from string \(urlString)"

        case .httpStatusCodeError:
            return "HTTP Request did no return status code 200"

        case .urlRequestDataError:
            return "Couldn't retrieve data from url request"

        case .failedParsingJson:
            return "Couldn't parse json from data response"

        case .failedRetrievingCachedObject:
            return "Failed to retrieve object from cache"

        case .responseInvalid:
            return "Received invalid response"

        case .other(let error):
            return error.localizedDescription
        }
    }
}
