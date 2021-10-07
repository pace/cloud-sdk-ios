//
//  AppKit.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import CoreLocation
import UIKit
import WebKit

public class AppKit {
    static var shared: AppKit {
        PACECloudSDK.shared.warningsHandler?.logSDKWarningsIfNeeded()
        return sharedInstance
    }

    private static let sharedInstance = AppKit()

    weak var delegate: AppKitDelegate?

    var theme: AppKitTheme = .automatic
    let requestTimeoutHandler: RequestTimeoutHandler

    private let appManager: AppManager

    private init() {
        requestTimeoutHandler = RequestTimeoutHandler()

        appManager = AppManager()
        appManager.delegate = self
    }

    func setup(theme: AppKitTheme = .automatic) {
        self.theme = theme
        appManager.setConfigValues()
    }
}

// MARK: - Setup
public extension AppKit {
    /**
     The delegate of AppKit.
     */
    static var delegate: AppKitDelegate? {
        get { shared.delegate }
        set { shared.delegate = newValue }
    }

    /**
     The current theme of the AppViewControllers and the App itself.
     Choose between `.light`, `.dark` and `.automatic`.
     The initial value is `.automatic``which is based on the current system interface style.
     */
    static var theme: AppKitTheme {
        get { shared.theme }
        set { shared.theme = newValue }
    }
}

// MARK: - AppViewControllers
public extension AppKit {
    /**
     Returns an `AppViewController` object that loads an app with the specified url.
     - parameter appUrl: The URL of the app.
     - parameter hasNavigationBar: Specifies if the navigation bar of the view controller will be displayed. Defaults to `false`.
     - parameter isModalInPresentation: Prevents the view controller from being dismissed when swiping down. Defaults to `true`.
     - parameter completion: The block to be called when the view controller gets closed.
     - returns: The prepared `AppViewController` object.
     */
    static func appViewController(appUrl: String,
                                  hasNavigationBar: Bool = false,
                                  isModalInPresentation: Bool = true,
                                  completion: (() -> Void)? = nil) -> AppViewController {
        AppViewController(appUrl: appUrl,
                          hasNavigationBar: hasNavigationBar,
                          isModalInPresentation: isModalInPresentation,
                          completion: completion)
    }

    /**
     Returns an `AppViewController` object that loads an app with the specified preset url.
     - parameter presetUrl: The pre-set url for an app.
     - parameter hasNavigationBar: Specifies if the navigation bar of the view controller will be displayed. Defaults to `false`.
     - parameter isModalInPresentation: Prevents the view controller from being dismissed when swiping down. Defaults to `true`.
     - parameter completion: The block to be called when the view controller gets closed.
     - returns: The prepared `AppViewController` object.
     */
    static func appViewController(presetUrl: PACECloudSDK.URL,
                                  hasNavigationBar: Bool = false,
                                  isModalInPresentation: Bool = true,
                                  completion: (() -> Void)? = nil) -> AppViewController {
        appViewController(appUrl: presetUrl.absoluteString,
                          hasNavigationBar: hasNavigationBar,
                          isModalInPresentation: isModalInPresentation,
                          completion: completion)
    }

    /**
     Returns an `AppViewController` object that loads an app with the specified url and gas station reference.
     - parameter appUrl: The URL of the app.
     - parameter reference: The gas station reference.
     - parameter isModalInPresentation: Prevents the view controller from being dismissed when swiping down. Defaults to `true`.
     - parameter hasNavigationBar: Specifies if the navigation bar of the view controller will be displayed. Defaults to `false`.
     - parameter completion: The block to be called when the view controller gets closed.
     - returns: The prepared `AppViewController` object.
     */
    static func appViewController(appUrl: String,
                                  reference: String,
                                  hasNavigationBar: Bool = false,
                                  isModalInPresentation: Bool = true,
                                  completion: (() -> Void)? = nil) -> AppViewController {
        let appUrl = shared.appManager.buildAppUrl(with: appUrl, for: reference)
        return AppViewController(appUrl: appUrl,
                                 hasNavigationBar: hasNavigationBar,
                                 isModalInPresentation: isModalInPresentation,
                                 completion: completion)
    }
}

// MARK: - AppWebViews
public extension AppKit {
    /**
     Returns an webview object that loads an app with the specified url.
     - parameter appUrl: The URL of the app.
     - returns: The prepared webview object.
     */
    static func appWebView(appUrl: String) -> WKWebView {
        AppWebView(with: appUrl)
    }

    /**
     Returns a webview object that loads an app with the specified preset url.
     - parameter presetUrl: The pre-set url for an app.
     - returns: The prepared webview object.
     */
    static func appWebView(presetUrl: PACECloudSDK.URL) -> WKWebView {
        appWebView(appUrl: presetUrl.absoluteString)
    }

    /**
     Returns a webview object that loads an app with the specified url and gas station reference.
     - parameter appUrl: The URL of the app.
     - parameter reference: The gas station reference.
     - returns: The prepared webview object.
     */
    static func appWebView(appUrl: String, reference: String) -> WKWebView {
        let appUrl = shared.appManager.buildAppUrl(with: appUrl, for: reference)
        return AppWebView(with: appUrl)
    }
}

public extension AppKit {
    /**
     Requests apps near the user's current location.

     The response will be delivered via both AppKitDelegate's callbacks `didReceiveAppDrawers(_ appDrawers: [AppKit.AppDrawer], _ appDatas: [AppKit.AppData])`
     and `didReceiveAppData(_ appData: [AppKit.AppData])`
     */
    static func requestLocalApps() {
        shared.appManager.startRetrievingLocation()
    }

    /**
     Requests a list `AppData` for all available apps.
     */
    static func requestListOfAppData(completion: @escaping (Result<[AppKit.AppData], AppKit.AppError>) -> Void) {
        shared.appManager.fetchListOfApps { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    /**
     Sets up geofences and starts monitoring the specified regions.
     - parameter locations: A list of keys along a given coordinate.
     */
    static func setupGeofenceRegions(for locations: [String: CLLocationCoordinate2D]) {
        shared.appManager.setupGeofenceRegions(for: locations)
    }

    /**
     Resets the geofences that have previously been set up via `setupGeofenceRegions(for locations: [String: CLLocationCoordinate2D])`.
     */
    static func resetGeofences() {
        shared.appManager.resetGeofences()
    }

    /**
     Handles the specified redirect URL within an `AppViewController`.
     - parameter url: The redirect URL.
     */
    static func handleRedirectURL(_ url: URL) {
        NotificationCenter.default.post(name: AppKit.Constants.NotificationIdentifier.caughtRedirectService,
                                        object: nil,
                                        userInfo: [AppKit.Constants.RedirectServiceParams.url: url])
    }

    static func sendEvent(_ event: AppEvent) {
        NotificationCenter.default.post(name: .appEventOccured, object: event)
    }
}
