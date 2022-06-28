//
//  PumpSelectionViewModel.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK

protocol PumpSelectionViewModel {
    var fuelingProcess: FuelingProcess { get }
    var pumps: LiveData<[PCFuelingPump]> { get }
    var isLoading: LiveData<Bool> { get }
    var errorMessage: LiveData<String> { get }
    var showPumpStatus: LiveData<Bool> { get }
    var showAmountSelection: LiveData<Bool> { get }
    var showPaymentSummary: LiveData<Bool> { get }

    var postPayPumpInformation: PCFuelingPumpResponse? { get }
    var postPayPumpStatus: PumpStatus? { get }

    init(fuelingProcess: FuelingProcess)
    func selectPump(pump: PCFuelingPump)
}

class PumpSelectionViewModelImplementation: PumpSelectionViewModel {
    private(set) var fuelingProcess: FuelingProcess
    private(set) var pumps: LiveData<[PCFuelingPump]> = .init()
    private(set) var isLoading: LiveData<Bool> = .init(value: false)
    private(set) var errorMessage: LiveData<String> = .init()
    private(set) var showPumpStatus: LiveData<Bool> = .init(value: false)
    private(set) var showAmountSelection: LiveData<Bool> = .init(value: false)
    private(set) var showPaymentSummary: LiveData<Bool> = .init(value: false)

    private(set) var postPayPumpInformation: PCFuelingPumpResponse?
    private(set) var postPayPumpStatus: PumpStatus?

    required init(fuelingProcess: FuelingProcess) {
        self.fuelingProcess = fuelingProcess
        self.pumps.value = fuelingProcess.pumps.sorted(by: { lhs, rhs in
            guard let lhsIdentifier = lhs.identifier, let rhsIdentifier = rhs.identifier else { return false }
            return lhsIdentifier.compare(rhsIdentifier, options: .numeric) == .orderedAscending
        })

        fuelingProcess.resetPumpInformation()
    }

    func selectPump(pump: PCFuelingPump) {
        checkPump(pump: pump)
    }

    private func checkPump(pump: PCFuelingPump) {
        guard let pumpId = pump.id else {
            showPumpError(message: Constants.genericErrorMessage)
            return
        }

        let stationId = fuelingProcess.gasStation.id
        let request = FuelingAPI.Fueling.GetPump.Request(gasStationId: stationId, pumpId: pumpId)

        isLoading.value = true
        APIHelper.makeFuelingRequest(request) { [weak self] response in
            defer {
                self?.isLoading.value = false
            }

            switch response.result {
            case .success(let result):
                guard result.successful,
                      let pumpResponse = result.success?.data,
                      let responsePumpStatus = pumpResponse.status,
                      let pumpStatus = PumpStatus(rawValue: responsePumpStatus.rawValue) else {
                          NSLog("[PumpSelectionViewModelImplementation] Failed pump at station \(stationId): Invalid response data.  Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                          self?.showPumpError(message: Constants.genericErrorMessage)
                          return
                      }

                if pumpStatus == .outOfOrder {
                    self?.showPumpError(message: PumpStatus.outOfOrder.titleText)
                } else {
                    self?.fuelingProcess.selectedPump = pump
                    self?.determineFuelingProcess(pumpInformation: pumpResponse, pumpStatus: pumpStatus)
                }

            case .failure(let error):
                if case .networkError(let error) = error {
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        return
                    } else {
                        self?.showPumpError(message: Constants.networkErrorMessage)
                    }
                } else {
                    self?.showPumpError(message: Constants.genericErrorMessage)
                    NSLog("[PumpSelectionViewModelImplementation] Failed pump with error \(error) at station \(stationId). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                }
            }
        }
    }

    private func determineFuelingProcess(pumpInformation: PCFuelingPumpResponse, pumpStatus: PumpStatus) {
        if fuelingProcess.didAuthorizePreAuthAmount {
            showPumpStatus.value = true
        } else if fuelingProcess.isPreAuth {
            if pumpStatus == .free || pumpStatus == .inUse {
                showPumpError(message: PumpStatus.inTransaction.titleText)
            } else {
                showAmountSelection.value = true
            }
        } else if fuelingProcess.isPostPay {
            if pumpStatus == .readyToPay { // Skip pump status if the pump is already in readyToPay
                fuelingProcess.pumpInformation = pumpInformation
                showPaymentSummary.value = true
            } else {
                postPayPumpInformation = pumpInformation
                postPayPumpStatus = pumpStatus
                showPumpStatus.value = true
            }
        }
    }

    private func showPumpError(message: String) {
        errorMessage.value = message
    }
}
