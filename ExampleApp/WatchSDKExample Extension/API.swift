//
//  API.swift
//  WatchSDKExample Extension
//
//  Created by PACE Telematics GmbH.
//

import PACECloudWatchSDK

public struct WatchAPI {
    func approaching() {
        let request = FuelingAPI.Fueling.ApproachingAtTheForecourt.Request(gasStationId: "e3211b77-03f0-4d49-83aa-4adaa46d95ae")

        API.Fueling.client.makeRequest(request) { response in
            switch response.result {
            case .success(let x):
                print(x)

            case .failure(let error):
                print(error)
            }
        }
    }
}
