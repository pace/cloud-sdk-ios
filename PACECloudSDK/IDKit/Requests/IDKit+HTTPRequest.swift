//
//  IDKit+HTTPRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func performHTTPRequest<T: Decodable>(for url: URL, type: T.Type, completion: @escaping ((T?, IDKitError?) -> Void)) {
        guard let accessToken = session?.lastTokenResponse?.accessToken else {
            completion(nil, .invalidSession)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: HttpHeaderFields.authorization.rawValue)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, .other(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(nil, .invalidHTTPURLResponse(url))
                return
            }

            guard response.statusCode < 400 else {
                completion(nil, .statusCode(response.statusCode))
                return
            }

            guard let data = data else {
                completion(nil, .invalidData(url))
                return
            }

            do {
                let result = try JSONDecoder().decode(type, from: data)
                completion(result, nil)
            } catch {
                completion(nil, .other(error))
            }
        }.resume()
    }
}
