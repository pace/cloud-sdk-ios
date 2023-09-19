//
//  MetaCollector.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

#if PACECloudWatchSDK
import WatchKit
#else
import UIKit
#endif

public extension PACECloudSDK {
    class MetaCollector {
        var isEnabled: Bool = true {
            didSet {
                guard oldValue != isEnabled else { return }
                setActivationState()
            }
        }

        private let data: RequestBody
        private let jsonEncoder: JSONEncoder

        init?(isEnabled: Bool) {
            guard let clientId = PACECloudSDK.shared.clientId ?? Bundle.main.bundleIdentifier else { return nil }
            self.data = .init(deviceId: DeviceInformation.id,
                              clientId: clientId,
                              services: [
                                RequestBody.DefaultService(name: Bundle.main.bundleName, version: Bundle.main.versionString),
                                RequestBody.DefaultService(name: "cloud-sdk-ios", version: Bundle.paceCloudSDK.releaseVersionNumber),
                                RequestBody.DefaultService(name: DeviceInformation.osName.lowercased(), version: DeviceInformation.deviceVersion)
                              ],
                              locale: Locale.current.languageCode)

            self.jsonEncoder = .init()
            self.isEnabled = isEnabled
            setActivationState()
        }

        deinit {
            detachAppLifecycleObserver()
        }
    }
}

public extension PACECloudSDK.MetaCollector {
    func addData(userId: String?,
                 locationData: RequestBody.Location?,
                 firebasePushToken: String?,
                 services: [MetaCollectorService]? = nil,
                 locale: String? = nil) {
        data.userId = userId
        data.lastLocation = locationData
        data.firebasePushToken = firebasePushToken

        if let services {
            data.services = (data.services ?? []) + services
        }

        if let locale {
            data.locale = locale
        }
    }

    func sendData() {
        do {
            let requestData = try JSONEncoder().encode(data)
            performRequest(data: requestData)
        } catch {
            SDKLogger.e("[MetaCollector] Failed encoding data with error \(error)")
        }
    }
}

private extension PACECloudSDK.MetaCollector {
    func performRequest(data: Data) {
        guard let url = URL(string: "\(Settings.shared.apiGateway)/client-data-collector/data"),
              let utmUrl = QueryParamHandler.buildUrl(for: url) else {
            SDKLogger.e("[MetaCollector] Failed building url.")
            return
        }

        var request = URLRequest.defaultURLRequest(url: utmUrl, withTracingId: true)
        request.setValue("application/json", forHTTPHeaderField: HttpHeaderFields.contentType.rawValue)
        request.httpMethod = "POST"
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                SDKLogger.e("[MetaCollector] Failed request with error \(error)")
                return
            }

            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                SDKLogger.e("[MetaCollector] Failed request - invalid url response.")
                return
            }

            if statusCode != HttpStatusCode.okNoContent.rawValue {
                SDKLogger.e("[MetaCollector] Failed request with status code \(statusCode)")
            }
        }.resume()
    }
}

private extension PACECloudSDK.MetaCollector {
    func setActivationState() {
        if isEnabled {
            attachAppLifecycleObserver()
        } else {
            detachAppLifecycleObserver()
        }
    }

    func attachAppLifecycleObserver() {
        var notificationName: NSNotification.Name

        #if PACECloudWatchSDK
        notificationName = WKExtension.applicationWillEnterForegroundNotification
        #else
        notificationName = UIApplication.willEnterForegroundNotification
        #endif

        NotificationCenter.default.addObserver(self, selector: #selector(handleAppLifecycleNotification), name: notificationName, object: nil)

        // Manually trigger notification selector once meta collector has been enabled
        handleAppLifecycleNotification()
    }

    func detachAppLifecycleObserver() {
        var notificationName: NSNotification.Name

        #if PACECloudWatchSDK
        notificationName = WKExtension.applicationWillEnterForegroundNotification
        #else
        notificationName = UIApplication.willEnterForegroundNotification
        #endif

        NotificationCenter.default.removeObserver(self, name: notificationName, object: nil)
    }

    @objc
    func handleAppLifecycleNotification() {
        sendData()
    }
}
