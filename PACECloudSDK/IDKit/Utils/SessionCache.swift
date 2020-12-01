//
//  SessionCache.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

class SessionCache {
    static func loadSession() -> OIDAuthState? {
        IDKitLogger.i("Attempting to load previous session...")

        guard let data = UserDefaults.standard.object(forKey: IDKitConstants.UserDefaults.sessionCache) as? Data else {
            return nil
        }

        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data)
        } catch {
            IDKitLogger.e("Failed unarchiving session with error \(error)")
        }

        return nil
    }

    static func persistSession(_ session: OIDAuthState?) {
        IDKitLogger.i("Persisting session")

        var data: Data?

        if let session = session {
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
            } catch {
                IDKitLogger.e("Failed archiving session with error \(error)")
            }
        }

        UserDefaults.standard.setValue(data, forKey: IDKitConstants.UserDefaults.sessionCache)
    }

    static func reset() {
        UserDefaults.standard.setValue(nil, forKey: IDKitConstants.UserDefaults.sessionCache)
    }
}
