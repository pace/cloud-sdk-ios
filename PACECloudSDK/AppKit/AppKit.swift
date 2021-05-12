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
    public static var shared: AppKit {
        PACECloudSDK.shared.warningsHandler?.logSDKWarningsIfNeeded()
        return sharedInternal
    }

    private static let sharedInternal = AppKit()

    public weak var delegate: AppKitDelegate?

    /// The current theme of the AppViewControllers and the App itself
    /// Choose between `.light`, `.dark` and `.automatic`
    /// The initial value is `.automatic``which is based on the current system interface style
    public var theme: AppKitTheme = .automatic

    let requestTimeoutHandler: RequestTimeoutHandler

    private let appManager: AppManager

    private init() {
        AppStyle.loadAllFonts()

        requestTimeoutHandler = RequestTimeoutHandler()

        appManager = AppManager()
        appManager.delegate = self
    }

    func setup(theme: AppKitTheme = .automatic) {
        self.theme = theme

        appManager.setConfigValues()
    }

    // MARK: - Drawer / Location based apps
    public func requestLocalApps() {
        appManager.startRetrievingLocation()
    }

    // MARK: - Apps as list
    public func requestListOfAppData(completion: @escaping (([AppData]?, AppError?) -> Void)) {
        appManager.fetchListOfApps { appDatas, error in
            DispatchQueue.main.async {
                completion(appDatas, error)
            }
        }
    }

    // MARK: - WebView or ViewController / apps with url
    public func appViewController(appUrl: String, hasNavigationBar: Bool = false, completion: (() -> Void)? = nil) -> AppViewController {
        AppViewController(appUrl: appUrl, hasNavigationBar: hasNavigationBar, completion: completion)
    }

    public func appWebView(appUrl: String) -> WKWebView {
        AppWebView(with: appUrl)
    }

    // MARK: - WebView or ViewController with preset urls
    public func appViewController(presetUrl: PACECloudSDK.URL, hasNavigationBar: Bool = false, completion: (() -> Void)? = nil) -> AppViewController {
        appViewController(appUrl: presetUrl.absoluteString, hasNavigationBar: hasNavigationBar, completion: completion)
    }

    public func appWebView(presetUrl: PACECloudSDK.URL) -> WKWebView {
        appWebView(appUrl: presetUrl.absoluteString)
    }

    // MARK: - WebView or ViewController / apps with app url and reference
    public func appViewController(appUrl: String, reference: String, hasNavigationBar: Bool = false, completion: (() -> Void)? = nil) -> AppViewController {
        let appUrl = appManager.buildAppUrl(with: appUrl, for: reference)
        return AppViewController(appUrl: appUrl, hasNavigationBar: hasNavigationBar, completion: completion)
    }

    public func appWebView(appUrl: String, reference: String) -> WKWebView {
        let appUrl = appManager.buildAppUrl(with: appUrl, for: reference)
        return AppWebView(with: appUrl)
    }

    public func sendEvent(_ event: AppEvent) {
        NotificationCenter.default.post(name: .appEventOccured, object: event)
    }

    public func setupGeofenceRegions(for locations: [String: CLLocationCoordinate2D]) {
        appManager.setupGeofenceRegions(for: locations)
    }

    public func resetGeofences() {
        appManager.resetGeofences()
    }

    public func handleRedirectURL(_ url: URL) {
        NotificationCenter.default.post(name: AppKitConstants.NotificationIdentifier.caughtRedirectService, object: nil, userInfo: [AppKitConstants.RedirectServiceParams.url: url])
    }

    // MARK: - POI proximity check
    public func isPoiInRange(id: String, completion: @escaping ((Bool) -> Void)) {
        appManager.isPoiInRange(with: id) { isAvailable in
            DispatchQueue.main.async {
                completion(isAvailable)
            }
        }
    }
}

extension AppKit: AppManagerDelegate {
    func didEnterGeofence(with id: String) {
        notifyDidEnterGeofence(with: id)
    }

    func didExitGeofence(with id: String) {
        notifyDidExitGeofence(with: id)
    }

    func didFailToMonitorRegion(_ region: CLRegion, error: Error) {
        notifyDidFailToMonitorRegion(region, error: error)
    }

    func passErrorToClient(_ error: AppError) {
        notifyDidFail(with: error)
    }

    func didReceiveAppDatas(_ appDatas: [AppData]) {
        // Filter out Apps that should not be shown
        let filteredAppData: [AppData] = appDatas.filter {
            guard let urlHost = URL(string: $0.appBaseUrl ?? "")?.host,
                let disableTime: Double = UserDefaults.standard.value(forKey: "disable_time_\(urlHost)") as? Double
            else {
                return true
            }

            if Date().timeIntervalSince1970 >= disableTime {
                AppKitLogger.i("Disable timer for \(urlHost) has been reached.")
                UserDefaults.standard.removeObject(forKey: "disable_time_\(urlHost)")

                return true
            }

            AppKitLogger.i("Don't show \(urlHost), because disable timer has not been reached.")
            return false
        }

        let appDrawers = filteredAppData.map { AppDrawer(with: $0) }
        notifyDidReceiveAppDrawerContainer(appDrawers, filteredAppData)
    }

    func didEscapeForecourt(_ appDatas: [AppData]) {
        notifyDidEscapeForecourt(appDatas)
    }
}
