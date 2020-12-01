//
//  Address.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation

public extension POIKit {
    /** Address that can be mapped to a road */
    struct Address {

        var id: String = ""
        var geometry = [GeometryCommand]()
        /** house number of the address */
        public var houseNumber: String = ""
        /** street name of the address */
        public var street: String = ""

        var distance: Double?

        /** coordinate where the address is located */
        public var coordinate: CLLocationCoordinate2D? {
            return geometry.first?.location.coordinate
        }

        func copy() -> Address {
            var address = Address()

            address.id = id
            address.geometry = geometry
            address.houseNumber = houseNumber
            address.street = street

            return address
        }
    }
}

// MARK: - Equatable
extension POIKit.Address: Equatable {
    /**
     Returns a Boolean value indicating whether two Addresses are equal.

     - parameter lhs: Address to compare
     - parameter rhs: Another address to compare
     - returns: if addresses are equal
     */
    public static func == (lhs: POIKit.Address, rhs: POIKit.Address) -> Bool {
        return lhs.id == rhs.id && lhs.houseNumber == rhs.houseNumber && lhs.street == rhs.street
    }
}
