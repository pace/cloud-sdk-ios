//
//  AmountSelectionViewModel.swift
//  FuelingExampleApp
//
//  Created by PACE Telematics GmbH.
//

import Foundation

protocol AmountSelectionViewModel: AnyObject {
    var fuelingProcess: FuelingProcess { get }
    var errorMessage: LiveData<String> { get }

    init(fuelingProcess: FuelingProcess)
    func didEnterAmount(_ amountString: String)
}

class AmountSelectionViewModelImplementation: AmountSelectionViewModel {
    private(set) var fuelingProcess: FuelingProcess
    private(set) var errorMessage: LiveData<String> = .init()

    required init(fuelingProcess: FuelingProcess) {
        self.fuelingProcess = fuelingProcess
    }

    func didEnterAmount(_ amountString: String) {
        guard let amountInt = Int(amountString) else {
            errorMessage.value = "Please enter a valid amount."
            return
        }

        fuelingProcess.amount = Decimal(amountInt)
    }
}
