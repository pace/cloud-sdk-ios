//
//  Constants.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import Foundation

struct Constants {
    struct URLs {
        static var simulatorUrl: String {
            "https://pwa-simulator.dev.pace.cloud"
        }

        static var fuelingUrl: String {
            #if PRODUCTION
            return "https://fuel.site"
            #elseif STAGE
            return "https://stage.fuel.site"
            #elseif SANDBOX
            return "https://sandbox.fuel.site"
            #else
            return "https://dev.fuel.site"
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

    static var paceIDHost: String {
        #if PRODUCTION
        return "id.pace.cloud"
        #elseif STAGE
        return "id.stage.pace.cloud"
        #elseif SANDBOX
        return "id.sandbox.pace.cloud"
        #else
        return "id.dev.pace.cloud"
        #endif
    }
}
