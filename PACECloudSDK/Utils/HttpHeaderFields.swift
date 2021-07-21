//
//  HttpHeaderFields.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

public enum HttpHeaderFields: String {
    case userAgent = "User-Agent"
    case accept = "Accept"
    case contentType = "Content-Type"
    case ifNoneMatch = "If-None-Match"
    case etag = "Etag"
    case expires = "Expires"
    case location = "Location"
    case lastModified = "Last-Modified"
    case date = "Date"
    case authorization = "Authorization"
    case noCache = "No-Cache"
    case apiKey = "API-Key"
    case acceptLanguage = "Accept-Language"
    case keepAlive = "Keep-Alive"
}
