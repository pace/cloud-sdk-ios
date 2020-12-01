//
//  NavigationService.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import CoreLocation
import MapKit
import UIKit

struct NavigationService {
    static func handleNavigationRequest(to coordinates: CLLocationCoordinate2D, name: String) -> UIAlertController? {
        askForNavigationApp(to: coordinates, name: name)
    }

    private static func askForNavigationApp(to coordinates: CLLocationCoordinate2D, name: String) -> UIAlertController? {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if UIApplication.shared.canOpenURL(URL(string: "maps://")!) { // swiftlint:disable:this force_unwrapping
            let apple = UIAlertAction(title: "Apple Maps", style: .default) { _ in
                self.openInAppleMaps(to: coordinates, name: name)
            }
            optionMenu.addAction(apple)
        }

        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) { // swiftlint:disable:this force_unwrapping
            let google = UIAlertAction(title: "Google Maps", style: .default) { _ in
                self.openInGoogleMaps(to: coordinates)
            }
            optionMenu.addAction(google)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)

        if optionMenu.actions.count == 1 {
            return nil
        }

        return optionMenu
    }

    private static func openInAppleMaps(to coordinates: CLLocationCoordinate2D, name: String) {
        let regionDistance: CLLocationDistance = 1000
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }

    private static func openInGoogleMaps(to coordinates: CLLocationCoordinate2D) {
        guard (UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)), // swiftlint:disable:this force_unwrapping
            let url = URL(string: "comgooglemaps://?saddr=&daddr=\(coordinates.latitude),\(coordinates.longitude)&directionsmode=driving") else {
                return
            }

        UIApplication.shared.open(url)
    }
}
