//
//  GasStationListViewModel.swift
//  PACECloudSDKFueling
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import PACECloudSDK

protocol GasStationListViewModel: AnyObject {
    var gasStations: LiveData<[GasStation]> { get }
    var errorMessage: LiveData<String> { get }
    var isLoading: LiveData<Bool> { get }
    var didApproachGasStation: LiveData<FuelingProcess> { get }

    func fetchCofuStations()
    func approachGasStation(gasStation: GasStation)
}

class GasStationListViewModelImplementation: NSObject, GasStationListViewModel {
    var gasStations: LiveData<[GasStation]> = .init()
    var errorMessage: LiveData<String> = .init()
    var isLoading: LiveData<Bool> = .init(value: false)
    var didApproachGasStation: LiveData<FuelingProcess> = .init()

    private var locationManager: CLLocationManager?
    private var previousLocation: CLLocation?

    var radius: CLLocationDistance = 20_000

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }

    func fetchCofuStations() {
        guard let location = previousLocation else {
            return
        }

        isLoading.value = true
        POIKit.requestCofuGasStations(center: location, radius: radius) { result in
            DispatchQueue.main.async { [weak self] in
                defer {
                    self?.isLoading.value = false
                }

                switch result {
                case .success(let detailedStations):
                    NSLog("[GasStationListViewModelImplementation] Succeeded to fetch \(detailedStations.count) stations")
                    self?.gasStations.value = detailedStations.compactMap { .init(from: $0, at: location) }.sorted(by: { $0.distance < $1.distance })

                case .failure(let error):
                    if case .operationCanceledByClient = error {} else {
                        print("[GasStationListViewModelImplementation] requestCofuGasStations failed with error: \(error)")
                    }
                }
            }
        }
    }

    func approachGasStation(gasStation: GasStation) { // swiftlint:disable:this cyclomatic_complexity function_body_length
        let stationId = gasStation.id
        let request = FuelingAPI.Fueling.ApproachingAtTheForecourt.Request(gasStationId: stationId)

        isLoading.value = true
        APIHelper.makeFuelingRequest(request) { [weak self] response in
            defer {
                self?.isLoading.value = false
            }

            switch response.result {
            case .success(let result):
                if result.statusCode == HttpStatusCode.unauthorized.rawValue {
                    self?.showApproachingError(message: "Your session has expired. Please log in again.")
                    NSLog("[GasStationListViewModelImplementation] Failed approaching at station \(stationId): 401 - Unauthorized. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    return
                }

                if result.statusCode == HttpStatusCode.internalError.rawValue {
                    self?.showApproachingError(message: "This gas station is currently under maintenance.")
                    NSLog("[GasStationListViewModelImplementation] Failed approaching at station \(stationId): 503 - Maintenance. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    return
                }

                if result.response as? FuelingAPI.Fueling.ApproachingAtTheForecourt.Response.Status404 != nil {
                    self?.showApproachingError(message: "Connected Fueling is coming soon to this gas station.")
                    NSLog("[GasStationListViewModelImplementation] Failed approaching at station \(stationId): 404 - Coming Soon. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    return
                }

                guard result.successful, let data = result.success?.data else {
                    self?.showApproachingError(message: Constants.genericErrorMessage)
                    NSLog("[GasStationListViewModelImplementation] Failed approaching at station \(stationId): Invalid response data. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    return
                }

                let fuelingGasStation = data.gasStation

                guard let fuelingGasStation = fuelingGasStation else {
                    self?.showApproachingError(message: Constants.genericErrorMessage)
                    NSLog("[GasStationListViewModelImplementation] Failed approaching at station \(stationId): No station data included in response. Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
                    return
                }

                let prices = fuelingGasStation.fuelPrices ?? []
                let pumps = fuelingGasStation.pumps ?? []
                let paymentMethods = data.paymentMethods ?? []
                let unsupportedPaymentMethods = data.unsupportedPaymentMethods ?? []

                if paymentMethods.isEmpty {
                    if unsupportedPaymentMethods.isEmpty {
                        self?.showApproachingError(message: "You don't have any payment methods available. Please add a payment method first.")
                    } else {
                        self?.showApproachingError(message: "You don't have any supported payment methods available. Please add a supported payment method first.")
                    }

                    NSLog("[GasStationListViewModelImplementation] Couldn't start fueling process. No payment methods available.")
                    return
                }

                NSLog("[GasStationListViewModelImplementation] Successfully approached station \(stationId). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length

                let fuelingProcess = FuelingProcess(gasStation: gasStation,
                                              prices: prices,
                                              pumps: pumps,
                                              supportedPaymentMethods: paymentMethods,
                                              unsupportedPaymentMethods: unsupportedPaymentMethods)
                self?.didApproachGasStation.value = fuelingProcess

            case .failure(let error):
                if case .networkError(let error) = error {
                    if (error as NSError?)?.code == NSURLErrorCancelled {
                        return
                    } else {
                        self?.showApproachingError(message: Constants.networkErrorMessage)
                    }
                } else {
                    self?.showApproachingError(message: Constants.genericErrorMessage)
                }
                NSLog("[GasStationListViewModelImplementation] Failed approaching with error \(error) at station \(stationId). Request with request-id: \(APIHelper.retrieveRequestID(from: response.urlResponse))") // swiftlint:disable:this line_length
            }
        }
    }

    private func showApproachingError(message: String) {
        errorMessage.value = message
    }
}

extension GasStationListViewModelImplementation: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last,
              previousLocation == nil || location.distance(from: previousLocation!) > 1000 else { return } // swiftlint:disable:this force_unwrapping
        previousLocation = location
        fetchCofuStations()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedAlways || status == .authorizedWhenInUse else { return }
        locationManager?.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard let clError = error as? CLError else { return }

        switch clError.code {
        case .locationUnknown:
            break

        default:
            NSLog("[GasStationListViewModelImplementation] LocationManager failed with error \(error)")
        }
    }
}
