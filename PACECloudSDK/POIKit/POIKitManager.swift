//
//  POIKitManager.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public extension POIKit {
    enum LocationServiceState {
        case disabled
        case denied
        case authorized
        case undetermined
    }

    enum LocationAccuracyState {
        case fullAccuracy
        case reducedAccuracy
    }

    class POIKitManager: NSObject, CLLocationManagerDelegate {
        internal static var onNonFatalErrorOccured: ((Error, Bool) -> Void)?

        // Move location manager into separate `LocationService` class
        lazy var locationManager: CLLocationManager = {
            let locationManager = CLLocationManager()
            locationManager.delegate = self
            return locationManager
        }()

        public weak var delegate: POIKitDelegate?

        var api: POIKitAPIProtocol = POIKitAPI.shared

        public var location: CLLocation? {
            return locationManager.location
        }

        private var locationServiceEnabled: Bool {
            let authorizationStatus: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
            return CLLocationManager.locationServicesEnabled() && (authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse)
        }

        private var locationServiceDenied: Bool {
            return CLLocationManager.authorizationStatus() == .denied
        }

        public var locationServiceState: LocationServiceState {
            if !CLLocationManager.locationServicesEnabled() {
                return .disabled
            } else if locationServiceDenied {
                return .denied
            } else if locationServiceEnabled {
                return .authorized
            }

            return .undetermined
        }

        public var locationAccuracyState: LocationAccuracyState {
            if #available(iOS 14.0, *) {
                return locationManager.accuracyAuthorization == .fullAccuracy ? .fullAccuracy : .reducedAccuracy
            } else {
                return .fullAccuracy
            }
        }

        required init(environment: PACECloudSDK.Environment) {
            api.environment = environment

            super.init()
        }

        public func start() {
            POIKitManager.onNonFatalErrorOccured = nonFatalErrorOccured

            if locationServiceEnabled {
                locationManager.startUpdatingLocation()
            } else if locationServiceDenied {
                self.delegate?.locationPermissionDenied()
            } else {
                requestLocationPermission()
            }
        }

        public func stop() {
            locationManager.stopUpdatingLocation()
        }

        public func observe(delegate: POIKitObserverTokenDelegate,
                            poisOfType: POILayer,
                            boundingBox: BoundingBox,
                            maxDistance: (distance: Double, padding: Double)? = nil,
                            handler: @escaping (Bool, Result<[GasStation], Error>) -> Void) -> BoundingBoxNotificationToken {
            return api.observe(delegate: delegate, poisOfType: poisOfType, boundingBox: boundingBox, maxDistance: maxDistance, handler: handler)
        }

        public func observe(delegate: POIKitObserverTokenDelegate,
                            uuids: [String],
                            handler: @escaping (Bool, Result<[GasStation], Error>) -> Void) -> UUIDNotificationToken {
            return api.observe(delegate: delegate, uuids: uuids, handler: handler)
        }

        /**
         Retrieves a route for a navigation request.

         - parameter request: request with the coordinates for the route and more parameters to restrict the search
         - parameter handler: block called with the calculated route or error if search failed
         */
        public func route(for request: NavigationRequest, handler: ((NavigationResponse?, POIKitAPIError) -> Void)? = nil) {
            api.route(request, handler: handler)
        }

        /**
         Search for a text with the given parameters

         - parameter request: search request restricting the search
         - parameter handler: block called with the search response or error if the request failed
         */
        public func search(_ request: AddressSearchRequest, handler: ((GeoJSONResult?, POIKitAPIError?) -> Void)? = nil) {
            api.search(request, handler: handler)
        }

        /**
         Searches for address results used as search suggestions for the user

         - parameter request: search request restricting the search
         - parameter handler: block called with the search response or error if the request failed
         */
        public func autocomplete(_ request: AddressSearchRequest, isThrottled: Bool, handler: ((GeoJSONResult?, POIKitAPIError?) -> Void)? = nil) {
            api.autocomplete(request, isThrottled: isThrottled, handler: handler)
        }

        /**
         Reverse geocode a location with the given parameters

         - parameter request: reverse geocode request restricting the location
         - parameter handler: block called with the reverse geocode response or error if the request failed
         */
        public func reverseGeocode(_ request: ReverseGeocodeRequest, handler: ((GeoJSONResult?, POIKitAPIError) -> Void)? = nil) {
            api.reverseGeocode(request, handler: handler)
        }

        /**
         Fetches the regional price for a given coordinate.

         - parameter coordinate: Coordinate to fetch the result for
         - parameter result: Result block called with either the response or an error message.
         */
        public func getRegionalPrice(for coordinates: CLLocationCoordinate2D, result: @escaping (Result<RegionalPricesResponse, Error>) -> Void) {
            let request = RegionalPriceRequest(coordinates: coordinates)
            api.regionalPrice(request, result: result)
        }

        /**
         Fetches the filters for a given coordinate from the metadata endpoint

         - parameter coordinate: Coordinate to fetch the result for
         - parameter result: Result block called with either the response or an error message.
         */
        public func getFilters(for coordinates: CLLocationCoordinate2D, result: @escaping (Result<POIFiltersResponse, Error>) -> Void) {
            let request = POIFiltersRequest(coordinates: coordinates)
            api.filters(request, result: result)
        }

        /**
         Fetches the price history for a given id, fuelType and period of time.

         - parameter id: UUID of the gas station
         - parameter fuelType: Desired fuelType of the prices
         - parameter from: Desired start date of prices (needs to be in )
         - parameter result: Result block called with either the response or an error message.
         */
        public func getPriceHistory(for id: String, fuelType: String, from: String, to: String, result: @escaping (Result<PCPriceHistory, Error>) -> Void) {
            let request = PriceHistoryRequest(id: id, fuelType: fuelType, from: from, to: to)
            api.priceHistory(request, result: result)
        }

        public func checkIfGasStationChanged(for id: String, result: @escaping (Result<GasStationResponse, Error>) -> Void) {
            let request = GasStationRequest(id: id)
            api.gasStation(request, result: result)
        }

        public func getGasStation(for id: String, result: @escaping (Result<GasStationResponse, Error>) -> Void) {
            let request = GasStationRequest(id: id)
            api.gasStation(request, result: result)
        }

        // MARK: – CLLocationManagerDelegate
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            delegate?.didUpdateLocations(locations)
            guard let newLocation = locations.last else { return }
            NotificationCenter.default.post(name: .didUpdateLocation, object: nil, userInfo: ["location": newLocation])
        }

        public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
            delegate?.didUpdateHeading(newHeading)
        }

        public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()

            case .restricted, .denied:
                delegate?.locationPermissionDenied()

            default:
                requestLocationPermission()
            }

            delegate?.didChangeLocationAuthorizationStatus(status)
        }

        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            guard let error = error as? CLError else { return }

            delegate?.didFailLocationWithError(error, locationServiceEnabled: CLLocationManager.locationServicesEnabled())
        }

        private func requestLocationPermission() {
            locationManager.requestWhenInUseAuthorization()
        }

        private func nonFatalErrorOccured(_ error: Error, _ shouldCrash: Bool) {
            delegate?.nonFatalErrorOccured(error, shouldCrash)
        }
    }
}
