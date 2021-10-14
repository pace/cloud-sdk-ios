//
//  CmsAPIClient.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

/// Manages and sends APIRequests
public class CmsAPIClient {

    public static var `default` = CmsAPIClient(baseURL: "https://api.pace.cloud/cms")

    /// The base url prepended before every request path
    public var baseURL: String

    /// The UrlSession used for each request
    public var session: URLSession

    /// These headers will get added to every request
    public var defaultHeaders: [String: String] = [:]

    private let cmsDispatchQueue: DispatchQueue = .init(label: "cms", qos: .utility)

    public init(baseURL: String, configuration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
    }

    public func paymentMethodVendors(completion: @escaping (Result<[PaymentMethodVendor], APIClientError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/payment-method-vendors") else {
            completion(.failure(.requestEncodingError(APIRequestError.encodingURL)))
            return
        }

        let request = URLRequest(url: url)
        performRequest(with: request, completion: completion)
    }

    public func paymentMethodVendorIcons(for paymentMethodKinds: PCPayPaymentMethodKinds,
                                         completion: @escaping (PaymentMethodVendorIcons) -> Void) {
        cmsDispatchQueue.async {
            let vendors = paymentMethodKinds.compactMap { $0.attributes?.vendors }.flatMap { $0 }
            var icons: PaymentMethodVendorIcons = []

            let vendorDispatchGroup = DispatchGroup()
            for vendor in vendors {
                vendorDispatchGroup.enter()

                guard let vendorId = vendor.id,
                      let paymentMethodKindId = vendor.paymentMethodKindId,
                      let slug = vendor.slug else {
                    vendorDispatchGroup.leave()
                    continue
                }

                var iconLightData: Data?
                var iconDarkData: Data?
                let iconDispatchGroup = DispatchGroup()

                if let iconLightUrl = vendor.logo?.href {
                    iconDispatchGroup.enter()
                    self.performIconRequest(urlString: iconLightUrl) { iconData in
                        iconLightData = iconData
                        iconDispatchGroup.leave()
                    }
                }

                if let iconDarkUrl = vendor.logo?.variants?.first?.href {
                    iconDispatchGroup.enter()
                    self.performIconRequest(urlString: iconDarkUrl) { iconData in
                        iconDarkData = iconData
                        iconDispatchGroup.leave()
                    }
                }

                iconDispatchGroup.notify(queue: self.cmsDispatchQueue) {
                    guard let iconLightData = iconLightData else {
                        vendorDispatchGroup.leave()
                        return
                    }

                    let icon = PaymentMethodVendorIcon(vendorId: vendorId,
                                                       paymentMethodKindId: paymentMethodKindId,
                                                       slug: slug,
                                                       iconLight: iconLightData,
                                                       iconDark: iconDarkData)
                    icons.append(icon)
                    vendorDispatchGroup.leave()
                }
            }

            vendorDispatchGroup.notify(queue: .main) {
                completion(icons)
            }
        }
    }

    private func performIconRequest(urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: baseURL.dropLast("/cms".count) + urlString) else {
            completion(nil)
            return
        }

        let request = URLRequest(url: url)
        performDataTask(for: request) { result in
            var data: Data?

            if case .success(let iconData) = result {
                data = iconData
            }

            completion(data)
        }
    }

    private func performRequest<T: Decodable>(with request: URLRequest, completion: @escaping (Result<T, APIClientError>) -> Void) {
        performDataTask(for: request) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                let decodedDataResult: Result<T, APIClientError> = self.decodeDataResponse(data: data)
                completion(decodedDataResult)

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func performDataTask(for request: URLRequest, completion: @escaping (Result<Data, APIClientError>) -> Void) {
        var requestWithHeaders = request

        for (key, value) in defaultHeaders {
            requestWithHeaders.setValue(value, forHTTPHeaderField: key)
        }

        self.session.dataTask(with: requestWithHeaders) { data, response, error -> Void in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let response = response as? HTTPURLResponse,
                  let data = data else {
                      completion(.failure(.networkError(URLRequestError.responseInvalid)))
                      return
                  }

            guard response.statusCode < HttpStatusCode.badRequest.rawValue else {
                completion(.failure(.unexpectedStatusCode(statusCode: response.statusCode, data: data)))
                return
            }

            completion(.success(data))
        }.resume()
    }

    private func decodeDataResponse<T: Decodable>(data: Data) -> Result<T, APIClientError> {
        do {
            let jsonResult = try JSONDecoder().decode(T.self, from: data)
            return .success(jsonResult)
        } catch {
            return .failure(.unknownError(error))
        }
    }
}
