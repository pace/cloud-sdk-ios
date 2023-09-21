//
//  PACECloudSDK.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

public class POIKit {
    static var shared: POIKit {
        PACECloudSDK.shared.warningsHandler?.logSDKWarningsIfNeeded()
        return sharedInstance
    }

    private static var sharedInstance: POIKit = POIKit()

    private var geoAPIManager: GeoAPIManager
    private lazy var oneTimeLocationProvider: OneTimeLocationProvider = .init()

    private var currentEnvironment: PACECloudSDK.Environment

    private init() {
        geoAPIManager = GeoAPIManager()
        currentEnvironment = PACECloudSDK.shared.environment
    }

    static func setup() {
        shared.geoAPIManager.speedThreshold = PACECloudSDK.shared.config?.speedThreshold ?? Constants.Configuration.defaultSpeedThreshold
        shared.oneTimeLocationProvider.lowAccuracy = PACECloudSDK.shared.config?.allowedLowAccuracy ?? Constants.Configuration.defaultAllowedLowAccuracy
        shared.geoAPIManager.geoAppsScope = PACECloudSDK.shared.config?.geoAppsScope
    }
}

extension POIKit {
    func locationBasedCofuStations(for location: CLLocation, completion: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        geoAPIManager.locationBasedCofuStations(for: location, result: completion)
    }

    func requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) -> Void) {
        geoAPIManager.cofuGasStations(option: option) { result in
            guard case let .success(stations) = result else {
                completion(nil)
                return
            }
            completion(stations)
        }
    }

    func requestCofuGasStations(center: CLLocation, radius: CLLocationDistance, completion: @escaping (Result<[POIKit.GasStation], POIKitAPIError>) -> Void) {
        requestCofuGasStations(option: .boundingBox(center: center, radius: radius)) { stations in
            guard let stations = stations else {
                completion(.failure(.unknown))
                return
            }

            let poiKitManager = POIKit.POIKitManager(environment: self.currentEnvironment)

            _ = poiKitManager.fetchPOIs(locations: stations.compactMap { $0.location }) { result in
                switch result {
                case .success(let poiStations):
                    let cofuStations = poiStations.filter { poiStation in
                        guard let station = stations.first(where: { $0.id == poiStation.id }) else { return false }
                        poiStation.additionalProperties = station.properties
                        return true
                    }
                    completion(.success(cofuStations))

                case .failure(let error as POIKit.POIKitAPIError):
                    completion(.failure(error))

                case .failure:
                    completion(.failure(.unknown))
                }
            }
        }
    }

    func isPoiInRange(id: String, at location: CLLocation?, completion: @escaping ((Bool) -> Void)) {
        DispatchQueue.main.async { [weak self] in
            guard let location = location else {
                self?.oneTimeLocationProvider.requestLocation { [weak self] location in
                    guard let location = location else {
                        completion(false)
                        return
                    }

                    self?.geoAPIManager.isPoiInRange(with: id, near: location, completion: completion)
                }
                return
            }
            self?.geoAPIManager.isPoiInRange(with: id, near: location, completion: completion)
        }
    }
}

@MainActor
extension POIKit {
    func requestCofuGasStations(option: CofuGasStation.Option = .all) async -> [CofuGasStation]? {
        await withCheckedContinuation { [weak self] continuation in
            self?.requestCofuGasStations(option: option) { cofuStations in
                continuation.resume(returning: cofuStations)
            }
        }
    }

    func requestCofuGasStations(center: CLLocation, radius: CLLocationDistance) async -> Result<[POIKit.GasStation], POIKitAPIError> {
        await withCheckedContinuation { [weak self] continuation in
            self?.requestCofuGasStations(center: center, radius: radius) { result in
                continuation.resume(returning: result)
            }
        }
    }

    func isPoiInRange(id: String, at location: CLLocation?) async -> Bool {
        await withCheckedContinuation { [weak self] continuation in
            self?.isPoiInRange(id: id, at: location) { isInRange in
                continuation.resume(returning: isInRange)
            }
        }
    }
}
