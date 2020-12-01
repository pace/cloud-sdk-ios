//
//  AppEvent.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

public extension AppKit {
    enum AppEvent: Equatable {
        case paymentMethodsChanged
        case escapedForecourt(uuid: String)
        case turnedOnEngine
        case paymentOverlayVisible

        var stringValue: String {
            switch self {
            case .paymentMethodsChanged:
                return "PaymentMethodsChanged"

            case .escapedForecourt:
                return "EscapedForecourt"

            case .turnedOnEngine:
                return "TurnedOnEngine"

            case .paymentOverlayVisible:
                return "PaymentOverlayVisible"
            }
        }
    }
}
