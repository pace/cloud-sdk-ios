//
//  RequestTimeoutHandler.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class RequestTimeoutHandler {
    private var requestTimerItems: [String: Timer] = [:]
    private let requestTimeoutQueue: DispatchQueue = .init(label: "requestTimeoutQueue", qos: .utility)

    func scheduleTimer(for requestId: String,
                       timeout: TimeInterval,
                       messageInterceptor: AppWebViewMessageInterceptor?,
                       requestHandler: @escaping (_ completion: @escaping () -> Void) -> Void) {

        DispatchQueue.main.async { [weak self] in
            let timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                messageInterceptor?.send(id: requestId, error: .requestTimeout)
                AppKitLogger.i("[RequestTimeoutHandler] Timeout for request with id \(requestId)")
                self?.stopTimer(for: requestId)
            }

            self?.addTimer(timer, for: requestId)

            requestHandler { [weak self] in
                self?.stopTimer(for: requestId)
            }
        }
    }

    private func addTimer(_ timer: Timer, for requestId: String) {
        requestTimeoutQueue.async { [weak self] in
            self?.requestTimerItems[requestId] = timer
            AppKitLogger.i("[RequestTimeoutHandler] Starting timer for request with id \(requestId)")
        }
    }

    private func stopTimer(for requestId: String) {
        requestTimeoutQueue.async { [weak self] in
            let requestTimer = self?.requestTimerItems[requestId]
            requestTimer?.invalidate()
            self?.requestTimerItems[requestId] = nil
            AppKitLogger.i("[RequestTimeoutHandler] Stopping timer for request with id \(requestId)")
        }
    }
}
