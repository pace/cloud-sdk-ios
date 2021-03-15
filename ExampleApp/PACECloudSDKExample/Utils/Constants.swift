//
//  Constants.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import Foundation

struct Constants {
    struct URLs {
        static var fuelingUrl: String {
            #if PRODUCTION
            return "https://fuel.site"
            #elseif STAGE
            return "https://fueling.stage.pace.cloud"
            #elseif SANDBOX
            return "https://fueling.sandbox.pace.cloud"
            #else
            return "https://fueling.dev.pace.cloud"
            #endif
        }

        static var paymentUrl: String {
            #if PRODUCTION
            return "https://pay.pace.cloud"
            #elseif STAGE
            return "https://pay.stage.pace.cloud"
            #elseif SANDBOX
            return "https://pay.sandbox.pace.cloud"
            #else
            return "https://pay.dev.pace.cloud"
            #endif
        }
    }
}
