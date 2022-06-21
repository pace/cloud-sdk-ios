//
//  SessionCache.swift
//  PACECloudSDK
//
//  Created by PACE Telematics GmbH.
//

import AppAuth

class SessionCache {
    static func loadSession(for environment: PACECloudSDK.Environment) -> OIDAuthState? {
        IDKitLogger.i("Attempting to load previous session...")

        // Fallback to old key
        guard let data = UserDefaults.standard.object(forKey: sessionCacheKey(for: environment)) as? Data
                ?? UserDefaults.standard.object(forKey: IDKitConstants.UserDefaults.sessionCache) as? Data else {
            return nil
        }

        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: OIDAuthState.self, from: data)
        } catch {
            IDKitLogger.e("Failed unarchiving session with error \(error)")
        }

        return nil
    }

    static func persistSession(_ session: OIDAuthState?, for environment: PACECloudSDK.Environment) {
        IDKitLogger.i("Persisting session")

        var data: Data?

        if let session = session {
            do {
                data = try NSKeyedArchiver.archivedData(withRootObject: session, requiringSecureCoding: false)
            } catch {
                IDKitLogger.e("Failed archiving session with error \(error)")
            }
        }

        UserDefaults.standard.setValue(data, forKey: sessionCacheKey(for: environment))
    }

    static func reset(for environment: PACECloudSDK.Environment) {
        // Remove session for old key as well
        [sessionCacheKey(for: environment), IDKitConstants.UserDefaults.sessionCache].forEach {
            UserDefaults.standard.setValue(nil, forKey: $0)
        }
    }

    private static func sessionCacheKey(for environment: PACECloudSDK.Environment) -> String {
        "\(IDKitConstants.UserDefaults.sessionCache)_\(environment.rawValue)"
    }
}
