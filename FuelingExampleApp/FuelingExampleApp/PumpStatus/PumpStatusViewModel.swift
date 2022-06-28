//
//  PumpStatusViewModel.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK

protocol PumpStatusViewModel {
    var fuelingProcess: FuelingProcess { get }
    var postPayPumpInformation: PCFuelingPumpResponse? { get }
    var postPayPumpStatus: PumpStatus? { get }

    var status: LiveData<PumpStatus> { get }
    var isLoading: LiveData<Bool> { get }
    var errorMessage: LiveData<String> { get }
    var didFinishPostPay: LiveData<PCFuelingPumpResponse> { get }
    var didFinishPreAuth: LiveData<PaymentSuccessData> { get }
    var showCancelTransactionButton: LiveData<Bool> { get }
    var popBackToPumpSelection: LiveData<Bool> { get }
    var showCancelTransactionSuccess: LiveData<Bool> { get }

    init(fuelingProcess: FuelingProcess,
         postPayPumpInformation: PCFuelingPumpResponse?,
         postPayPumpStatus: PumpStatus?)

    func initiatePumpStatusHandling()
    func cancelTransaction()
    func reset()
}

class PumpStatusViewModelImplementation: PumpStatusViewModel {
    private(set) var fuelingProcess: FuelingProcess
    private(set) var postPayPumpInformation: PCFuelingPumpResponse?
    private(set) var postPayPumpStatus: PumpStatus?

    private(set) var status: LiveData<PumpStatus> = .init()
    private(set) var isLoading: LiveData<Bool> = .init()
    private(set) var errorMessage: LiveData<String> = .init()
    private(set) var didFinishPostPay: LiveData<PCFuelingPumpResponse> = .init()
    private(set) var didFinishPreAuth: LiveData<PaymentSuccessData> = .init()
    private(set) var showCancelTransactionButton: LiveData<Bool> = .init()
    private(set) var popBackToPumpSelection: LiveData<Bool> = .init()
    private(set) var showCancelTransactionSuccess: LiveData<Bool> = .init()

    private var pumpInformationRequest: CancellableFuelingAPIRequest?
    private var waitForPumpStatusRequest: CancellableFuelingAPIRequest?
    private var waitForTransactionRequest: CancellablePayAPIRequest?
    private var cancelTransactionRequest: CancellableFuelingAPIRequest?

    private var currentPumpStatus: PumpStatus? {
        didSet {
            guard let currentPumpStatus = currentPumpStatus else { return }
            status.value = currentPumpStatus
        }
    }

    required init(fuelingProcess: FuelingProcess,
                  postPayPumpInformation: PCFuelingPumpResponse? = nil,
                  postPayPumpStatus: PumpStatus? = nil) {
        self.fuelingProcess = fuelingProcess
        self.postPayPumpInformation = postPayPumpInformation
        self.postPayPumpStatus = postPayPumpStatus
    }

    func initiatePumpStatusHandling() {
        if fuelingProcess.isPostPay, let postPayPumpInformation = postPayPumpInformation, let postPayPumpStatus = postPayPumpStatus {
            handleWaitForPumpStatus(pumpInformation: postPayPumpInformation, newStatus: postPayPumpStatus)
        } else if fuelingProcess.isPreAuth {
            fetchPumpInformation()
        } else {
            showPumpStatusAlert(message: Constants.genericErrorMessage)
        }
    }

    private func fetchPumpInformation() {
        guard let pumpId: String = fuelingProcess.selectedPump?.id else {
            showPumpStatusAlert(message: Constants.genericErrorMessage)
            return
        }

        isLoading.value = true
        let gasStationId = fuelingProcess.gasStation.id
        let request = FuelingAPI.Fueling.GetPump.Request(gasStationId: gasStationId, pumpId: pumpId)
        pumpInformationRequest = APIHelper.makeFuelingRequest(request) { [weak self] response in
            defer {
                self?.isLoading.value = false
            }

            switch response.result {
            case .success(let result):
                guard result.successful,
                      let pumpResponse = result.success?.data,
                      let pumpStatus = pumpResponse.status,
                      let newStatus = PumpStatus(rawValue: pumpStatus.rawValue) else {
                          NSLog("[PumpStatusViewModelImplementation] Failed pump at station \(gasStationId): Invalid response data.  Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                          self?.showPumpStatusAlert(message: Constants.genericErrorMessage)
                          return
                      }

                if self?.fuelingProcess.isPreAuth == true && self?.fuelingProcess.didAuthorizePreAuthAmount == true {
                    self?.showCancelTransactionButton.value = true
                    self?.waitForTransaction()
                }

                self?.handleWaitForPumpStatus(pumpInformation: pumpResponse, newStatus: newStatus)

            case .failure(let error):
                if case .networkError(let error) = error {
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        return
                    } else {
                        self?.showPumpStatusAlert(message: Constants.networkErrorMessage)
                    }
                } else {
                    self?.showPumpStatusAlert(message: Constants.genericErrorMessage)
                }

                NSLog("[PumpStatusViewModelImplementation] Failed pump with error \(error) at station \(gasStationId). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
            }
        }
    }

    private func waitForPumpStatus(lastStatus: PumpStatus) {
        guard let pumpId: String = fuelingProcess.selectedPump?.id else {
            showPumpStatusAlert(message: Constants.genericErrorMessage)
            return
        }

        let gasStationId = fuelingProcess.gasStation.id
        let request = FuelingAPI.Fueling.WaitOnPumpStatusChange.Request.init(gasStationId: gasStationId,
                                                                             pumpId: pumpId,
                                                                             update: .longPolling,
                                                                             lastStatus: lastStatus.lastFuelingStatus,
                                                                             timeout: 60)

        waitForPumpStatusRequest = APIHelper.makeFuelingRequest(request) { [weak self] response in
            switch response.result {
            case .success(let result):
                guard result.successful,
                      let pumpResponse = result.success?.data,
                      let pumpStatus = pumpResponse.status,
                      let newStatus = PumpStatus(rawValue: pumpStatus.rawValue) else {
                          NSLog("[PumpStatusViewModelImplementation] Failed waitForPumpChange at station \(gasStationId): Invalid response data. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                          self?.showPumpStatusAlert(message: Constants.genericErrorMessage)
                          return
                      }

                self?.handleWaitForPumpStatus(pumpInformation: pumpResponse, newStatus: newStatus)

            case .failure(let error):
                if case .networkError(let error) = error {
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        return
                    } else {
                        self?.showPumpStatusAlert(message: Constants.networkErrorMessage)
                    }
                } else {
                    self?.showPumpStatusAlert(message: Constants.genericErrorMessage)
                }

                NSLog("[PumpStatusViewModelImplementation] Failed waitForPumpChange with error \(error) at station \(gasStationId). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
            }
        }
    }

    private func handleWaitForPumpStatus(pumpInformation: PCFuelingPumpResponse, newStatus: PumpStatus) {
        fuelingProcess.isPostPay
        ? handlePostPayPumpStatus(pumpInformation: pumpInformation, newStatus: newStatus)
        : handlePreAuthPumpStatus(pumpInformation: pumpInformation, newStatus: newStatus)
    }

    func reset() {
        pumpInformationRequest?.cancel()
        waitForPumpStatusRequest?.cancel()
        waitForTransactionRequest?.cancel()
        cancelTransactionRequest?.cancel()
    }

    private func showPumpStatusAlert(message: String) {
        errorMessage.value = message
    }

    deinit {
        reset()
    }
}

// MARK: - Post Pay
private extension PumpStatusViewModelImplementation {
    func handlePostPayPumpStatus(pumpInformation: PCFuelingPumpResponse, newStatus: PumpStatus) {
        guard newStatus != .outOfOrder else {
            showPumpStatusAlert(message: PumpStatus.outOfOrder.titleText)
            return
        }

        guard newStatus == .readyToPay else {
            currentPumpStatus = newStatus
            waitForPumpStatus(lastStatus: newStatus)
            return
        }

        didFinishPostPay.value = pumpInformation
    }
}

// MARK: - Pre Auth
extension PumpStatusViewModelImplementation {
    private func handlePreAuthPumpStatus(pumpInformation: PCFuelingPumpResponse, newStatus: PumpStatus) {
        guard newStatus != .outOfOrder else {
            showPumpStatusAlert(message: PumpStatus.outOfOrder.titleText)
            return
        }

        // Go back one screen to pump selection if:
        // - someone else was fueling and completed the process
        if currentPumpStatus == .inTransaction && newStatus == .locked {
            popBackToPumpSelection.value = true
            return
        }

        if newStatus != .free {
            showCancelTransactionButton.value = false
        }

        // Someone else is fueling and not using our system
        // Mapping to -> inTransaction
        if (newStatus == .free || newStatus == .inUse) && !fuelingProcess.didAuthorizePreAuthAmount {
            currentPumpStatus = .inTransaction
        } else {
            currentPumpStatus = newStatus
        }

        // Only trigger another waitForPumpStatus request if:
        // - status is free
        //   -> user authorized an amount but hasn't started fueling yet
        // - status is inTransaction
        //   -> a different user is fueling
        //   -> we want to know when the pump switches back to locked
        if newStatus == .free || newStatus == .inTransaction {
            waitForPumpStatus(lastStatus: newStatus)
        }
    }

    private func waitForTransaction() {
        guard let transactionId = fuelingProcess.transactionId else {
            showPumpStatusAlert(message: Constants.genericErrorMessage)
            return
        }

        let request = PayAPI.PaymentTransactions.GetTransaction.Request(transactionId: transactionId, update: .longPolling)
        waitForTransactionRequest = APIHelper.makePayRequest(request) { [weak self] response in
            switch response.result {
            case .success(let result):
                if result.response as? PayAPI.PaymentTransactions.GetTransaction.Response.Status410 != nil {
                    self?.handleCancelledTransaction()
                    NSLog("[PumpStatusViewModelImplementation] Wait for transaction cancelled: Status code 410. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    return
                }

                if result.response as? PayAPI.PaymentTransactions.GetTransaction.Response.Status404 != nil {
                    self?.waitForTransaction()
                    return
                }

                guard result.successful, let transactionData = result.success?.data else {
                    self?.showPumpStatusAlert(message: Constants.genericErrorMessage)
                    NSLog("[PumpStatusViewModelImplementation] Failed waitForTransaction: Invalid response data. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    return
                }

                self?.handleWaitForTransactionSuccess(transactionData: transactionData)

            case .failure(let error):
                if case .networkError(let error) = error {
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        return
                    } else {
                        self?.showPumpStatusAlert(message: Constants.networkErrorMessage)
                    }
                } else {
                    self?.showPumpStatusAlert(message: Constants.genericErrorMessage)
                }
                NSLog("[PumpStatusViewModelImplementation] Failed waitForTransaction with error \(error). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
            }
        }
    }

    private func handleWaitForTransactionSuccess(transactionData: PCPayTransaction) {
        let priceIncludingVAT = transactionData.priceIncludingVAT ?? 0 // Already discounted amount
        let fuelingAmount = transactionData.fuel?.amount ?? 0
        let productName = transactionData.fuel?.productName ?? ""
        let pricePerUnit = transactionData.fuel?.pricePerUnit
        let discountAmount = transactionData.discountAmount

        var paymentMethod: String?
        if let localizedKind = fuelingProcess.selectedPaymentMethod?.localizedKind {
            paymentMethod = localizedKind
        } else if let paymentMethodKind = transactionData.paymentMethodKind {
            // Use payment method kind from transaction data if it's not available anymore
            // (e.g. user restarted the process)
            paymentMethod = PCFuelingPaymentMethod.localizedKind(for: paymentMethodKind)
        }

        var actualAmount: Decimal = priceIncludingVAT
        var discountedAmount: Decimal?

        if let discountAmount = discountAmount, discountAmount > 0 {
            actualAmount += discountAmount // Add discount to get actual total amount
            discountedAmount = priceIncludingVAT
        }

        let preAuthSuccessData = PaymentSuccessData(actualAmount: actualAmount,
                                                    fuelingAmount: fuelingAmount,
                                                    productName: productName,
                                                    pricePerUnit: pricePerUnit,
                                                    currencySymbol: fuelingProcess.currencySymbol,
                                                    discountAmount: discountAmount,
                                                    discountedAmount: discountedAmount,
                                                    paymentMethod: paymentMethod,
                                                    recipient: Constants.paceRecipient)
        didFinishPreAuth.value = preAuthSuccessData
    }

    func cancelTransaction() {
        guard let transactionId = fuelingProcess.transactionId else {
            showPumpStatusAlert(message: Constants.genericErrorMessage)
            return
        }

        let gasStationId = fuelingProcess.gasStation.id
        let request = FuelingAPI.Fueling.CancelPreAuth.Request(gasStationId: gasStationId, transactionId: transactionId)
        cancelTransactionRequest = APIHelper.makeFuelingRequest(request) { [weak self] response in
            switch response.result {
            case .success(let successResponse):
                if successResponse.successful {
                    self?.waitForTransactionRequest?.cancel()
                    self?.handleCancelledTransaction()
                    NSLog("[PumpStatusViewModelImplementation] Successfully cancelled transaction at station \(gasStationId).")
                } else {
                    NSLog("[PumpStatusViewModelImplementation] Failed cancelling the transaction at station \(gasStationId). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    self?.showPumpStatusAlert(message: Constants.genericErrorMessage)
                }

            case .failure(let error):
                if case .networkError(let error) = error {
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        return
                    } else {
                        self?.showPumpStatusAlert(message: Constants.networkErrorMessage)
                    }
                } else {
                    self?.showPumpStatusAlert(message: Constants.genericErrorMessage)
                }
                NSLog("[PumpStatusViewModelImplementation] Failed cancelling the transaction with error \(error) at station \(gasStationId). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
            }
        }
    }

    private func handleCancelledTransaction() {
        fuelingProcess.transactionId = nil
        showCancelTransactionSuccess.value = true
    }
}
