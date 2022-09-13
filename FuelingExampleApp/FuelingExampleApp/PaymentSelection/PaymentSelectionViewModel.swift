//
//  PaymentSelectionViewModel.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK

protocol PaymentSelectionViewModel {
    var fuelingProcess: FuelingProcess { get }
    var paymentMethods: LiveData<[[PCFuelingPaymentMethod]]> { get }

    init(fuelingProcess: FuelingProcess)
    func selectPaymentMethod(paymentMethod: PCFuelingPaymentMethod)
}

class PaymentSelectionViewModelImplementation: PaymentSelectionViewModel {
    private(set) var fuelingProcess: FuelingProcess
    private(set) var paymentMethods: LiveData<[[PCFuelingPaymentMethod]]> = LiveData()

    required init(fuelingProcess: FuelingProcess) {
        self.fuelingProcess = fuelingProcess

        var paymentMethods: [[PCFuelingPaymentMethod]] = [fuelingProcess.supportedPaymentMethods]

        if !fuelingProcess.unsupportedPaymentMethods.isEmpty {
            paymentMethods.append(fuelingProcess.unsupportedPaymentMethods)
        }

        self.paymentMethods.value = paymentMethods

        fuelingProcess.resetPaymentMethodInformation()
    }

    func selectPaymentMethod(paymentMethod: PCFuelingPaymentMethod) {
        fuelingProcess.selectedPaymentMethod = paymentMethod
    }
}
