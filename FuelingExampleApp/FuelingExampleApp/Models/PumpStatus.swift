//
//  PumpStatus.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import PACECloudSDK

enum PumpStatus: String {
    case free
    case inUse
    case readyToPay
    case locked
    case inTransaction
    case outOfOrder

    var lastFuelingStatus: FuelingAPI.Fueling.WaitOnPumpStatusChange.PCFuelingLastStatus {
        switch self {
        case .free:
            return .free

        case .inUse:
            return .inUse

        case .readyToPay:
            return .readyToPay

        case .locked:
            return .locked

        case .inTransaction:
            return .inTransaction

        case .outOfOrder:
            return .outOfOrder
        }
    }

    var titleText: String {
        switch self {
        case .free:
            return "The pump is ready"

        case .inUse:
            return "Fueling in progress ..."

        case .inTransaction:
            return "This pump is currently in use"

        case .outOfOrder:
            return "Out of order"

        default:
            return ""
        }
    }

    var descriptionText: String {
        switch self {
        case .free:
            return "You can refuel now"

        case .inUse:
            return "When you have finished filling up, put the fuel nozzle back to proceed"

        case .outOfOrder:
            return "Sorry, you currently can’t pay with Connected Fueling at this pump. Please pay at checkout."

        default:
            return ""
        }
    }
}
