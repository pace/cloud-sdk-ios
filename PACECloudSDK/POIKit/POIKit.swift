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

    private var geoAPIManager: GeoAPIManager?
    private lazy var oneTimeLocationProvider: OneTimeLocationProvider = .init()

    private var currentEnvironment: PACECloudSDK.Environment

    private init() {
        currentEnvironment = PACECloudSDK.shared.environment
    }

    static func setup() {
        guard let sdkConfig = PACECloudSDK.shared.config else {
            POIKitLogger.e("[POIKit] Failed setting up POIKit. Corrupted SDK config")
            return
        }

        shared.oneTimeLocationProvider.lowAccuracy = sdkConfig.allowedLowAccuracy

        switch sdkConfig.geoDatabaseMode {
        case .enabled(let databaseUrl):
            Task {
                shared.geoAPIManager = await .init(databaseUrl: databaseUrl,
                                                   speedThreshold: sdkConfig.speedThreshold,
                                                   geoAppsScope: sdkConfig.geoAppsScope)
            }

        case .disabled:
            POIKitLogger.i("[POIKit] GeoDatabase has been disabled.")
        }
    }
}

extension POIKit {
    func locationBasedCofuStations(for location: CLLocation, completion: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        guard let geoAPIManager else {
            completion(.failure(.unknown))
            return
        }

        Task(priority: .utility) {
            let result = await geoAPIManager.locationBasedCofuStations(for: location)
            completion(result)
        }
    }

    func requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) -> Void) {
        guard let geoAPIManager else {
            completion(nil)
            return
        }

        Task(priority: .utility) {
            let result = await geoAPIManager.cofuGasStations(option: option)

            guard case let .success(stations) = result else {
                completion(nil)
                return
            }

            completion(stations)
        }
    }

    func requestCofuGasStations(boundingBox: POIKit.BoundingBox, completion: @escaping (Result<[POIKit.GasStation], POIKitAPIError>) -> Void) {
        requestCofuGasStations(option: .boundingBox(box: boundingBox)) { [weak self] stations in
            guard let stations = stations, let self = self else {
                completion(.failure(.unknown))
                return
            }

            self.fetchPOIs(for: stations, handler: completion)
        }
    }

    func requestCofuGasStations(center: CLLocation, radius: CLLocationDistance, completion: @escaping (Result<[POIKit.GasStation], POIKitAPIError>) -> Void) {
        requestCofuGasStations(option: .boundingCircle(center: center, radius: radius)) { [weak self] stations in
            guard let stations = stations, let self = self else {
                completion(.failure(.unknown))
                return
            }

            self.fetchPOIs(for: stations, handler: completion)
        }
    }

    func isPoiInRange(id: String, at location: CLLocation?, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async { [weak self] in
            guard let geoAPIManager = self?.geoAPIManager, let location = location else {
                self?.oneTimeLocationProvider.requestLocation { [weak self] location in
                    guard let geoAPIManager = self?.geoAPIManager, let location = location else {
                        completion(false)
                        return
                    }

                    Task(priority: .utility) {
                        let isInRange = await geoAPIManager.isPoiInRange(with: id, near: location)
                        completion(isInRange)
                    }
                }
                return
            }

            Task(priority: .utility) {
                let isInRange = await geoAPIManager.isPoiInRange(with: id, near: location)
                completion(isInRange)
            }
        }
    }

    private func fetchPOIs(for stations: [POIKit.CofuGasStation], handler: @escaping (Result<[POIKit.GasStation], POIKitAPIError>) -> Void) {
        let poiKitManager = POIKit.POIKitManager(environment: self.currentEnvironment)

        _ = poiKitManager.fetchPOIs(locations: stations.compactMap { $0.location }) { result in
            switch result {
            case .success(let poiStations):
                let cofuStations = poiStations.filter { poiStation in
                    guard let station = stations.first(where: { $0.id == poiStation.id }) else { return false }
                    poiStation.additionalProperties = station.properties
                    return true
                }
                handler(.success(cofuStations))

            case .failure:
                handler(.failure(.unknown))
            }
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

    func requestCofuGasStations(boundingBox: POIKit.BoundingBox) async -> Result<[POIKit.GasStation], POIKitAPIError> {
        await withCheckedContinuation { [weak self] continuation in
            self?.requestCofuGasStations(boundingBox: boundingBox) { result in
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
