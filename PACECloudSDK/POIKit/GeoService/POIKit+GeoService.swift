//
//  POIKit+GeoService.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import Foundation

extension POIKit {
    static func locationBasedCofuStations(for location: CLLocation, completion: @escaping (Result<[CofuGasStation], GeoApiManagerError>) -> Void) {
        shared.locationBasedCofuStations(for: location, completion: completion)
    }
}

public extension POIKit {

    /// Requests connected fueling gas stations for the specified option.
    ///
    /// The response might also include connected fueling stations that are currently **offline**.
    /// You may use the `onlineStations` property on the response array to filter the stations by their online status.
    ///
    /// ```swift
    /// POIKit.requestCofuGasStations(option: .all) { cofuStations in
    ///     let onlineStations = cofuStations?.onlineStations
    /// }
    /// ```
    /// If you wish to retrieve connected fueling stations that contain more detailed information use
    /// `requestCofuGasStations(center: CLLocation, radius: CLLocationDistance,`
    /// `includesOnlineOnly: Bool = true, completion: @escaping (Result<[POIKit.GasStation], POIKitAPIError>) -> Void)`
    /// instead.
    ///
    /// - Parameter option: The option that defines which connected fueling gas stations will be contained in the
    /// response.
    /// - Parameter completion: The block to be called when the response is available either containing a list of
    /// connected fueling gas stations or
    /// `nil` if the retrieval failed.
    static func requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) -> Void) {
        shared.requestCofuGasStations(option: option, completion: completion)
    }

    /// Requests connected fueling gas stations for the specified area with detailed information.
    ///
    /// The response might also include connected fueling stations that are currently **offline**.
    ///
    ///  If you only need a list of connected fueling gas stations e.g. for their ids or their location, please use
    ///  `requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) ->
    ///  Void)`
    ///  instead.
    ///
    /// - Parameter center: The center of the area you are requesting.
    /// - Parameter radius: The radius for the desired area.
    /// - Parameter completion: The block to be called when the response is available
    /// either containing a list of online connected fueling gas stations with detailed information or an `error`.
    static func requestCofuGasStations(center: CLLocation, radius: CLLocationDistance, completion: @escaping (Result<[POIKit.GasStation], POIKitAPIError>) -> Void) {
        shared.requestCofuGasStations(center: center, radius: radius, completion: completion)
    }

    /// Requests connected fueling gas stations for the specified bounding box with detailed information.
    ///
    /// The response might also include connected fueling stations that are currently **offline**.
    ///
    ///  If you only need a list of connected fueling gas stations e.g. for their ids or their location, please use
    ///  `requestCofuGasStations(option: CofuGasStation.Option = .all, completion: @escaping ([CofuGasStation]?) ->
    ///  Void)`
    ///  instead.
    ///
    /// - Parameter boundingBox: The bounding box of the area you are requesting.
    /// - Parameter completion: The block to be called when the response is available
    /// either containing a list of online connected fueling gas stations with detailed information or an `error`.
    static func requestCofuGasStations(boundingBox: POIKit.BoundingBox, completion: @escaping (Result<[POIKit.GasStation], POIKitAPIError>) -> Void) {
        shared.requestCofuGasStations(boundingBox: boundingBox, completion: completion)
    }

    /// Checks if the connected fueling gas station with the specified id is in range of the user's current location.
    /// - Parameter id: The id of the gas station.
    /// - Parameter location: The location to be checked. Defaults to `nil`. If `location` is not specified the SDK
    /// will request the current location
    /// itself.
    /// - Parameter completion: The block to be called when the check has been completed containing a boolean
    /// that reflects if the connected fueling gas station is in range or not.
    static func isPoiInRange(id: String, at location: CLLocation? = nil, completion: @escaping ((Bool) -> Void)) {
        shared.isPoiInRange(id: id, at: location, completion: completion)
    }
}

@MainActor
public extension POIKit {

    /// Requests connected fueling gas stations for the specified option.
    ///
    /// The response might also include connected fueling stations that are currently **offline**.
    /// You may use the `onlineStations` property on the response array to filter the stations by their online status.
    ///
    /// ```swift
    /// POIKit.requestCofuGasStations(option: .all) { cofuStations in
    ///     let onlineStations = cofuStations?.onlineStations
    /// }
    /// ```
    /// If you wish to retrieve connected fueling stations that contain more detailed information use
    /// `requestCofuGasStations(center: CLLocation, radius: CLLocationDistance,`
    /// `includesOnlineOnly: Bool = true) async -> Result<[POIKit.GasStation], POIKitAPIError>`
    /// instead.
    ///
    /// - Parameter option: The option that defines which connected fueling gas stations will be contained in the
    /// response.
    /// - Returns: An asynchronously-delivered optional array of `CofuGasStation`.
    static func requestCofuGasStations(option: CofuGasStation.Option = .all) async -> [CofuGasStation]? {
        await shared.requestCofuGasStations(option: option)
    }

    /// Requests connected fueling gas stations for the specified area with detailed information.
    ///
    /// The response might also include connected fueling stations that are currently **offline**.
    ///
    ///  If you only need a list of connected fueling gas stations e.g. for their ids or their location, please use
    ///  `requestCofuGasStations(option: CofuGasStation.Option = .all) async -> [CofuGasStation]?`
    ///  instead.
    ///
    /// - Parameter center: The center of the area you are requesting.
    /// - Parameter radius: The radius for the desired area.
    /// - Parameter completion: The block to be called when the response is available
    /// either containing a list of online connected fueling gas stations with detailed information or an `error`.
    /// - Returns: An asynchronously-delivered result that either contains an array of `POIKit.CofuGasStation` or an
    /// error.
    static func requestCofuGasStations(center: CLLocation, radius: CLLocationDistance) async -> Result<[POIKit.GasStation], POIKitAPIError> {
        await shared.requestCofuGasStations(center: center, radius: radius)
    }

    /// Requests connected fueling gas stations for the specified bounding box with detailed information.
    ///
    /// The response might also include connected fueling stations that are currently **offline**.
    ///
    ///  If you only need a list of connected fueling gas stations e.g. for their ids or their location, please use
    ///  `requestCofuGasStations(option: CofuGasStation.Option = .all) async -> [CofuGasStation]?`
    ///  instead.
    ///
    /// - Parameter boundingBox: The bounding box of the area you are requesting.
    /// - Parameter completion: The block to be called when the response is available
    /// either containing a list of online connected fueling gas stations with detailed information or an `error`.
    /// - Returns: An asynchronously-delivered result that either contains an array of `POIKit.CofuGasStation` or an
    /// error.
    static func requestCofuGasStations(boundingBox: POIKit.BoundingBox) async -> Result<[POIKit.GasStation], POIKitAPIError> {
        await shared.requestCofuGasStations(boundingBox: boundingBox)
    }

    /// Checks if the connected fueling gas station with the specified id is in range of the user's current location.
    /// - Parameter id: The id of the gas station.
    /// - Parameter location: The location to be checked. Defaults to `nil`. If `location` is not specified the SDK
    /// will request the current location
    /// itself.
    /// - Returns: An asynchronously-delivered boolean that reflects if the connected fueling gas station is in range
    /// or not.
    static func isPoiInRange(id: String, at location: CLLocation? = nil) async -> Bool {
        await shared.isPoiInRange(id: id, at: location)
    }
}
