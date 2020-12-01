//
//  JsonRpcErrorObjects.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

struct ErrorObject: Codable {
    let code: Int
    let message: String
    let data: EmptyJSONObject
}

struct EmptyJSONObject: Codable {}

struct JsonRpcErrorObject {
    let code: Int
    let message: String
}

/// JSON RPC error objects as defined in https://www.jsonrpc.org/specification#error_object
struct JsonRpcErrorObjects {

    /// The JSON sent is not a valid Request object.
    static let invalidRequest = JsonRpcErrorObject(code: -32600, message: "Invalid Request")

    /// The method does not exist / is not available.
    static let methodNotFound = JsonRpcErrorObject(code: -32601, message: "Method not found")
}
