//
//  Application.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import UIKit

class Application {
    static var shared: UIApplication {
        let sharedSelector = NSSelectorFromString("sharedApplication")

        guard UIApplication.responds(to: sharedSelector) else { fatalError("Extensions cannot access sharedApplication object") }
        guard let shared = UIApplication.perform(sharedSelector)?.takeUnretainedValue() as? UIApplication else { fatalError() }

        return shared
    }
}
