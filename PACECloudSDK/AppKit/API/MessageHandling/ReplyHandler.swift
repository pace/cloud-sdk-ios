//
//  ReplyHandler.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

class ReplyHandler {
    private var replyHandler: ((Any?, String?) -> Void)?

    init(replyHandler: @escaping (Any?, String?) -> Void) {
        self.replyHandler = replyHandler
    }

    func reply(with response: Any?, errorMessage: String?) {
        replyHandler?(response, errorMessage)
        replyHandler = nil
    }
}
