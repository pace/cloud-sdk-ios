//
//  ListViewModel.swift
//  PACECloudSDKExample
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation
import PACECloudSDK

protocol ListViewModel: ObservableObject {
    var cofuStations: [ListGasStation] { get }
    var didFail: Bool { get }
    var isLoading: Bool { get }
    var cofuStationRadius: CLLocationDistance { get set }
    func fetchCofuStations()
}
