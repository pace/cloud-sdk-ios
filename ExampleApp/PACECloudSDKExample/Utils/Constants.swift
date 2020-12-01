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
            return "https://payment-app.prod.k8s.pacelink.net"
            #elseif STAGE
            return "https://payment-app.stage.k8s.pacelink.net"
            #elseif SANDBOX
            return "https://payment-app.sandbox.k8s.pacelink.net"
            #else
            return "https://payment-app.dev.k8s.pacelink.net"
            #endif
        }
    }
}
