//
//  ExtensionDelegate.swift
//  WatchSDKExample Extension
//
//  Created by PACE Telematics GmbH.
//

import WatchKit
import PACECloudWatchSDK

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        let config: PACECloudSDK.Configuration = .init(
            apiKey: "a54445c2-ed2c-4b54-bb4d-42250e19a30d",
            authenticationMode: .native,
            environment: PACECloudSDK.Environment.development,
            isRedirectSchemeCheckEnabled: false,
            domainACL: ["pace.cloud"],
            allowedLowAccuracy: 200,
            geoAppsScope: "pace-drive-ios"
        )

        PACECloudSDK.shared.setup(with: config)

        API.accessToken = "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJnYlpySmRJelBTTWN1aHNJYzZfM3g3ZmhrdTM4UmN5MlZLVUZ4LWppNTNzIn0.eyJleHAiOjE2MjY4Nzg3MjIsImlhdCI6MTYyNjg3MTUyMiwiYXV0aF90aW1lIjoxNjI2ODcxNTIyLCJqdGkiOiI0ODczNzcwZS1iNTQyLTQ1MzctOGFiNy1lYmNjYTM1NzNkMjYiLCJpc3MiOiJodHRwczovL2lkLmRldi5wYWNlLmNsb3VkL2F1dGgvcmVhbG1zL3BhY2UiLCJzdWIiOiIzMjYxY2JlMC01M2NkLTQ4YzktOGUyNC0wM2YzYzI0ODE0NzIiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJkcml2ZS1hcHAtaW9zIiwibm9uY2UiOiJIelZweUVCQ1lZeGlwRUh1S0ZJMTlQYzNjd0I0WmNjMm9ZUS1CcFdJVVdNIiwic2Vzc2lvbl9zdGF0ZSI6ImM0MWJiZjY0LTc2YmEtNDlkMi04ZDQ3LWE5ZDljYzBmZjE3MCIsImFjciI6IjEiLCJzY29wZSI6InBvaTphcHBzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6Y3JlYXRlIHBheTphcHBsZXBheS1zZXNzaW9uczpjcmVhdGUgcGF5OnBheW1lbnQtbWV0aG9kczpjcmVhdGUgdXNlcjpwcmVmZXJlbmNlczpyZWFkOnBheW1lbnQtYXBwIHBheTpwYXltZW50LW1ldGhvZHM6cGF0Y2ggdXNlcjpkZXZpY2UtdG90cHM6Y3JlYXRlIHVzZXI6dXNlcnMucGluOmNoZWNrIHBheTp0cmFuc2FjdGlvbnM6cmVhZCBmdWVsaW5nOmdhcy1zdGF0aW9uczphcHByb2FjaGluZyBwYXk6cGF5bWVudC10b2tlbnM6ZGVsZXRlIHBvaTpnYXMtc3RhdGlvbnM6cmVhZCB1c2VyOnByZWZlcmVuY2VzOnJlYWQgZnVlbGluZzpwdW1wczpyZWFkIHVzZXI6b3RwOnZlcmlmeSB1c2VyOnByZWZlcmVuY2VzOnJlYWQ6ZHJpdmUtYXBwIHVzZXI6b3RwOmNyZWF0ZSB1c2VyOnByZWZlcmVuY2VzOndyaXRlIHBheTpwYXltZW50LXRva2VuczpjcmVhdGUgcGF5OnRyYW5zYWN0aW9uczpyZWNlaXB0IHVzZXI6dXNlcnMucGluOnVwZGF0ZSB1c2VyOmRldmljZS10b3RwczpjcmVhdGUtYWZ0ZXItbG9naW4gdXNlcjp1c2Vycy5wYXNzd29yZDpjaGVjayB1c2VyOnVzZXIuZW1haWw6cmVhZCBwYXk6cGF5bWVudC1tZXRob2RzOmRlbGV0ZSBwYXk6cGF5bWVudC1tZXRob2RzOnJlYWQgZnVlbGluZzp0cmFuc2FjdGlvbnM6ZGVsZXRlIHVzZXI6dGVybXM6YWNjZXB0IHBheTpwYXltZW50LXRva2VuczpyZWFkIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImVtYWlsIjoiY2FybEBwYWNlLmNhciJ9.MFdhQ8fPa0y2GynbL4qJGW45OPhrSYbSfrDrZwitInKM58lAbnnw95__VlHe64m6mZHI5LfSWBm1LtQrGtCetKa-In7WUb9m-0TGEjzQow-7Tbc1Bme_X-RHlSV4CtoEhD2iSL9H8qZhTv-2UO5ii_MvlDJ3dGi_zYPw4cxR6YZDNtTGWshJhwL03QIr2MaCDmH4cIxBhYugQr0ZUqu9sXuojLk-d_VLWCTcFUgFH-YrLMjyxlz0GulQDAgWh2D6DxmLGe19uIVEC4bFlaGhXpVpxJILxvyqgCf3Z2nXg-GIb_-EPKtnKKLfilt5VRgBQX43FOBhwglRRRoUvFZtog"
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
