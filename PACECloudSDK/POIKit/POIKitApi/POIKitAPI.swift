//
//  POIKitAPI.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

class POIKitAPI: POIKitAPIProtocol {
    var environment: PACECloudSDK.Environment = .production
    let request: HttpRequestProtocol

    static let shared = POIKitAPI()

    let invalidationTokenCache = InvalidationTokenCache()

    // MARK: - Initialize

    init(request: HttpRequestProtocol = HttpRequest()) {
        self.request = request
    }

    func setLanguage(_ language: String) {
        request.set(language: language)
    }

    // MARK: - Internal methods

    func buildURL(_ baseUrl: Settings.POIKitBaseUrl, path: String, urlParams: [String: [String]] = [:]) -> URL? {
        var urlString = ""

        if !urlParams.isEmpty {
            urlString = "?"
            // Append each parameter to the url
            for (key, values) in urlParams {
                for value in values {
                    guard let key = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                        let value = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { continue }

                    if urlString.count > 1 { urlString += "&" }
                    urlString += "\(key)=\(value)"
                }
            }
        }

        // Prepend base url and path
        urlString = Settings.shared.baseUrl(baseUrl) + path + urlString

        return URL(string: urlString)
    }
}
