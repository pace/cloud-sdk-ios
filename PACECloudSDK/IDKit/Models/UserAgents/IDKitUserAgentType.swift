//
//  IDKitUserAgentType.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
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
