//
//  API.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public struct API {
    /**
     The access token to be used for API requests.

     This token will be set automatically when using IDKit.
     */
    public static var accessToken: String?
}

public extension API {
    /**
     Determines if an API request should be retried.

     It takes into account if the request has failed due to network connection errors or timeouts and if the maximum number of retries has been exceeded.

     - parameter currentRetryCount: The current number of retries for a specific request.
     - parameter maxRetryCount: The maximum number of retries allowed for a specific request.
     - parameter response: The most recent URL response of a specific request or `nil` if not available.
     */
    static func shouldRetryRequest(currentRetryCount: Int,
                                   maxRetryCount: Int,
                                   response: URLResponse?) -> Bool {
        guard currentRetryCount <= maxRetryCount else { return false }
        guard let response = response as? HTTPURLResponse else { return true }
        return response.statusCode == HttpStatusCode.requestTimeout.rawValue
    }

    /**
     Returns the number of seconds an API request should be delayed before the next retry is executed.

     It calculates the number of seconds based on an exponential backoff algorithm.

     - parameter currentRetryCount: The current number of retries for a specific request.
     - parameter delayUpperBound: The maximum number of seconds a request should be delayed. Defaults to `64`.
     - returns: The request delay in seconds.
     */
    static func nextExponentialBackoffRequestDelay(currentRetryCount: Int, delayUpperBound: Int = 64) -> Int {
        let nextDelayIteration = NSDecimalNumber(decimal: pow(2, currentRetryCount - 1))
        let delay = min(Int(truncating: nextDelayIteration), delayUpperBound)
        return delay
    }
}
