//
//  InterfaceController.swift
//  WatchSDKExample Extension
//
//  Created by PACE Telematics GmbH.
//

import WatchKit
import Foundation
import PACECloudWatchSDK

class InterfaceController: WKInterfaceController {

    var api: WatchAPI?

    @IBAction func testSDKButton() {
        guard let api = api else { return }
        print("test")
        api.approaching()
    }

    override func awake(withContext context: Any?) {
        api = WatchAPI()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

}
