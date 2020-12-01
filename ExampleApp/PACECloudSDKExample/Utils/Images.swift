//
//  Images.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import UIKit

enum Images: String {
    case tabBarList = "list"
    case tabBarListActive = "list_active"
    case tabBarFueling = "fueling"
    case tabBarFuelingActive = "fueling_active"
    case tabBarAccount = "account"
    case tabBarAccountActive = "account_active"

    var image: UIImage? {
        UIImage(named: self.rawValue)?.withRenderingMode(.alwaysTemplate)
    }
}
