//
//  HttpStatusCode.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public enum HttpStatusCode: Int {
    case ok = 200
    case created = 201
    case okNoContent = 204

    case redirect = 302
    case seeOther = 303
    case notModified = 304

    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case requestTimeout = 408
    case rangeNotSatisfiable = 416

    case internalError = 500

    init?(from code: Int?) {
        if let code = code, let httpResponseCode = HttpStatusCode(rawValue: code) {
            self = httpResponseCode
        } else {
            return nil
        }
    }

    var successRange: Range<Int> {
        return 200 ..< 299
    }

    var redirectRange: Range<Int> {
        return 300 ..< 399
    }
    var errorRange: Range<Int> {
        return 400 ..< 999
    }

    public var success: Bool {
        return successRange.contains(self.rawValue)
    }

    public var redirect: Bool {
        return redirectRange.contains(self.rawValue)
    }

    public var error: Bool {
        return errorRange.contains(self.rawValue)
    }
}
