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
    public static let shared = AppKit()
    public weak var delegate: AppKitDelegate?

    /// The current theme of the AppViewControllers and the App itself
    /// Choose between `.light`, `.dark` and `.automatic`
    /// The initial value is `.automatic``which is based on the current system interface style
    public var theme: AppKitTheme = .automatic

    var apiKey: String?
    var clientId: String?
    var authenticationMode: AuthenticationMode = .web
    var initialAccessToken: String?
    var currentAccessToken: String?
    var environment: AppEnvironment?
    var configValues: [ConfigValue: Any]?

    var userAgentExtensions: [String] = []

    private var proximityCheckPoiID: String?
    private var proximityCheckCompletion: ((Bool) -> Void)?

    private let auth: AppKitAuthorization
    private let appManager: AppManager

    private init() {
        AppStyle.loadAllFonts()

        auth = AppKitAuthorization()

        appManager = AppManager()
        appManager.delegate = self
    }

    public func setup(config: AppKitConfiguration) {
        self.clientId = config.clientId
        self.apiKey = config.apiKey
        self.authenticationMode = config.authenticationMode
        self.initialAccessToken = config.accessToken
        self.currentAccessToken = config.accessToken
        self.theme = config.theme
        self.environment = config.environment
        self.configValues = config.configValues

        auth.setup(apiKey: apiKey)

        guard let value = configValues?[ConfigValue.allowedLowAccuracy] as? Double else { return }
        appManager.setAllowedLocationAccuracy(value)
    }

    public func extendUserAgent(with extensions: [String]) {
        userAgentExtensions = extensions
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
    public func appViewController(appUrl: String, hasNavigationBar: Bool = false) -> UIViewController {
        AppViewController(appUrl: appUrl, hasNavigationBar: hasNavigationBar)
    }

    public func appWebView(appUrl: String) -> WKWebView {
        AppWebView(with: appUrl)
    }

    // MARK: - WebView or ViewController / apps with app url and reference
    public func appViewController(appUrl: String, reference: String, hasNavigationBar: Bool = false) -> UIViewController {
        let appUrl = appManager.buildAppUrl(with: appUrl, for: reference)
        return AppViewController(appUrl: appUrl, hasNavigationBar: hasNavigationBar)
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
        proximityCheckPoiID = id
        proximityCheckCompletion = completion
        appManager.startRetrievingLocation()
    }
}

extension AppKit: AppManagerDelegate {
    func didReceiveAppReferences(_ references: [String]) {
        AppKitLogger.i("Received the following references: \(references.joined(separator: ", "))")

        guard let id = proximityCheckPoiID, let completion = proximityCheckCompletion else {
            AppKitLogger.i("Missing ID or completion handler for `isPoiInRange` check")
            return
        }

        completion(references.contains(where: { $0.contains(id) }))

        proximityCheckPoiID = nil
        proximityCheckCompletion = nil
    }

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
            guard let urlHost = URL(string: $0.appApiUrl ?? "")?.host,
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
