//
// Generated by SwagGen
// https://github.com/pace/SwagGen
//

import Foundation

public protocol PayAPIRequestBehaviour {

    /// runs first and allows the requests to be modified. If modifying asynchronously use validate
    func modifyRequest(request: AnyPayAPIRequest, urlRequest: URLRequest) -> URLRequest

    /// validates and modifies the request. complete must be called with either .success or .fail
    func validate(request: AnyPayAPIRequest, urlRequest: URLRequest, complete: @escaping (RequestValidationResult) -> Void)

    /// called before request is sent
    func beforeSend(request: AnyPayAPIRequest)

    /// called when request successfuly returns a 200 range response
    func onSuccess(request: AnyPayAPIRequest, result: Any)

    /// called when request fails with an error. This will not be called if the request returns a known response even if the a status code is out of the 200 range
    func onFailure(request: AnyPayAPIRequest, error: APIClientError)

    /// called if the request recieves a network response. This is not called if request fails validation or encoding
    func onResponse(request: AnyPayAPIRequest, response: AnyPayAPIResponse)
}

// Provides empty defaults so that each function becomes optional
public extension PayAPIRequestBehaviour {
    func modifyRequest(request: AnyPayAPIRequest, urlRequest: URLRequest) -> URLRequest { return urlRequest }
    func validate(request: AnyPayAPIRequest, urlRequest: URLRequest, complete: @escaping (RequestValidationResult) -> Void) {
        complete(.success(urlRequest))
    }
    func beforeSend(request: AnyPayAPIRequest) {}
    func onSuccess(request: AnyPayAPIRequest, result: Any) {}
    func onFailure(request: AnyPayAPIRequest, error: APIClientError) {}
    func onResponse(request: AnyPayAPIRequest, response: AnyPayAPIResponse) {}
}

// Group different RequestBehaviours together
struct PayAPIRequestBehaviourGroup {

    let request: AnyPayAPIRequest
    let behaviours: [PayAPIRequestBehaviour]

    init<T>(request: PayAPIRequest<T>, behaviours: [PayAPIRequestBehaviour]) {
        self.request = request.asAny()
        self.behaviours = behaviours
    }

    func beforeSend() {
        behaviours.forEach {
            $0.beforeSend(request: request)
        }
    }

    func validate(_ urlRequest: URLRequest, complete: @escaping (RequestValidationResult) -> Void) {
        if behaviours.isEmpty {
            complete(.success(urlRequest))
            return
        }

        var count = 0
        var modifiedRequest = urlRequest
        func validateNext() {
            let behaviour = behaviours[count]
            behaviour.validate(request: request, urlRequest: modifiedRequest) { result in
                count += 1
                switch result {
                case .success(let urlRequest):
                    modifiedRequest = urlRequest
                    if count == self.behaviours.count {
                        complete(.success(modifiedRequest))
                    } else {
                        validateNext()
                    }
                case .failure(let error):
                    complete(.failure(error))
                }
            }
        }
        validateNext()
    }

    func onSuccess(result: Any) {
        behaviours.forEach {
            $0.onSuccess(request: request, result: result)
        }
    }

    func onFailure(error: APIClientError) {
        behaviours.forEach {
            $0.onFailure(request: request, error: error)
        }
    }

    func onResponse(response: AnyPayAPIResponse) {
        behaviours.forEach {
            $0.onResponse(request: request, response: response)
        }
    }

    func modifyRequest(_ urlRequest: URLRequest) -> URLRequest {
        guard let oldUrl = urlRequest.url else { return urlRequest }

        var newRequest = urlRequest
        behaviours.forEach {
            newRequest = $0.modifyRequest(request: request, urlRequest: urlRequest)
        }

        newRequest.url = QueryParamHandler.buildUrl(for: oldUrl)
        newRequest.setValue(Constants.Tracing.identifier, forHTTPHeaderField: Constants.Tracing.key)

        return newRequest
    }
}

extension PayAPIService {
    public func asAny() -> PayAPIService<AnyResponseValue> {
        return PayAPIService<AnyResponseValue>(id: id, tag: tag, method: method, path: path, hasBody: hasBody, securityRequirements: securityRequirements)
    }
}
