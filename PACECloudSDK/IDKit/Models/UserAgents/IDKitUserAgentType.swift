//
//  IDKitUserAgentType.swift
//  PACECloudSDK
//
//  Created by Patrick Niepel on 14.02.22.
//

import Foundation

public extension IDKit {
    enum UserAgentType {
        /// Uses the SFSafariViewController / SFAuthenticationSession to handle the authorization flow.
        /// Only available with iOS 13 and above.
        case external

        /// Uses an internal WKWebView to handle the authorization flow.
        case integrated
    }
}
