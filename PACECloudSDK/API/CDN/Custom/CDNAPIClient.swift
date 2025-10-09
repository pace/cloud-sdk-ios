//
//  CDNAPIClient.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

/// Manages and sends APIRequests
public class CDNAPIClient {

    public static var `default` = CDNAPIClient(baseURL: "https://cdn.pace.cloud")

    /// The base url prepended before every request path
    public var baseURL: String

    /// The UrlSession used for each request
    public var session: URLSession

    /// These headers will get added to every request
    public var defaultHeaders: [String: String] = [:]

    private let cdnDispatchQueue: DispatchQueue = .init(label: "cdn", qos: .utility)

    public init(baseURL: String, configuration: URLSessionConfiguration = .default) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: configuration)
    }

    public func paymentMethodVendors(completion: @escaping (Result<[PaymentMethodVendor], APIClientError>) -> Void) {
        guard let url = URL(string: "\(baseURL)\(Constants.cdnPayPath)/payment-method-vendors.json"),
              let utmUrl = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: url) else {
            completion(.failure(.requestEncodingError(APIRequestError.encodingURL)))
            return
        }

        let request = URLRequest(url: utmUrl)
        performRequest(with: request) { (result: Result<[PaymentMethodVendorResponse], APIClientError>) in
            switch result {
            case .success(let paymentMethodVendorDTOs):
                let mappedPaymentMethodVendors: [PaymentMethodVendor] = paymentMethodVendorDTOs.map { .init(from: $0) }
                completion(.success(mappedPaymentMethodVendors))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    public func paymentMethodVendorIcons(for paymentMethodKinds: PCPayPaymentMethodKinds,
                                         completion: @escaping (PaymentMethodVendorIcons) -> Void) {
        let apiVendors = paymentMethodKinds.compactMap { $0.vendors }.flatMap { $0 }
        let paymentMethodVendors: PaymentMethodVendors = apiVendors.map {
            PaymentMethodVendorResponse(id: $0.id,
                                        slug: $0.slug,
                                        name: $0.name,
                                        logo: .init(href: $0.logo?.href, variants: .init(dark: .init(href: $0.logo?.variants?.first?.href))),
                                        paymentMethodKindId: $0.paymentMethodKindId)
        }.map { .init(from: $0) }

        paymentMethodVendorIcons(for: paymentMethodVendors, completion: completion)
    }

    public func paymentMethodVendorIcons(for paymentMethodVendors: PaymentMethodVendors,
                                         completion: @escaping (PaymentMethodVendorIcons) -> Void) {
        cdnDispatchQueue.async {
            var icons: PaymentMethodVendorIcons = []

            let vendorDispatchGroup = DispatchGroup()
            for vendor in paymentMethodVendors {
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

                iconDispatchGroup.enter()
                iconDispatchGroup.enter()

                if let iconLightUrl = vendor.logo?.href {
                    self.performIconRequest(urlString: iconLightUrl) { iconData in
                        iconLightData = iconData
                        iconDispatchGroup.leave()
                    }
                } else {
                    iconDispatchGroup.leave()
                }

                if let iconDarkUrl = vendor.logo?.variants?.dark?.href {
                    self.performIconRequest(urlString: iconDarkUrl) { iconData in
                        iconDarkData = iconData
                        iconDispatchGroup.leave()
                    }
                } else {
                    iconDispatchGroup.leave()
                }

                iconDispatchGroup.notify(queue: self.cdnDispatchQueue) {
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
        guard let url = URL(string: urlString),
              let utmUrl = PACECloudSDK.QueryParamUTMHandler.buildUrl(for: url) else {
            completion(nil)
            return
        }

        let request = URLRequest(url: utmUrl)
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

        self.session.dataTask(with: requestWithHeaders) { data, response, error in
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

@MainActor
public extension CDNAPIClient {
    func paymentMethodVendors() async -> Result<[PaymentMethodVendor], APIClientError> {
        await withCheckedContinuation { [weak self] continuation in
            self?.paymentMethodVendors { result in
                continuation.resume(returning: result)
            }
        }
    }

    func paymentMethodVendorIcons(for paymentMethodKinds: PCPayPaymentMethodKinds) async -> PaymentMethodVendorIcons {
        await withCheckedContinuation { [weak self] continuation in
            self?.paymentMethodVendorIcons(for: paymentMethodKinds) { icons in
                continuation.resume(returning: icons)
            }
        }
    }

    func paymentMethodVendorIcons(for paymentMethodVendors: PaymentMethodVendors) async -> PaymentMethodVendorIcons {
        await withCheckedContinuation { [weak self] continuation in
            self?.paymentMethodVendorIcons(for: paymentMethodVendors) { icons in
                continuation.resume(returning: icons)
            }
        }
    }
}
