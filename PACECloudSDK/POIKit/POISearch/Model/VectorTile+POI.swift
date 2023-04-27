//
//  VectorTile+POI.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import Foundation

extension VectorTile_Tile {
    func loadPOIContents(for tileInformation: TileInformation) -> [POIKit.GasStation] {
        guard let poiLayer = layers.first(where: { $0.name == "pois" }) else {
            return []
        }

        return loadPOIs(for: poiLayer, tileInformation: tileInformation)
    }

    private func loadPOIs(for layer: VectorTile_Tile.Layer, tileInformation: TileInformation) -> [POIKit.GasStation] {
        var pois = [POIKit.GasStation]()

        for feature in layer.features {
            let values = feature.getValues(for: layer)

            let commands = feature.processGeometry()
            let geometry: [POIKit.GeometryCommand] = commands.map { POIKit.GeometryCommand(type: $0.type,
                                                          coordinate: $0.point.toGpsCoordinate(extent: layer.extent,
                                                                                               tileInformation: tileInformation)) }

            let type = values["t"]
            if type == "gasStation" {
                let gasStation = loadGasStation(for: values)
                gasStation.geometry = geometry
                pois.append(gasStation)
            }
        }

        return pois
    }

    private func loadGasStation(for values: [String: String]) -> POIKit.GasStation {
        let gasStation = POIKit.GasStation()

        if let id = values["id"] { gasStation.id = id }
        if let name = values["n"] { gasStation.stationName = name }
        if let brand = values["b"] { gasStation.brand = brand }

        if let openingHoursValue = values["oh"] {
            loadOpeningHourRules(for: gasStation, from: openingHoursValue)
        }

        if let prices = values["pl"] {
            loadPrices(for: gasStation, from: prices)
        }

        if let currency = values["pc"] { gasStation.currency = currency }
        if let priceFormat = values["pf"] { gasStation.priceFormat = priceFormat }

        if let paymentMethods = values["pm"] {
            let splittedResponse = splitResponse(for: paymentMethods)
            let wrapped = splittedResponse.compactMap { $0 }
            let cofuPaymentMethods = splittedResponse.filter { $0.hasPrefix("cofu:") }
            gasStation.paymentMethods = wrapped
            gasStation.cofuPaymentMethods = cofuPaymentMethods
        }

        if let addressString = values["a"] {
            gasStation.address = loadAddress(from: addressString)
        }

        if let validFrom = values["vf"], let lastUpdatedTimestamp = Int(validFrom) {
            gasStation.lastUpdated = Date(timeIntervalSince1970: Double(lastUpdatedTimestamp))
        }

        if let amenities = values["am"] {
            let splittedResponse = splitResponse(for: amenities)
            let wrapped = splittedResponse.compactMap { $0 }
            gasStation.amenities = wrapped
        }

        if let foods = values["fd"] {
            let splittedResponse = splitResponse(for: foods)
            let wrapped = splittedResponse.compactMap { $0 }
            gasStation.food = wrapped
        }

        if let loyalityPrograms = values["lp"] {
            let splittedResponse = splitResponse(for: loyalityPrograms)
            let wrapped = splittedResponse.compactMap { $0 }
            gasStation.loyaltyPrograms = wrapped
        }

        if let postService = values["ps"] {
            let splittedResponse = splitResponse(for: postService)
            let wrapped = splittedResponse.compactMap { $0 }
            gasStation.postalServices = wrapped
        }

        if let services = values["sv"] {
            let splittedResponse = splitResponse(for: services)
            let wrapped = splittedResponse.compactMap { $0 }
            gasStation.services = wrapped
        }

        if let shop = values["sg"] {
            let splittedResponse = splitResponse(for: shop)
            let wrapped = splittedResponse.compactMap { $0 }
            gasStation.shopGoods =  wrapped
        }
        
        if let connectedFueling = values["cf"], connectedFueling == "y" { gasStation.isConnectedFuelingAvailable = true }
        if let priceComparisonOptOut = values["po"], priceComparisonOptOut == "y" { gasStation.priceComparisonOptOut = true }

        return gasStation
    }

    private func splitResponse(for object: String, separator: Character = ",") -> [String] {
        object.split(separator: separator).map { String($0) }
    }

    private func loadOpeningHourRules(for gasStation: POIKit.GasStation, from value: String) {
        guard let regex = try? NSRegularExpression(pattern: ",[a-z]{2}=", options: []) else { return }

        let matches = regex
            .matches(in: value, options: [], range: NSRange(location: 0, length: value.count))
            .filter { $0.numberOfRanges == 1 }
            .map { $0.range(at: 0).location }

        let locations = matches + [value.count]
        let previousLocations = [-1] + locations

        let values = zip(previousLocations, locations).map { previous, location -> String in
            let start = value.index(value.startIndex, offsetBy: previous + 1)
            let end = value.index(value.startIndex, offsetBy: location)
            return String(value[start..<end])
        }

        gasStation.openingHours = loadOpeningHours(from: values)
    }

    private func loadOpeningHours(from values: [String]) -> PCPOICommonOpeningHours {
        var rules: [PCPOICommonOpeningHours.Rules] = []

        values.forEach {
            let components = dictionary(from: $0)

            var days: [PCPOICommonOpeningHours.Rules.PCPOIDays] = []
            var timespans: [PCPOICommonOpeningHours.Rules.Timespans] = []

            if let unwrapped = components["ds"] {
                days = unwrapped
                    .split(separator: ",")
                    .compactMap { PCPOICommonOpeningHours.Rules.PCPOIDays(rawValue: String($0)) }
            }
            if let unwrapped = components["hr"] {
                let tmpHours = unwrapped.split(separator: ",").map { String($0) }
                timespans = tmpHours.compactMap {
                    let hourComponents = $0.split(separator: "-").map { String($0) }

                    return hourComponents.count == 2 ? PCPOICommonOpeningHours.Rules.Timespans(from: hourComponents[0], to: hourComponents[1]) : nil
                }
            }
            let ruleAction = PCPOICommonOpeningHours.Rules.PCPOIAction(rawValue: components["rl"] ?? "")
            let rule = PCPOICommonOpeningHours.Rules(action: ruleAction, days: days, timespans: timespans)
            rules.append(rule)
        }

        let openingHours = PCPOICommonOpeningHours(rules: rules)
        return openingHours
    }

    private func loadPrices(for gasStation: POIKit.GasStation, from prices: String) {
        let priceComponents = prices.split(separator: ",").map { String($0) }
        gasStation.prices = priceComponents.compactMap { priceComponent in
            let priceArray = array(from: priceComponent)

            guard let productType = priceArray.first(where: { $0.0 == "pt"})?.1 else { return nil } // TOOD: Is product type always set?

            let name = priceArray.first(where: { $0.0 == "pn"})?.1

            var price: Double?

            if let unwrapped = priceArray.first(where: { $0.0 == "pv"})?.1 {
                price = Double(unwrapped)
            }

            let fuelPrice = PCPOIFuelPrice(type: .fuelPrice, fuelType: productType, price: price, productName: name)
            return fuelPrice
        }
    }

    private func array(from string: String) -> [(String, String)] {
        var array: [(String, String)] = .init()
        let entries: [String] = string.split(separator: ";").map { $0.string }
        for entry in entries {
            let keyValuePair = entry.split(separator: "=").map { String($0) }
            guard keyValuePair.count == 2 else { continue }
            array.append((keyValuePair[0], keyValuePair[1]))
        }
        return array
    }

    private func loadAddress(from string: String) -> PCPOIGasStation.Address {
        let addressEntries = dictionary(from: string)
        return PCPOIGasStation.Address(city: addressEntries["l"],
                                       countryCode: addressEntries["c"],
                                       houseNo: addressEntries["hn"],
                                       postalCode: addressEntries["pc"],
                                       street: addressEntries["s"])
    }

    private func dictionary(from string: String) -> [String: String] {
        var dictionary = [String: String]()
        let entries = string.split(separator: ";")
        for entry in entries {
            let keyValuePair = entry.split(separator: "=").map { String($0) }
            guard keyValuePair.count == 2 else { continue }
            dictionary[keyValuePair[0]] = keyValuePair[1]
        }
        return dictionary
    }
}
