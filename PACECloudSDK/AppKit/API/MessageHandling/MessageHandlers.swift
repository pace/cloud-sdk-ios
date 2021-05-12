//
//  MessageHandlers.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

enum MessageHandler: String, CaseIterable {
    case close = "pace_close"
    case getBiometricStatus = "pace_getBiometricStatus"
    case setTOTPSecret = "pace_setTOTPSecret"
    case getTOTP = "pace_getTOTP"
    case setSecureData = "pace_setSecureData"
    case getSecureData = "pace_getSecureData"
    case disable = "pace_disable"
    case openURLInNewTab = "pace_openURLInNewTab"
    case getAccessToken = "pace_getAccessToken"
    case logout = "pace_logout"
    case imageData = "pace_imageData"
    case applePayAvailabilityCheck = "pace_applePayAvailabilityCheck"
    case applePayRequest = "pace_applePayRequest"
    case verifyLocation = "pace_verifyLocation"
    case logger = "pace_logger"
    case back = "pace_back"
    case redirectScheme = "pace_getAppInterceptableLink"
    case setUserProperty = "pace_setUserProperty"
    case logEvent = "pace_logEvent"
    case getConfig = "pace_getConfig"
    case getTraceId = "pace_getTraceId"

    var timeout: TimeInterval {
        switch self {
        case .close, .getBiometricStatus, .setSecureData, .disable, .openURLInNewTab, .imageData, .applePayAvailabilityCheck,
             .logger, .back, .redirectScheme, .setUserProperty, .logEvent, .getTraceId:
            return 5

        case .setTOTPSecret, .getTOTP, .getSecureData:
            return 120

        case .verifyLocation, .getConfig, .getAccessToken:
            return 60

        case .applePayRequest:
            return 300

        case .logout:
            return 30
        }
    }
}
