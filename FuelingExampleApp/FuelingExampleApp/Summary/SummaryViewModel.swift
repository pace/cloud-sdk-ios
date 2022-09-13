//
//  SummaryViewModel.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import Foundation
import PACECloudSDK

protocol SummaryViewModel: AnyObject {
    var fuelingProcess: FuelingProcess { get }

    var summaryItems: LiveData<[SummaryItem]> { get }
    var showPaymentAuthorizationAlert: LiveData<Bool> { get }
    var didFinishPaymentProcess: LiveData<PaymentSuccessData> { get }
    var isLoading: LiveData<Bool> { get }
    var errorMessage: LiveData<String> { get }

    init(fuelingProcess: FuelingProcess)
    func requestDiscountInformationIfNeeded()
    func makePayment()
    func handlePaymentAuthorization(type: PaymentAuthorizationType, input: String?)
}

class SummaryViewModelImplementation: SummaryViewModel {
    private(set) var fuelingProcess: FuelingProcess

    private(set) var summaryItems: LiveData<[SummaryItem]> = .init()
    private(set) var showPaymentAuthorizationAlert: LiveData<Bool> = .init(value: false)
    private(set) var isLoading: LiveData<Bool> = .init(value: false)
    private(set) var didFinishPaymentProcess: LiveData<PaymentSuccessData> = .init()
    private(set) var errorMessage: LiveData<String> = .init()

    private var discountsRequest: URLSessionDataTask?
    private var authorizationRequest: CancellablePayAPIRequest?
    private var processPaymentRequest: CancellableFuelingAPIRequest?

    private var discounts: [Discount]?
    private var discountTokens: [String]? {
        discounts?.map { $0.token }
    }

    private var discountAmount: Decimal? {
        discounts?.map { $0.amount }.reduce(0, +)
    }

    required init(fuelingProcess: FuelingProcess) {
        self.fuelingProcess = fuelingProcess
    }

    var paymentAuthorizationCompletion: ((PaymentAuthorization?) -> Void)?

    func requestDiscountInformationIfNeeded() {
        guard fuelingProcess.isPostPay else {
            setupSummaryItems()
            return
        }

        guard let pumpId = fuelingProcess.selectedPump?.id else { return }

        let gasStationId = fuelingProcess.gasStation.id
        let paymentMethodId = fuelingProcess.selectedPaymentMethod?.id
        let paymentMethodKind = fuelingProcess.selectedPaymentMethod?.kind

        requestDiscounts(gasStationId: gasStationId,
                         pumpId: pumpId,
                         paymentMethodId: paymentMethodId,
                         paymentMethodKind: paymentMethodKind) { [weak self] in
            self?.setupSummaryItems()
        }
    }

    func showPaymentErrorAlert(message: String) {
        errorMessage.value = message
    }

    private func setupSummaryItems() {
        guard let selectedPaymentMethod = fuelingProcess.selectedPaymentMethod else {
            showPaymentErrorAlert(message: Constants.genericErrorMessage)
            return
        }

        let currencySymbol = fuelingProcess.currencySymbol

        let stationName = fuelingProcess.gasStation.name
        let stationAddress = "\(fuelingProcess.gasStation.addressLine1)\n\(fuelingProcess.gasStation.addressLine2)"
        let totalAmount = "\(fuelingProcess.formattedAmount)\(currencySymbol)"

        var summaryItems: [SummaryItem] = [
            .init(title: "Total amount", value: totalAmount)
        ]

        if let discountAmount = discountAmount {
            let formattedDiscountedAmount = fuelingProcess.formattedDiscountedAmount(for: discountAmount)
            let discountedAmount = "\(formattedDiscountedAmount)\(currencySymbol)"
            summaryItems.append(.init(title: "Discounted amount", value: discountedAmount))
        }

        if let productName = fuelingProcess.fuelTypeName {
            let fuelingAmount = "\(fuelingProcess.formattedFuelingAmount) ltr"
            summaryItems.append(.init(title: productName, value: fuelingAmount))
        }

        if !fuelingProcess.formattedPricePerLiter.isEmpty {
            let pricePerLiter = "\(fuelingProcess.formattedPricePerLiter)\(currencySymbol)"
            summaryItems.append(.init(title: "Price/ltr", value: pricePerLiter))
        }

        [
            .init(title: selectedPaymentMethod.localizedKind ?? "", value: selectedPaymentMethod.alias ?? selectedPaymentMethod.identificationString ?? ""),
            .init(title: "Gas station", value: stationName),
            .init(title: "Address", value: stationAddress),
            .init(title: "Recipient", value: Constants.paceRecipient)
        ].forEach {
            summaryItems.append($0)
        }

        self.summaryItems.value = summaryItems
    }

    deinit {
        discountsRequest?.cancel()
        authorizationRequest?.cancel()
        processPaymentRequest?.cancel()
    }
}

// MARK: - Payment handling
extension SummaryViewModelImplementation {
    func makePayment() {
        guard let paymentMethod = fuelingProcess.selectedPaymentMethod,
              let paymentMethodId = paymentMethod.id,
              let pumpId = fuelingProcess.selectedPump?.id,
              let amount = fuelingProcess.amount
        else {
            showPaymentErrorAlert(message: Constants.genericErrorMessage)
            return
        }

        let gasStationId = fuelingProcess.gasStation.id
        let currency = fuelingProcess.currency
        let purposePRNs = purposePRNs(gasStationId: gasStationId, fuelType: fuelingProcess.fuelType, paymentMethod: paymentMethod)

        handlePaymentAuthorizationIfNeeded(paymentMethod: paymentMethod) { [weak self] paymentAuthorization in
            self?.startPaymentProcess(gasStationId: gasStationId,
                                      pumpId: pumpId,
                                      paymentMethodId: paymentMethodId,
                                      currency: currency,
                                      amount: amount,
                                      purposePRNs: purposePRNs,
                                      discountTokens: self?.discountTokens,
                                      twoFactorAuthorization: paymentAuthorization)
        }
    }

    private func startPaymentProcess(gasStationId: String, // swiftlint:disable:this function_parameter_count
                                     pumpId: String,
                                     paymentMethodId: String,
                                     currency: String,
                                     amount: Decimal,
                                     purposePRNs: [String],
                                     discountTokens: [String]?,
                                     twoFactorAuthorization: PaymentAuthorization?) {
        authorize(paymentMethodId: paymentMethodId,
                  currency: currency,
                  amount: amount,
                  purposePRNs: purposePRNs,
                  discountTokens: discountTokens,
                  twoFactorAuthorization: twoFactorAuthorization) { [weak self] paymentToken in
            guard let paymentToken = paymentToken else { return }
            self?.processPayment(paymentToken: paymentToken,
                                 gasStationId: gasStationId,
                                 pumpId: pumpId) { [weak self] transactionId in
                guard let transactionId = transactionId else { return }
                self?.completePaymentProcess(transactionId: transactionId, amount: amount)
            }
        }
    }

    private func purposePRNs(gasStationId: String, fuelType: String?, paymentMethod: PCFuelingPaymentMethod) -> [String] {
        var purposePRNs = ["\(Constants.prnPrefixGasStationId)\(gasStationId)"]

        if let fuelType = fuelingProcess.fuelType {
            purposePRNs.append("\(Constants.prnPrefixFuelType)\(fuelType)")
        }

        return purposePRNs
    }

    private func completePaymentProcess(transactionId: String, amount: Decimal) {
        fuelingProcess.transactionId = transactionId

        var discountedAmount: Decimal?
        if let discountAmount = discountAmount {
            discountedAmount = fuelingProcess.discountedAmount(for: discountAmount)
        }

        let paymentSuccessData: PaymentSuccessData = .init(actualAmount: amount,
                                                           fuelingAmount: fuelingProcess.fuelingAmount,
                                                           productName: fuelingProcess.fuelTypeName,
                                                           pricePerUnit: fuelingProcess.pricePerLiter,
                                                           currencySymbol: fuelingProcess.currencySymbol,
                                                           discountAmount: discountAmount,
                                                           discountedAmount: discountedAmount,
                                                           paymentMethod: fuelingProcess.selectedPaymentMethod?.localizedKind,
                                                           recipient: Constants.paceRecipient)
        didFinishPaymentProcess.value = paymentSuccessData
    }
}

// MARK: - API requests
private extension SummaryViewModelImplementation {
    func requestDiscounts(gasStationId: String,
                          pumpId: String,
                          paymentMethodId: String?,
                          paymentMethodKind: String?,
                          completion: @escaping () -> Void) {
        guard let discountRequest = APIHelper.discountRequest(gasStationId: gasStationId,
                                                              pumpId: pumpId,
                                                              paymentMethodId: paymentMethodId,
                                                              paymentMethodKind: paymentMethodKind)
        else {
            completion()
            return
        }

        NSLog("[SummaryViewModelImplementation] Requesting discounts...")
        isLoading.value = true
        discountsRequest = APIHelper.makeCustomJSONRequest(discountRequest) { [weak self] (response: Result<DiscountResponse, APIClientError>) in
            defer {
                self?.isLoading.value = false
            }

            switch response {
            case .success(let result):
                guard let discountData = result.data else {
                    NSLog("[SummaryViewModelImplementation] Failed requesting discount: Invalid response data.")
                    completion()
                    return
                }

                let discounts: [Discount] = discountData.compactMap(Discount.init(from:))
                let discountsResult: [Discount]? = discounts.isEmpty ? nil : discounts

                NSLog("[SummaryViewModelImplementation] Successfully requested discount - Discounted amount: \(discounts.map { $0.amount }.reduce(0, +))")

                self?.discounts = discountsResult
                completion()

            case .failure(let error):
                if case .networkError(let error) = error {
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        completion()
                        return
                    } else {
                        completion()
                    }
                } else {
                    completion()
                }
                NSLog("[SummaryViewModelImplementation] Failed discount request with error \(error)")
            }
        }
    }

    func authorize(paymentMethodId: String, // swiftlint:disable:this function_parameter_count
                   currency: String,
                   amount: Decimal,
                   purposePRNs: [String],
                   discountTokens: [String]?,
                   twoFactorAuthorization: PaymentAuthorization?,
                   completion: @escaping (String?) -> Void) {
        var twoFactor: PCPayPaymentTokenCreateRequest.Attributes.TwoFactor?
        if let twoFactorAuthorization = twoFactorAuthorization {
            twoFactor = .init(method: twoFactorAuthorization.method, otp: twoFactorAuthorization.otp)
        }

        let body: PayAPI.PaymentTokens.AuthorizePaymentToken.Request.Body = .init(data: .init(type: .paymentToken,
                                                                                              attributes: .init(currency: currency,
                                                                                                                amount: amount,
                                                                                                                purposePRNs: purposePRNs,
                                                                                                                discountTokens: discountTokens,
                                                                                                                twoFactor: twoFactor)))

        let request = PayAPI.PaymentTokens.AuthorizePaymentToken.Request(paymentMethodId: paymentMethodId, body: body)
        isLoading.value = true
        authorizationRequest = APIHelper.makePayRequest(request) { [weak self] response in
            switch response.result {
            case .success(let result):
                if let error403 = result.response as? PayAPI.PaymentTokens.AuthorizePaymentToken.Response.Status403,
                   (error403.errors ?? []).contains(where: { $0.code == "rule:product-denied" }) {
                    NSLog("[SummaryViewModelImplementation] Failed authorize: 403 - 'rule:product-denied'. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    self?.showPaymentErrorAlert(message: "Payment with your selected fuel type is not supported")
                    self?.isLoading.value = false
                    completion(nil)
                    return
                }

                guard result.successful, let paymentToken = result.success?.data else {
                    NSLog("[SummaryViewModelImplementation] Failed authorize: Invalid response data. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    self?.showPaymentErrorAlert(message: Constants.genericErrorMessage)
                    self?.isLoading.value = false
                    completion(nil)
                    return
                }

                completion(paymentToken.value)

            case .failure(let error):
                NSLog("[SummaryViewModelImplementation] Failed payment authorization with error \(error). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                self?.isLoading.value = false
                self?.handlePaymentErrorResponse(error: error, completion: completion)
            }
        }
    }

    func processPayment(paymentToken: String,
                        gasStationId: String,
                        pumpId: String,
                        completion: @escaping (String?) -> Void) {
        let transactionId = UUID().uuidString.lowercased()
        let transactionRequest: PCFuelingTransactionRequest = .init(data: .init(type: .transaction,
                                                                                attributes: .init(paymentToken: paymentToken,
                                                                                                  pumpId: pumpId),
                                                                                id: transactionId))

        let request = FuelingAPI.Fueling.ProcessPayment.Request(gasStationId: gasStationId, body: transactionRequest)
        request.body.data?.id = transactionId

        processPaymentRequest = APIHelper.makeFuelingRequest(request) { [weak self] response in
            defer {
                self?.isLoading.value = false
            }

            switch response.result {
            case .success(let result):
                guard result.successful else {
                    NSLog("[SummaryViewModelImplementation] Failed process payment at station \(gasStationId): Invalid response data. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    self?.showPaymentErrorAlert(message: Constants.genericErrorMessage)
                    completion(nil)
                    return
                }

                NSLog("[SummaryViewModelImplementation] Payment successful at station: \(gasStationId) Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                completion(transactionId)

            case .failure(let error):
                NSLog("[SummaryViewModelImplementation] Failed payment with error \(error) at station \(gasStationId). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                self?.handlePaymentErrorResponse(error: error, completion: completion)
            }
        }
    }

    func handlePaymentErrorResponse(error: APIClientError, completion: @escaping (String?) -> Void) {
        if case .networkError(let error) = error {
            if (error as NSError?)?.code == NSURLErrorCancelled {
                completion(nil)
                return
            } else {
                showPaymentErrorAlert(message: Constants.networkErrorMessage)
                completion(nil)
            }
        } else {
            showPaymentErrorAlert(message: Constants.genericErrorMessage)
            completion(nil)
        }
    }
}
