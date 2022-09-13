//
//  SelectPumpViewModel.swift
//  PACECloudSDKFueling
//
//  Created by Philipp Knoblauch on 28.06.22.
//

import Foundation

protocol AutorizePaymentViewModel: AnyObject {
    var selectedPump: Int { get }
    var gasStation: GasStation { get }
}

class AutorizePaymentViewModelImplementation: AutorizePaymentViewModel {
    var gasStation: GasStation

    var selectedPump: Int

    init(gasStation: GasStation, selectedPump: Int) {
        self.gasStation = gasStation
        self.selectedPump = selectedPump
    }
}
