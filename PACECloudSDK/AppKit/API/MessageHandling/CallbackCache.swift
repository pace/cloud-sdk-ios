//
//  CallbackCache.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class CallbackCache {
    enum Callback {
        case tokenInvalid
        case verifyLocation
    }

    private var callbackItems: [Callback: [String]] = [:]
    private let callbackCacheQueue: DispatchQueue = .init(label: "callbackCache", qos: .utility)

    func handle<T, U>(callbackName: Callback,
                      requestId: String,
                      responseHandler: @escaping (String, U) -> Void,
                      responseValueHandler: @escaping (T) -> U,
                      notifyClientHandler: @escaping (@escaping (T) -> Void) -> Void) {

        callbackCacheQueue.async { [weak self] in
            let callback: (T) -> Void = { [weak self] value in
                let responseValue = responseValueHandler(value)
                self?.resolveCallbacks(for: callbackName, responseValue: responseValue, responseBlock: responseHandler)
            }

            if self?.callbackItems[callbackName] == nil {
                self?.callbackItems[callbackName] = [requestId]
                notifyClientHandler(callback)
            } else {
                self?.callbackItems[callbackName]?.append(requestId)
            }

            AppKitLogger.i("[CallbackCache] Enqueuing callback for request with id \(requestId).")
        }
    }

    private func resolveCallbacks<T>(for name: Callback, responseValue: T, responseBlock: @escaping (String, T) -> Void) {
        callbackCacheQueue.async { [weak self] in
            let callbacks = self?.callbackItems[name]

            callbacks?.forEach { requestId in
                responseBlock(requestId, responseValue)
                AppKitLogger.i("[CallbackCache] Resolving callback for request with id \(requestId).")
            }

            // Reset cache for this callback
            self?.callbackItems[name] = nil
        }
    }
}
