//
//  CookieStorage.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import WebKit

public extension AppKit {
    struct CookieStorage {
        static let cookiesKey = "WebViewCookies"

        public static var sharedSessionCookies: [HTTPCookie] = retrieveCookies()

        public static func saveCookies(_ cookies: [HTTPCookie]) {
            var cookiesDict: [String: Any] = [:]

            cookies.forEach {
                cookiesDict[$0.name] = $0.properties
            }

            SDKUserDefaults.set(cookiesDict, for: cookiesKey, isUserSensitiveData: false)
        }

        public static func retrieveCookies() -> [HTTPCookie] {
            guard let cookiesDict = SDKUserDefaults.dictionary(for: cookiesKey, isUserSensitiveData: false) else { return [] }

            var cookies: [HTTPCookie] = []

            for (_, properties) in cookiesDict {
                guard let properties = properties as? [HTTPCookiePropertyKey: Any],
                      let cookie = HTTPCookie(properties: properties) else { continue }

                cookies.append(cookie)
            }

            return cookies
        }
    }
}
