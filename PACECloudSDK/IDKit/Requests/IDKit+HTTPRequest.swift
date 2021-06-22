//
//  IDKit+HTTPRequest.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension IDKit {
    func performHTTPRequest<T: Decodable>(for url: URL, type: T.Type, currentNumberOfRetries: Int = 0, completion: @escaping ((T?, IDKitError?) -> Void)) {
        guard let accessToken = IDKit.latestAccessToken() else {
            completion(nil, .invalidSession)
            return
        }

        var request = URLRequest(url: url, withTracingId: true)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: HttpHeaderFields.authorization.rawValue)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                completion(nil, .other(error))
                return
            }

            guard let response = response as? HTTPURLResponse else {
                completion(nil, .invalidHTTPURLResponse(url))
                return
            }

            let statusCode = response.statusCode

            if statusCode >= 400 {
                if statusCode == HttpStatusCode.unauthorized.rawValue
                    && currentNumberOfRetries < 1
                    && IDKit.isSessionAvailable {
                    IDKit.apiInducedRefresh { [weak self] isSuccessful in
                        guard isSuccessful else {
                            completion(nil, .statusCode(response.statusCode))
                            return
                        }
                        self?.performHTTPRequest(for: url, type: type, currentNumberOfRetries: currentNumberOfRetries + 1, completion: completion)
                    }
                } else {
                    completion(nil, .statusCode(response.statusCode))
                }
            } else {
                self.handleResponseData(for: url,
                                        data: data,
                                        type: type,
                                        completion: completion)
            }
        }.resume()
    }

    func handleResponseData<T: Decodable>(for url: URL, data: Data?, type: T.Type, completion: @escaping ((T?, IDKitError?) -> Void)) {
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
    }
}
