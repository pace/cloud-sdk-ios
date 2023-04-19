//
//  RequestTimeoutHandler.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

protocol RequestTimeoutHandlerDelegate: AnyObject {
    func didReachTimeout(_ requestId: String, with replyHandler: ReplyHandler?)
}

class RequestTimeoutHandler {
    weak var delegate: RequestTimeoutHandlerDelegate?
    private var requestTimerItems: [String: Timer] = [:]
    private let requestTimeoutQueue: DispatchQueue = .init(label: "requestTimeoutQueue", qos: .utility)

    func scheduleTimer(with requestId: String,
                       timeout: TimeInterval,
                       operation: API.Communication.Operation,
                       completion: @escaping () -> Void,
                       with replyHandler: ReplyHandler?) {
        DispatchQueue.main.async { [weak self] in
            let timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
                AppKitLogger.d("[RequestTimeoutHandler] Timeout for request with id \(requestId) - \(operation.rawValue)")
                self?.removeTimer(for: requestId)
                self?.delegate?.didReachTimeout(requestId, with: replyHandler)
            }

            self?.addTimer(timer, for: requestId, operation: operation)
            completion()
        }
    }

    func stopTimer(with requestId: String, operation: API.Communication.Operation?) {
        requestTimeoutQueue.async { [weak self] in
            if let timer = self?.requestTimerItems[requestId] {
                timer.invalidate()
                self?.removeTimer(for: requestId)
                AppKitLogger.d("[RequestTimeoutHandler] Stopping timer for request with id \(requestId) - \(operation?.rawValue ?? "no operation available")")
            }
        }
    }

    private func addTimer(_ timer: Timer, for requestId: String, operation: API.Communication.Operation) {
        requestTimeoutQueue.async { [weak self] in
            self?.requestTimerItems[requestId] = timer
            AppKitLogger.d("[RequestTimeoutHandler] Starting timer for request with id \(requestId) - \(operation.rawValue)")
        }
    }

    private func removeTimer(for requestId: String) {
        requestTimeoutQueue.async { [weak self] in
            self?.requestTimerItems[requestId] = nil
        }
    }
}
